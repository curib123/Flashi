import 'dart:convert';
import 'package:flashi/domain/study.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum StudyPackageKind { backup, studyPack }
enum ImportBehavior { replace, duplicate, cancel }

class StudyPackage {
  static const format = 'flashi.study';
  static const currentVersion = 1;

  final StudyPackageKind kind;
  final int version;
  final String creator;
  final DateTime createdAt;
  final List<StudySet> sets;
  final List<Subject> subjects;
  final List<StudyAttempt> attempts;

  const StudyPackage._({
    required this.kind,
    required this.version,
    required this.creator,
    required this.createdAt,
    required this.sets,
    required this.subjects,
    required this.attempts,
  });

  factory StudyPackage.pack(List<StudySet> sets, {String creator = ''}) =>
      StudyPackage._(
        kind: StudyPackageKind.studyPack,
        version: currentVersion,
        creator: creator,
        createdAt: DateTime.now().toUtc(),
        sets: sets,
        subjects: const [],
        attempts: const [],
      );

  factory StudyPackage.backup({
    required List<StudySet> sets,
    required List<Subject> subjects,
    required List<StudyAttempt> attempts,
    String creator = '',
  }) =>
      StudyPackage._(
        kind: StudyPackageKind.backup,
        version: currentVersion,
        creator: creator,
        createdAt: DateTime.now().toUtc(),
        sets: sets,
        subjects: subjects,
        attempts: attempts,
      );

  int get flashcardCount => sets
      .expand((e) => e.questions)
      .where((q) => q.type == QuestionType.flashcard)
      .length;
  int get questionCount => sets.fold(0, (sum, set) => sum + set.questions.length);
  String get title => sets.length == 1 ? sets.first.title : 'Flashi Study Library';
  String get subject => sets.length == 1 ? sets.first.subject : '';
  String get contentType => kind == StudyPackageKind.backup
      ? 'Full backup'
      : sets.length == 1
          ? sets.first.kind.name
          : 'Study pack';

  Map<String, dynamic> toJson() => {
        'format': format,
        'version': version,
        'kind': kind.name,
        'creator': creator,
        'createdAt': createdAt.toIso8601String(),
        'data': {
          'sets': sets.map((e) => e.toJson()).toList(),
          'subjects': subjects.map((e) => e.toJson()).toList(),
          'attempts': attempts.map((e) => e.toJson()).toList(),
        },
      };

  String encode() => jsonEncode(toJson());

  static StudyPackage decode(String encoded) {
    try {
      final raw = jsonDecode(encoded);
      if (raw is! Map) throw const FormatException('Invalid Flashi package');
      final json = Map<String, dynamic>.from(raw);
      _strict(json, {'format', 'version', 'kind', 'creator', 'createdAt', 'data'});
      if (json['format'] != format || json['version'] != currentVersion) {
        throw const FormatException('Unsupported Flashi package version');
      }
      if (json['data'] is! Map) throw const FormatException('Invalid package data');
      final data = Map<String, dynamic>.from(json['data'] as Map);
      _strict(data, {'sets', 'subjects', 'attempts'});
      _rejectUnsafe(data);
      final sets = _list(data, 'sets')
          .map((e) => StudySet.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final subjects = _list(data, 'subjects')
          .map((e) => Subject.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final attempts = _list(data, 'attempts')
          .map((e) => StudyAttempt.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return StudyPackage._(
        kind: StudyPackageKind.values.firstWhere(
          (e) => e.name == json['kind'],
          orElse: () => throw const FormatException('Invalid package kind'),
        ),
        version: currentVersion,
        creator: json['creator'] is String ? json['creator'] as String : '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toUtc() ??
            (throw const FormatException('Invalid package timestamp')),
        sets: sets,
        subjects: subjects,
        attempts: attempts,
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Corrupted Flashi package');
    }
  }

  StudyPackage independentCopy() {
    final setMap = <String, String>{};
    final questionMap = <String, String>{};
    final newSets = sets.map((set) {
      final setId = _uuid.v4();
      setMap[set.id] = setId;
      final questions = set.questions.map((q) {
        final id = _uuid.v4();
        questionMap[q.id] = id;
        return q.copyWith(id: id);
      }).toList();
      return set.copyWith(id: setId, questions: questions);
    }).toList();
    final newSubjects =
        subjects.map((s) => Subject(title: s.title, updatedAt: s.updatedAt)).toList();
    final newAttempts = attempts
        .where((a) => setMap.containsKey(a.setId))
        .map((a) => StudyAttempt(
              setId: setMap[a.setId]!,
              title: a.title,
              mode: a.mode,
              startedAt: a.startedAt,
              finishedAt: a.finishedAt,
              answers: a.answers
                  .map((record) => AnswerRecord(
                        question: record.question.copyWith(
                          id: questionMap[record.question.id] ?? _uuid.v4(),
                        ),
                        response: record.response,
                        correct: record.correct,
                      ))
                  .toList(),
            ))
        .toList();
    return StudyPackage._(
      kind: kind,
      version: version,
      creator: creator,
      createdAt: createdAt,
      sets: newSets,
      subjects: newSubjects,
      attempts: newAttempts,
    );
  }

  static List<dynamic> _list(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! List) throw FormatException('Invalid $key');
    if (value.any((e) => e is! Map)) throw FormatException('Invalid $key entry');
    return value;
  }

  static void _strict(Map<String, dynamic> json, Set<String> keys) {
    if (json.keys.any((key) => !keys.contains(key))) {
      throw const FormatException('Unexpected Flashi package field');
    }
  }

  static void _rejectUnsafe(dynamic value) {
    if (value is String) {
      final v = value.trim().toLowerCase();
      if (v.startsWith('file:') ||
          v.startsWith('content:') ||
          v.startsWith('javascript:') ||
          v.contains('<script') ||
          v.contains('../') ||
          v.contains('..\\')) {
        throw const FormatException('Unsafe reference in study package');
      }
    } else if (value is List) {
      for (final item in value) {
        _rejectUnsafe(item);
      }
    } else if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key.toString().toLowerCase();
        if ({'script', 'executable', 'filepath', 'file_path', 'uri'}.contains(key)) {
          throw const FormatException('Unsafe field in study package');
        }
        _rejectUnsafe(entry.value);
      }
    }
  }
}
