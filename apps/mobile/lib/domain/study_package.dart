import 'dart:convert';

import 'package:flashi/domain/study.dart';

class StudyPackage {
  static const format = 'flashi.study';
  static const currentVersion = 1;
  static const maxBytes = 8 * 1024 * 1024;

  final String packageType;
  final String creator;
  final DateTime createdAt;
  final List<StudySet> sets;
  final List<Subject> subjects;
  final List<StudyAttempt> attempts;

  StudyPackage._({
    required this.packageType,
    required this.creator,
    required this.createdAt,
    required this.sets,
    required this.subjects,
    required this.attempts,
  });

  factory StudyPackage.pack(
    List<StudySet> sets, {
    String creator = '',
    List<Subject> subjects = const [],
  }) {
    return StudyPackage._(
      packageType: 'pack',
      creator: creator,
      createdAt: DateTime.now().toUtc(),
      sets: List.unmodifiable(sets),
      subjects: List.unmodifiable(subjects),
      attempts: const [],
    );
  }

  factory StudyPackage.backup({
    required List<StudySet> sets,
    required List<Subject> subjects,
    required List<StudyAttempt> attempts,
    String creator = '',
  }) {
    return StudyPackage._(
      packageType: 'backup',
      creator: creator,
      createdAt: DateTime.now().toUtc(),
      sets: List.unmodifiable(sets),
      subjects: List.unmodifiable(subjects),
      attempts: List.unmodifiable(attempts),
    );
  }

  int get questionCount =>
      sets.fold(0, (total, set) => total + set.questions.length);

  String encode() {
    return jsonEncode({
      'format': format,
      'version': currentVersion,
      'packageType': packageType,
      'metadata': {
        'creator': creator,
        'createdAt': createdAt.toIso8601String(),
        'setCount': sets.length,
        'questionCount': questionCount,
      },
      'data': {
        'sets': sets.map((set) => set.toJson()).toList(),
        'subjects': subjects.map((subject) => subject.toJson()).toList(),
        'attempts': attempts.map((attempt) => attempt.toJson()).toList(),
      },
    });
  }

  factory StudyPackage.decode(String raw) {
    try {
      if (utf8.encode(raw).length > maxBytes) {
        throw const FormatException('Package is too large');
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map) throw const FormatException('Invalid package');
      final root = Map<String, dynamic>.from(decoded);
      _expect(root, const {'format', 'version', 'packageType', 'metadata', 'data'});
      if (root['format'] != format || root['version'] != currentVersion) {
        throw const FormatException('Unsupported Flashi package');
      }
      if (root['packageType'] != 'pack' && root['packageType'] != 'backup') {
        throw const FormatException('Invalid package type');
      }

      final metadata = Map<String, dynamic>.from(root['metadata'] as Map);
      _expect(
        metadata,
        const {'creator', 'createdAt', 'setCount', 'questionCount'},
      );
      final data = Map<String, dynamic>.from(root['data'] as Map);
      _expect(data, const {'sets', 'subjects', 'attempts'});

      final sets = _mapList(data['sets'], StudySet.fromJson);
      final subjects = _mapList(data['subjects'], Subject.fromJson);
      final attempts = _mapList(data['attempts'], StudyAttempt.fromJson);

      final setIds = sets.map((set) => set.id).toSet();
      if (setIds.length != sets.length) {
        throw const FormatException('Duplicate set IDs');
      }
      final subjectIds = subjects.map((subject) => subject.id).toSet();
      if (subjectIds.length != subjects.length) {
        throw const FormatException('Duplicate subject IDs');
      }
      if (attempts.any((attempt) => !setIds.contains(attempt.setId))) {
        throw const FormatException('Orphan study attempt');
      }

      final package = StudyPackage._(
        packageType: root['packageType'] as String,
        creator: metadata['creator'] as String,
        createdAt: DateTime.parse(metadata['createdAt'] as String).toUtc(),
        sets: List.unmodifiable(sets),
        subjects: List.unmodifiable(subjects),
        attempts: List.unmodifiable(attempts),
      );
      if (metadata['setCount'] != package.sets.length ||
          metadata['questionCount'] != package.questionCount) {
        throw const FormatException('Package metadata does not match content');
      }
      return package;
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Invalid Flashi package');
    }
  }

  static List<T> _mapList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (value is! List) throw const FormatException('Invalid package list');
    return value
        .map((item) {
          if (item is! Map) throw const FormatException('Invalid package item');
          return parser(Map<String, dynamic>.from(item));
        })
        .toList(growable: false);
  }

  static void _expect(Map<String, dynamic> map, Set<String> allowed) {
    if (map.keys.any((key) => !allowed.contains(key))) {
      throw const FormatException('Unknown package field');
    }
  }
}
