import 'dart:convert';

import 'package:flashi/domain/study.dart';
import 'package:flashi/domain/study_package.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

enum ImportBehavior { replace, duplicate, cancel }

class PendingChange {
  final String id;
  final String entityType;
  final int localVersion;
  final int serverRevision;
  final bool deleted;
  final Map<String, dynamic>? payload;

  const PendingChange({
    required this.id,
    required this.entityType,
    required this.localVersion,
    required this.serverRevision,
    required this.deleted,
    required this.payload,
  });
}

class StudyRepository {
  final Database database;

  StudyRepository._(this.database);

  static Future<StudyRepository> open({Database? database}) async {
    final db = database ??
        await openDatabase(
          p.join(await getDatabasesPath(), 'flashi.db'),
          version: 1,
        );
    final repository = StudyRepository._(db);
    await repository._createSchema();
    return repository;
  }

  Future<void> _createSchema() async {
    await database.execute(
      'CREATE TABLE IF NOT EXISTS study_sets ('
      'id TEXT PRIMARY KEY, payload TEXT NOT NULL, updated_at TEXT NOT NULL)',
    );
    await database.execute(
      'CREATE TABLE IF NOT EXISTS subjects ('
      'id TEXT PRIMARY KEY, payload TEXT NOT NULL, updated_at TEXT NOT NULL)',
    );
    await database.execute(
      'CREATE TABLE IF NOT EXISTS attempts ('
      'id TEXT PRIMARY KEY, set_id TEXT NOT NULL, payload TEXT NOT NULL, finished_at TEXT NOT NULL)',
    );
    await database.execute(
      'CREATE TABLE IF NOT EXISTS metadata ('
      'key TEXT PRIMARY KEY, value TEXT NOT NULL)',
    );
    await database.execute(
      'CREATE TABLE IF NOT EXISTS pending_changes ('
      'account_id TEXT NOT NULL, entity_id TEXT NOT NULL, entity_type TEXT NOT NULL, '
      'local_version INTEGER NOT NULL, server_revision INTEGER NOT NULL DEFAULT 0, '
      'deleted INTEGER NOT NULL DEFAULT 0, payload TEXT, '
      'PRIMARY KEY(account_id, entity_id))',
    );
  }

  Future<void> migrateLegacyQuizSets(dynamic raw) async {
    final migrated = await database.query(
      'metadata',
      where: 'key = ?',
      whereArgs: ['legacy_hive_quiz_migrated'],
      limit: 1,
    );
    if (migrated.isNotEmpty) return;

    await database.transaction((txn) async {
      if (raw is List) {
        for (final item in raw) {
          if (item is! Map) continue;
          final legacy = Map<String, dynamic>.from(item);
          final title = (legacy['name'] ?? '').toString().trim();
          if (title.isEmpty) continue;

          final rawCards = legacy['cards'];
          final questions = <StudyQuestion>[];
          if (rawCards is List) {
            for (final card in rawCards) {
              if (card is! Map) continue;
              final map = Map<String, dynamic>.from(card);
              final question = (map['question'] ?? '').toString().trim();
              final answer = (map['answer'] ?? '').toString().trim();
              if (question.isEmpty || answer.isEmpty) continue;
              questions.add(
                StudyQuestion(
                  type: QuestionType.identification,
                  question: question,
                  answer: answer,
                  topic: (map['keyword'] ?? '').toString(),
                ),
              );
            }
          }

          final set = StudySet(
            title: title,
            subject: (legacy['description'] ?? '').toString(),
            kind: SetKind.quiz,
            questions: questions,
          );
          await _putSet(txn, set);
        }
      }

      await txn.insert(
        'metadata',
        {'key': 'legacy_hive_quiz_migrated', 'value': '1'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<List<StudySet>> sets() async {
    final rows = await database.query('study_sets', orderBy: 'updated_at DESC');
    return rows
        .map((row) => StudySet.fromJson(
              Map<String, dynamic>.from(jsonDecode(row['payload'] as String)),
            ))
        .toList();
  }

  Future<List<Subject>> subjects() async {
    final rows = await database.query('subjects', orderBy: 'updated_at DESC');
    return rows
        .map((row) => Subject.fromJson(
              Map<String, dynamic>.from(jsonDecode(row['payload'] as String)),
            ))
        .toList();
  }

  Future<List<StudyAttempt>> attempts() async {
    final rows = await database.query('attempts', orderBy: 'finished_at DESC');
    return rows
        .map((row) => StudyAttempt.fromJson(
              Map<String, dynamic>.from(jsonDecode(row['payload'] as String)),
            ))
        .toList();
  }

  Future<void> saveSet(StudySet set, {String accountId = 'user'}) async {
    await database.transaction((txn) async {
      await _putSet(txn, set);
      await _recordPending(txn, accountId, 'set', set.id, set.toJson());
    });
  }

  Future<void> saveSubject(
    Subject subject, {
    String accountId = 'user',
  }) async {
    await database.transaction((txn) async {
      await txn.insert(
        'subjects',
        {
          'id': subject.id,
          'payload': jsonEncode(subject.toJson()),
          'updated_at': subject.updatedAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await _recordPending(
        txn,
        accountId,
        'subject',
        subject.id,
        subject.toJson(),
      );
    });
  }

  Future<void> saveAttempt(
    StudyAttempt attempt, {
    String accountId = 'user',
  }) async {
    await database.transaction((txn) async {
      await _putAttempt(txn, attempt);
      await _recordPending(
        txn,
        accountId,
        'attempt',
        attempt.id,
        attempt.toJson(),
      );
    });
  }

  Future<void> importPackage(
    StudyPackage package,
    ImportBehavior behavior, {
    bool replaceLibrary = false,
    String accountId = 'user',
  }) async {
    if (behavior == ImportBehavior.cancel) return;

    final importedSets = behavior == ImportBehavior.duplicate
        ? package.sets.map((set) => set.duplicate()).toList()
        : package.sets;
    final importedSubjects = behavior == ImportBehavior.duplicate
        ? package.subjects.map((subject) => subject.duplicate()).toList()
        : package.subjects;
    final sourceToImportedSetId = <String, String>{};
    for (var index = 0; index < package.sets.length; index++) {
      sourceToImportedSetId[package.sets[index].id] = importedSets[index].id;
    }
    final importedAttempts = behavior == ImportBehavior.duplicate
        ? package.attempts
            .map(
              (attempt) => StudyAttempt(
                setId: sourceToImportedSetId[attempt.setId] ?? attempt.setId,
                title: attempt.title,
                mode: attempt.mode,
                startedAt: attempt.startedAt,
                finishedAt: attempt.finishedAt,
                answers: attempt.answers
                    .map(
                      (answer) => AnswerRecord(
                        question: answer.question.duplicate(),
                        response: answer.response,
                        correct: answer.correct,
                      ),
                    )
                    .toList(),
              ),
            )
            .toList()
        : package.attempts;

    await database.transaction((txn) async {
      if (replaceLibrary) {
        await txn.delete('attempts');
        await txn.delete('study_sets');
        await txn.delete('subjects');
      }
      for (final subject in importedSubjects) {
        await txn.insert(
          'subjects',
          {
            'id': subject.id,
            'payload': jsonEncode(subject.toJson()),
            'updated_at': subject.updatedAt.toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await _recordPending(
          txn,
          accountId,
          'subject',
          subject.id,
          subject.toJson(),
        );
      }
      for (final set in importedSets) {
        await _putSet(txn, set);
        await _recordPending(txn, accountId, 'set', set.id, set.toJson());
      }
      for (final attempt in importedAttempts) {
        await _putAttempt(txn, attempt);
        await _recordPending(
          txn,
          accountId,
          'attempt',
          attempt.id,
          attempt.toJson(),
        );
      }
    });
  }

  Future<StudyPackage> backup({String creator = ''}) async {
    return StudyPackage.backup(
      sets: await sets(),
      subjects: await subjects(),
      attempts: await attempts(),
      creator: creator,
    );
  }

  Future<List<PendingChange>> pendingChanges(String accountId) async {
    final rows = await database.query(
      'pending_changes',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'local_version ASC',
    );
    return rows
        .map(
          (row) => PendingChange(
            id: row['entity_id'] as String,
            entityType: row['entity_type'] as String,
            localVersion: row['local_version'] as int,
            serverRevision: row['server_revision'] as int,
            deleted: (row['deleted'] as int) == 1,
            payload: row['payload'] == null
                ? null
                : Map<String, dynamic>.from(
                    jsonDecode(row['payload'] as String),
                  ),
          ),
        )
        .toList();
  }

  Future<void> acknowledge(
    String accountId,
    String entityId,
    int serverRevision,
    int expectedLocalVersion,
  ) async {
    await database.transaction((txn) async {
      final rows = await txn.query(
        'pending_changes',
        where: 'account_id = ? AND entity_id = ?',
        whereArgs: [accountId, entityId],
        limit: 1,
      );
      if (rows.isEmpty) return;
      final currentVersion = rows.first['local_version'] as int;
      if (currentVersion == expectedLocalVersion) {
        await txn.delete(
          'pending_changes',
          where: 'account_id = ? AND entity_id = ?',
          whereArgs: [accountId, entityId],
        );
      } else {
        await txn.update(
          'pending_changes',
          {'server_revision': serverRevision},
          where: 'account_id = ? AND entity_id = ?',
          whereArgs: [accountId, entityId],
        );
      }
    });
  }

  Future<void> _putSet(DatabaseExecutor db, StudySet set) async {
    await db.insert(
      'study_sets',
      {
        'id': set.id,
        'payload': jsonEncode(set.toJson()),
        'updated_at': set.updatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _putAttempt(DatabaseExecutor db, StudyAttempt attempt) async {
    await db.insert(
      'attempts',
      {
        'id': attempt.id,
        'set_id': attempt.setId,
        'payload': jsonEncode(attempt.toJson()),
        'finished_at': attempt.finishedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _recordPending(
    DatabaseExecutor db,
    String accountId,
    String entityType,
    String entityId,
    Map<String, dynamic>? payload, {
    bool deleted = false,
  }) async {
    final existing = await db.query(
      'pending_changes',
      columns: ['local_version', 'server_revision'],
      where: 'account_id = ? AND entity_id = ?',
      whereArgs: [accountId, entityId],
      limit: 1,
    );
    final nextVersion =
        existing.isEmpty ? 1 : (existing.first['local_version'] as int) + 1;
    final serverRevision =
        existing.isEmpty ? 0 : existing.first['server_revision'] as int;
    await db.insert(
      'pending_changes',
      {
        'account_id': accountId,
        'entity_id': entityId,
        'entity_type': entityType,
        'local_version': nextVersion,
        'server_revision': serverRevision,
        'deleted': deleted ? 1 : 0,
        'payload': payload == null ? null : jsonEncode(payload),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() => database.close();
}
