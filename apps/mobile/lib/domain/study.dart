import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum SetKind { deck, quiz, exam }
enum Difficulty { easy, medium, hard }

enum QuestionType {
  flashcard,
  multipleChoice,
  identification,
  trueFalse,
  definition,
  fillBlank,
  matching,
  questionAnswer,
  enumeration,
}

String _questionTypeName(QuestionType type) {
  switch (type) {
    case QuestionType.multipleChoice:
      return 'multiple_choice';
    case QuestionType.trueFalse:
      return 'true_false';
    case QuestionType.fillBlank:
      return 'fill_blank';
    case QuestionType.questionAnswer:
      return 'question_answer';
    default:
      return type.name;
  }
}

QuestionType _questionTypeFromName(String value) {
  for (final type in QuestionType.values) {
    if (_questionTypeName(type) == value) return type;
  }
  throw FormatException('Unsupported question type: $value');
}

void _expectKeys(Map<String, dynamic> json, Set<String> allowed) {
  final unknown = json.keys.where((key) => !allowed.contains(key)).toList();
  if (unknown.isNotEmpty) {
    throw FormatException('Unknown fields: ${unknown.join(', ')}');
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) throw FormatException('Invalid $key');
  return value;
}

List<String> _stringList(dynamic value) {
  if (value is! List || value.any((item) => item is! String)) {
    throw const FormatException('Invalid string list');
  }
  return List<String>.from(value);
}

class MatchPair {
  final String left;
  final String right;

  const MatchPair(this.left, this.right);

  Map<String, dynamic> toJson() => {'left': left, 'right': right};

  factory MatchPair.fromJson(Map<String, dynamic> json) {
    _expectKeys(json, const {'left', 'right'});
    final pair = MatchPair(
      _requiredString(json, 'left').trim(),
      _requiredString(json, 'right').trim(),
    );
    if (pair.left.isEmpty || pair.right.isEmpty) {
      throw const FormatException('Matching pairs cannot be empty');
    }
    return pair;
  }
}

class StudyQuestion {
  final String id;
  final QuestionType type;
  final String question;
  final String answer;
  final List<String> options;
  final String explanation;
  final String topic;
  final List<MatchPair> pairs;

  StudyQuestion({
    String? id,
    required this.type,
    required this.question,
    required this.answer,
    List<String>? options,
    this.explanation = '',
    this.topic = '',
    List<MatchPair>? pairs,
  })  : id = id ?? _uuid.v4(),
        options = List.unmodifiable(options ?? const []),
        pairs = List.unmodifiable(pairs ?? const []) {
    _validate();
  }

  void _validate() {
    if (question.trim().isEmpty) {
      throw const FormatException('Question cannot be empty');
    }
    if (type == QuestionType.matching) {
      if (answer.isNotEmpty || options.isNotEmpty || pairs.length < 2) {
        throw const FormatException('Invalid matching question');
      }
      final left = pairs.map((pair) => pair.left).toSet();
      final right = pairs.map((pair) => pair.right).toSet();
      if (left.length != pairs.length || right.length != pairs.length) {
        throw const FormatException('Matching pairs must be unique');
      }
      return;
    }
    if (answer.trim().isEmpty) {
      throw const FormatException('Answer cannot be empty');
    }
    if (type == QuestionType.multipleChoice) {
      if (options.length != 4 ||
          options.toSet().length != 4 ||
          !options.contains(answer)) {
        throw const FormatException('Invalid multiple-choice answers');
      }
    } else if (type == QuestionType.trueFalse) {
      if (!const ['True', 'False'].contains(answer) ||
          options.length != 2 ||
          options[0] != 'True' ||
          options[1] != 'False') {
        throw const FormatException('Invalid true/false question');
      }
    } else if (options.isNotEmpty) {
      throw const FormatException('Unexpected answer options');
    }
    if (type == QuestionType.fillBlank && !RegExp(r'_{3,}').hasMatch(question)) {
      throw const FormatException('Fill-in-the-blank questions need a blank');
    }
  }

  bool matches(String response) => _normalize(response) == _normalize(answer);

  static String _normalize(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': _questionTypeName(type),
        'question': question,
        'answer': answer,
        'options': options,
        'explanation': explanation,
        'topic': topic,
        'pairs': pairs.map((pair) => pair.toJson()).toList(),
      };

  factory StudyQuestion.fromJson(Map<String, dynamic> json) {
    _expectKeys(json, const {
      'id',
      'type',
      'question',
      'answer',
      'options',
      'explanation',
      'topic',
      'pairs',
    });
    final rawPairs = json['pairs'];
    if (rawPairs is! List) throw const FormatException('Invalid pairs');
    return StudyQuestion(
      id: _requiredString(json, 'id'),
      type: _questionTypeFromName(_requiredString(json, 'type')),
      question: _requiredString(json, 'question'),
      answer: _requiredString(json, 'answer'),
      options: _stringList(json['options']),
      explanation: _requiredString(json, 'explanation'),
      topic: _requiredString(json, 'topic'),
      pairs: rawPairs
          .map((item) => MatchPair.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    );
  }

  StudyQuestion duplicate() => StudyQuestion(
        type: type,
        question: question,
        answer: answer,
        options: options,
        explanation: explanation,
        topic: topic,
        pairs: pairs,
      );
}

class StudySet {
  final String id;
  final String title;
  final String subject;
  final String creator;
  final SetKind kind;
  final Difficulty difficulty;
  final List<StudyQuestion> questions;
  final DateTime updatedAt;

  StudySet({
    String? id,
    required this.title,
    this.subject = '',
    this.creator = '',
    this.kind = SetKind.deck,
    this.difficulty = Difficulty.medium,
    required List<StudyQuestion> questions,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        questions = List.unmodifiable(questions),
        updatedAt = updatedAt ?? DateTime.now().toUtc() {
    if (title.trim().isEmpty) throw const FormatException('Title is required');
    if (questions.map((question) => question.id).toSet().length !=
        questions.length) {
      throw const FormatException('Duplicate question IDs');
    }
  }

  StudySet copyWith({
    String? id,
    String? title,
    String? subject,
    String? creator,
    SetKind? kind,
    Difficulty? difficulty,
    List<StudyQuestion>? questions,
    DateTime? updatedAt,
  }) {
    return StudySet(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      creator: creator ?? this.creator,
      kind: kind ?? this.kind,
      difficulty: difficulty ?? this.difficulty,
      questions: questions ?? this.questions,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    );
  }

  StudySet duplicate() => StudySet(
        title: title,
        subject: subject,
        creator: creator,
        kind: kind,
        difficulty: difficulty,
        questions: questions.map((question) => question.duplicate()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'creator': creator,
        'kind': kind.name,
        'difficulty': difficulty.name,
        'questions': questions.map((question) => question.toJson()).toList(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory StudySet.fromJson(Map<String, dynamic> json) {
    _expectKeys(json, const {
      'id',
      'title',
      'subject',
      'creator',
      'kind',
      'difficulty',
      'questions',
      'updatedAt',
    });
    final rawQuestions = json['questions'];
    if (rawQuestions is! List) throw const FormatException('Invalid questions');
    final kind = SetKind.values.where((item) => item.name == json['kind']).firstOrNull;
    final difficulty =
        Difficulty.values.where((item) => item.name == json['difficulty']).firstOrNull;
    if (kind == null || difficulty == null) {
      throw const FormatException('Invalid set kind or difficulty');
    }
    return StudySet(
      id: _requiredString(json, 'id'),
      title: _requiredString(json, 'title'),
      subject: _requiredString(json, 'subject'),
      creator: _requiredString(json, 'creator'),
      kind: kind,
      difficulty: difficulty,
      questions: rawQuestions
          .map((item) => StudyQuestion.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      updatedAt: DateTime.parse(_requiredString(json, 'updatedAt')).toUtc(),
    );
  }
}

class Subject {
  final String id;
  final String title;
  final DateTime updatedAt;

  Subject({String? id, required this.title, DateTime? updatedAt})
      : id = id ?? _uuid.v4(),
        updatedAt = updatedAt ?? DateTime.now().toUtc();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory Subject.fromJson(Map<String, dynamic> json) {
    _expectKeys(json, const {'id', 'title', 'updatedAt'});
    return Subject(
      id: _requiredString(json, 'id'),
      title: _requiredString(json, 'title'),
      updatedAt: DateTime.parse(_requiredString(json, 'updatedAt')).toUtc(),
    );
  }

  Subject duplicate() => Subject(title: title);
}

class AnswerRecord {
  final StudyQuestion question;
  final String response;
  final bool correct;

  const AnswerRecord({
    required this.question,
    required this.response,
    required this.correct,
  });

  Map<String, dynamic> toJson() => {
        'question': question.toJson(),
        'response': response,
        'correct': correct,
      };

  factory AnswerRecord.fromJson(Map<String, dynamic> json) {
    _expectKeys(json, const {'question', 'response', 'correct'});
    if (json['question'] is! Map || json['correct'] is! bool) {
      throw const FormatException('Invalid answer record');
    }
    return AnswerRecord(
      question: StudyQuestion.fromJson(
        Map<String, dynamic>.from(json['question'] as Map),
      ),
      response: _requiredString(json, 'response'),
      correct: json['correct'] as bool,
    );
  }
}

class StudyAttempt {
  final String id;
  final String setId;
  final String title;
  final String mode;
  final DateTime startedAt;
  final DateTime finishedAt;
  final List<AnswerRecord> answers;

  StudyAttempt({
    String? id,
    required this.setId,
    required this.title,
    required this.mode,
    DateTime? startedAt,
    DateTime? finishedAt,
    required List<AnswerRecord> answers,
  })  : id = id ?? _uuid.v4(),
        startedAt = startedAt ?? DateTime.now().toUtc(),
        finishedAt = finishedAt ?? DateTime.now().toUtc(),
        answers = List.unmodifiable(answers);

  int get score {
    if (answers.isEmpty) return 0;
    return ((answers.where((answer) => answer.correct).length / answers.length) *
            100)
        .round();
  }

  List<AnswerRecord> get mistakes =>
      answers.where((answer) => !answer.correct).toList(growable: false);

  Map<String, dynamic> toJson() => {
        'id': id,
        'setId': setId,
        'title': title,
        'mode': mode,
        'startedAt': startedAt.toUtc().toIso8601String(),
        'finishedAt': finishedAt.toUtc().toIso8601String(),
        'answers': answers.map((answer) => answer.toJson()).toList(),
      };

  factory StudyAttempt.fromJson(Map<String, dynamic> json) {
    _expectKeys(json, const {
      'id',
      'setId',
      'title',
      'mode',
      'startedAt',
      'finishedAt',
      'answers',
    });
    final rawAnswers = json['answers'];
    if (rawAnswers is! List) throw const FormatException('Invalid answers');
    return StudyAttempt(
      id: _requiredString(json, 'id'),
      setId: _requiredString(json, 'setId'),
      title: _requiredString(json, 'title'),
      mode: _requiredString(json, 'mode'),
      startedAt: DateTime.parse(_requiredString(json, 'startedAt')).toUtc(),
      finishedAt: DateTime.parse(_requiredString(json, 'finishedAt')).toUtc(),
      answers: rawAnswers
          .map((item) => AnswerRecord.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    for (final value in this) {
      return value;
    }
    return null;
  }
}
