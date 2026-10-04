import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum SetKind { deck, quiz, exam }

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

String questionTypeWire(QuestionType type) => switch (type) {
  QuestionType.flashcard => 'flashcard',
  QuestionType.multipleChoice => 'multiple_choice',
  QuestionType.identification => 'identification',
  QuestionType.trueFalse => 'true_false',
  QuestionType.definition => 'definition',
  QuestionType.fillBlank => 'fill_blank',
  QuestionType.matching => 'matching',
  QuestionType.questionAnswer => 'question_answer',
  QuestionType.enumeration => 'enumeration',
};

QuestionType questionTypeFromWire(String value) {
  for (final type in QuestionType.values) {
    if (questionTypeWire(type) == value) return type;
  }
  throw const FormatException('Unsupported question type');
}

String setKindWire(SetKind kind) => kind.name;
SetKind setKindFromWire(String value) =>
    SetKind.values.firstWhere((e) => e.name == value,
        orElse: () => throw const FormatException('Unsupported set kind'));

void _strictKeys(Map<String, dynamic> json, Set<String> keys) {
  if (json.keys.any((key) => !keys.contains(key))) {
    throw const FormatException('Unexpected package field');
  }
}

String _requiredString(Map<String, dynamic> json, String key,
    {bool allowEmpty = false}) {
  final value = json[key];
  if (value is! String || (!allowEmpty && value.trim().isEmpty)) {
    throw FormatException('Invalid $key');
  }
  return value;
}

class MatchPair {
  final String left;
  final String right;
  const MatchPair(this.left, this.right);

  Map<String, dynamic> toJson() => {'left': left, 'right': right};

  factory MatchPair.fromJson(Map<String, dynamic> json) {
    _strictKeys(json, {'left', 'right'});
    return MatchPair(_requiredString(json, 'left'), _requiredString(json, 'right'));
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
    this.options = const [],
    this.explanation = '',
    this.topic = '',
    this.pairs = const [],
  }) : id = id ?? _uuid.v4();

  StudyQuestion copyWith({
    String? id,
    QuestionType? type,
    String? question,
    String? answer,
    List<String>? options,
    String? explanation,
    String? topic,
    List<MatchPair>? pairs,
  }) =>
      StudyQuestion(
        id: id ?? this.id,
        type: type ?? this.type,
        question: question ?? this.question,
        answer: answer ?? this.answer,
        options: options ?? this.options,
        explanation: explanation ?? this.explanation,
        topic: topic ?? this.topic,
        pairs: pairs ?? this.pairs,
      );

  bool matches(String response) {
    String normalize(String value) =>
        value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    return normalize(response) == normalize(answer);
  }

  void validate() {
    if (question.trim().isEmpty || question.length > 4000) {
      throw const FormatException('Invalid question');
    }
    if (type == QuestionType.matching) {
      if (answer.isNotEmpty || options.isNotEmpty || pairs.length < 2) {
        throw const FormatException('Invalid matching question');
      }
      return;
    }
    if (answer.trim().isEmpty || pairs.isNotEmpty) {
      throw const FormatException('Invalid answer');
    }
    if (type == QuestionType.multipleChoice) {
      if (options.length != 4 ||
          options.toSet().length != 4 ||
          !options.contains(answer)) {
        throw const FormatException('Invalid multiple choice answers');
      }
    } else if (type == QuestionType.trueFalse) {
      if (answer != 'True' && answer != 'False') {
        throw const FormatException('Invalid true/false answer');
      }
      if (options.length != 2 ||
          options[0] != 'True' ||
          options[1] != 'False') {
        throw const FormatException('Invalid true/false options');
      }
    } else if (options.isNotEmpty) {
      throw const FormatException('Unexpected options');
    }
    if (type == QuestionType.fillBlank && !question.contains('___')) {
      throw const FormatException('Fill-in-the-blank needs a blank');
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': questionTypeWire(type),
        'question': question,
        'answer': answer,
        'options': options,
        'explanation': explanation,
        'topic': topic,
        'pairs': pairs.map((e) => e.toJson()).toList(),
      };

  factory StudyQuestion.fromJson(Map<String, dynamic> json) {
    _strictKeys(json, {
      'id',
      'type',
      'question',
      'answer',
      'options',
      'explanation',
      'topic',
      'pairs'
    });
    final options = json['options'];
    final pairs = json['pairs'];
    if (options is! List || pairs is! List) {
      throw const FormatException('Invalid question lists');
    }
    final result = StudyQuestion(
      id: _requiredString(json, 'id'),
      type: questionTypeFromWire(_requiredString(json, 'type')),
      question: _requiredString(json, 'question'),
      answer: _requiredString(json, 'answer', allowEmpty: true),
      options: options.map((e) {
        if (e is! String || e.trim().isEmpty) {
          throw const FormatException('Invalid option');
        }
        return e;
      }).toList(),
      explanation: _requiredString(json, 'explanation', allowEmpty: true),
      topic: _requiredString(json, 'topic', allowEmpty: true),
      pairs: pairs.map((e) {
        if (e is! Map) throw const FormatException('Invalid matching pair');
        return MatchPair.fromJson(Map<String, dynamic>.from(e));
      }).toList(),
    );
    result.validate();
    return result;
  }
}

class StudySet {
  final String id;
  final String title;
  final String subject;
  final String creator;
  final SetKind kind;
  final String difficulty;
  final List<StudyQuestion> questions;
  final DateTime updatedAt;

  StudySet({
    String? id,
    required this.title,
    this.subject = '',
    this.creator = '',
    required this.kind,
    this.difficulty = 'medium',
    this.questions = const [],
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        updatedAt = updatedAt ?? DateTime.now().toUtc();

  StudySet copyWith({
    String? id,
    String? title,
    String? subject,
    String? creator,
    SetKind? kind,
    String? difficulty,
    List<StudyQuestion>? questions,
    DateTime? updatedAt,
  }) =>
      StudySet(
        id: id ?? this.id,
        title: title ?? this.title,
        subject: subject ?? this.subject,
        creator: creator ?? this.creator,
        kind: kind ?? this.kind,
        difficulty: difficulty ?? this.difficulty,
        questions: questions ?? this.questions,
        updatedAt: updatedAt ?? DateTime.now().toUtc(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'creator': creator,
        'kind': setKindWire(kind),
        'difficulty': difficulty,
        'questions': questions.map((e) => e.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory StudySet.fromJson(Map<String, dynamic> json) {
    _strictKeys(json, {
      'id',
      'title',
      'subject',
      'creator',
      'kind',
      'difficulty',
      'questions',
      'updatedAt'
    });
    final rawQuestions = json['questions'];
    if (rawQuestions is! List) throw const FormatException('Invalid questions');
    final result = StudySet(
      id: _requiredString(json, 'id'),
      title: _requiredString(json, 'title'),
      subject: _requiredString(json, 'subject', allowEmpty: true),
      creator: _requiredString(json, 'creator', allowEmpty: true),
      kind: setKindFromWire(_requiredString(json, 'kind')),
      difficulty: _requiredString(json, 'difficulty'),
      questions: rawQuestions.map((item) {
        if (item is! Map) throw const FormatException('Invalid question');
        return StudyQuestion.fromJson(Map<String, dynamic>.from(item));
      }).toList(),
      updatedAt: DateTime.tryParse(_requiredString(json, 'updatedAt'))?.toUtc(),
    );
    if (!{'easy', 'medium', 'hard'}.contains(result.difficulty)) {
      throw const FormatException('Invalid difficulty');
    }
    if (result.questions.map((e) => e.id).toSet().length !=
        result.questions.length) {
      throw const FormatException('Duplicate question ids');
    }
    return result;
  }
}

class Subject {
  final String id;
  final String title;
  final DateTime updatedAt;

  Subject({String? id, required this.title, DateTime? updatedAt})
      : id = id ?? _uuid.v4(),
        updatedAt = updatedAt ?? DateTime.now().toUtc();

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'updatedAt': updatedAt.toIso8601String()};

  factory Subject.fromJson(Map<String, dynamic> json) {
    _strictKeys(json, {'id', 'title', 'updatedAt'});
    return Subject(
      id: _requiredString(json, 'id'),
      title: _requiredString(json, 'title'),
      updatedAt: DateTime.tryParse(_requiredString(json, 'updatedAt'))?.toUtc(),
    );
  }
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
    _strictKeys(json, {'question', 'response', 'correct'});
    if (json['question'] is! Map || json['correct'] is! bool) {
      throw const FormatException('Invalid answer record');
    }
    return AnswerRecord(
      question: StudyQuestion.fromJson(
          Map<String, dynamic>.from(json['question'] as Map)),
      response: _requiredString(json, 'response', allowEmpty: true),
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
    this.answers = const [],
  })  : id = id ?? _uuid.v4(),
        startedAt = startedAt ?? DateTime.now().toUtc(),
        finishedAt = finishedAt ?? DateTime.now().toUtc();

  int get correctCount => answers.where((e) => e.correct).length;
  int get score =>
      answers.isEmpty ? 0 : ((correctCount / answers.length) * 100).round();
  List<AnswerRecord> get mistakes =>
      answers.where((e) => !e.correct).toList(growable: false);

  Map<String, int> get weakTopics {
    final result = <String, int>{};
    for (final item in mistakes) {
      final topic =
          item.question.topic.trim().isEmpty ? 'General' : item.question.topic;
      result[topic] = (result[topic] ?? 0) + 1;
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'setId': setId,
        'title': title,
        'mode': mode,
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': finishedAt.toIso8601String(),
        'answers': answers.map((e) => e.toJson()).toList(),
      };

  factory StudyAttempt.fromJson(Map<String, dynamic> json) {
    _strictKeys(json,
        {'id', 'setId', 'title', 'mode', 'startedAt', 'finishedAt', 'answers'});
    final raw = json['answers'];
    if (raw is! List) throw const FormatException('Invalid attempt answers');
    return StudyAttempt(
      id: _requiredString(json, 'id'),
      setId: _requiredString(json, 'setId'),
      title: _requiredString(json, 'title'),
      mode: _requiredString(json, 'mode'),
      startedAt:
          DateTime.tryParse(_requiredString(json, 'startedAt'))?.toUtc(),
      finishedAt:
          DateTime.tryParse(_requiredString(json, 'finishedAt'))?.toUtc(),
      answers: raw.map((item) {
        if (item is! Map) throw const FormatException('Invalid answer');
        return AnswerRecord.fromJson(Map<String, dynamic>.from(item));
      }).toList(),
    );
  }
}
