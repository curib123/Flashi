import 'dart:convert';
import 'package:flashi/domain/study.dart';
import 'package:flashi/domain/study_package.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class PendingChange {
  final String entityId;
  final String entityType;
  final int baseRevision;
  final int localVersion;
  final bool deleted;
  final Map<String, dynamic>? payload;

  const PendingChange({
    required this.entityId,
    required this.entityType,
    required this.baseRevision,
    required this.localVersion,
    required this.deleted,
    required this.payload,
  });

  Map<String, dynamic> toApi() => {
        'id': entityId,
        'entityType': entityType,
        'baseRevision': baseRevision,
        'deleted': deleted,
        'payload': payload,
      };
}

class StudyRepository {
  final Database _db;
  StudyRepository._(this._db);

  static Future<StudyRepository> open({Database? database}) async {
    final db = database ??
        await openDatabase(
          p.join((await getApplicationDocumentsDirectory()).path, 'flashi.db'),
          version: 1,
          onCreate: (db, _) => _createSchema(db),
        );
    await _createSchema(db);
    return StudyRepository._(db);
  }

  static Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS study_sets(
        id TEXT PRIMARY KEY,
        payload TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS subjects(
        id TEXT PRIMARY KEY,
        payload TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS attempts(
        id TEXT PRIMARY KEY,
        set_id TEXT NOT NULL,
        payload TEXT NOT NULL,
        finished_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pending_changes(
        user_id TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        base_revision INTEGER NOT NULL DEFAULT 0,
        local_version INTEGER NOT NULL DEFAULT 1,
        deleted INTEGER NOT NULL DEFAULT 0,
        payload TEXT,
        PRIMARY KEY(user_id, entity_id)
      )
    ''');
  }

  Future<List<StudySet>> sets() async {
    final rows = await _db.query('study_sets', orderBy: 'updated_at DESC');
    return rows
        .map((row) => StudySet.fromJson(
            Map<String, dynamic>.from(jsonDecode(row['payload'] as String))))
        .toList();
  }

  Future<List<Subject>> subjects() async {
    final rows = await _db.query('subjects', orderBy: 'updated_at DESC');
    return rows
        .map((row) => Subject.fromJson(
            Map<String, dynamic>.from(jsonDecode(row['payload'] as String))))
        .toList();
  }

  Future<List<StudyAttempt>> attempts() async {
    final rows = await _db.query('attempts', orderBy: 'finished_at DESC');
    return rows
        .map((row) => StudyAttempt.fromJson(
            Map<String, dynamic>.from(jsonDecode(row['payload'] as String))))
        .toList();
  }

  Future<void> saveSet(StudySet set, {bool queueSync = true}) async {
    await _db.transaction((txn) async {
      await txn.insert(
        'study_sets',
        {
          'id': set.id,
          'payload': jsonEncode(set.toJson()),
          'updated_at': set.updatedAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (queueSync) await _queue(txn, set.id, 'set', set.toJson());
    });
  }

  Future<void> deleteSet(String id) async {
    await _db.transaction((txn) async {
      await txn.delete('study_sets', where: 'id=?', whereArgs: [id]);
      await _queue(txn, id, 'set', null, deleted: true);
    });
  }

  Future<void> saveSubject(Subject subject, {bool queueSync = true}) async {
    await _db.transaction((txn) async {
      await txn.insert(
        'subjects',
        {
          'id': subject.id,
          'payload': jsonEncode(subject.toJson()),
          'updated_at': subject.updatedAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (queueSync) await _queue(txn, subject.id, 'subject', subject.toJson());
    });
  }

  Future<void> saveAttempt(StudyAttempt attempt, {bool queueSync = true}) async {
    await _db.transaction((txn) async {
      await txn.insert(
        'attempts',
        {
          'id': attempt.id,
          'set_id': attempt.setId,
          'payload': jsonEncode(attempt.toJson()),
          'finished_at': attempt.finishedAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (queueSync) await _queue(txn, attempt.id, 'attempt', attempt.toJson());
    });
  }

  Future<StudyPackage> backup({String creator = ''}) async =>
      StudyPackage.backup(
        sets: await sets(),
        subjects: await subjects(),
        attempts: await attempts(),
        creator: creator,
      );

  Future<void> importPackage(
    StudyPackage package,
    ImportBehavior behavior, {
    bool replaceLibrary = false,
  }) async {
    if (behavior == ImportBehavior.cancel) return;
    final source =
        behavior == ImportBehavior.duplicate ? package.independentCopy() : package;

    await _db.transaction((txn) async {
      if (replaceLibrary) {
        await txn.delete('attempts');
        await txn.delete('subjects');
        await txn.delete('study_sets');
        await txn.delete('pending_changes');
      }

      for (final subject in source.subjects) {
        await txn.insert(
          'subjects',
          {
            'id': subject.id,
            'payload': jsonEncode(subject.toJson()),
            'updated_at': subject.updatedAt.toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final set in source.sets) {
        await txn.insert(
          'study_sets',
          {
            'id': set.id,
            'payload': jsonEncode(set.toJson()),
            'updated_at': set.updatedAt.toIso8601String(),
          },
          conflictAlgorithm: behavior == ImportBehavior.replace
              ? ConflictAlgorithm.replace
              : ConflictAlgorithm.abort,
        );
      }
      for (final attempt in source.attempts) {
        await txn.insert(
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

      for (final set in source.sets) {
        await _queue(txn, set.id, 'set', set.toJson());
      }
      for (final subject in source.subjects) {
        await _queue(txn, subject.id, 'subject', subject.toJson());
      }
      for (final attempt in source.attempts) {
        await _queue(txn, attempt.id, 'attempt', attempt.toJson());
      }
    });
  }

  Future<List<PendingChange>> pendingChanges(String userId) async {
    final rows = await _db.query(
      'pending_changes',
      where: 'user_id=?',
      whereArgs: [userId],
      orderBy: 'local_version ASC',
    );
    return rows.map((row) {
      final raw = row['payload'] as String?;
      return PendingChange(
        entityId: row['entity_id'] as String,
        entityType: row['entity_type'] as String,
        baseRevision: row['base_revision'] as int,
        localVersion: row['local_version'] as int,
        deleted: (row['deleted'] as int) == 1,
        payload: raw == null
            ? null
            : Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    }).toList();
  }

  Future<void> acknowledge(
    String userId,
    String entityId,
    int serverRevision,
    int sentLocalVersion,
  ) async {
    await _db.transaction((txn) async {
      final rows = await txn.query(
        'pending_changes',
        where: 'user_id=? AND entity_id=?',
        whereArgs: [userId, entityId],
        limit: 1,
      );
      if (rows.isEmpty) return;
      final current = rows.first['local_version'] as int;
      if (current == sentLocalVersion) {
        await txn.delete(
          'pending_changes',
          where: 'user_id=? AND entity_id=?',
          whereArgs: [userId, entityId],
        );
      } else {
        await txn.update(
          'pending_changes',
          {'base_revision': serverRevision},
          where: 'user_id=? AND entity_id=?',
          whereArgs: [userId, entityId],
        );
      }
    });
  }

  Future<void> applyRemote({
    required String entityType,
    required int revision,
    required bool deleted,
    required Map<String, dynamic>? payload,
  }) async {
    if (payload == null && !deleted) return;
    if (entityType == 'set') {
      if (deleted) {
        await _db.delete('study_sets', where: 'id=?', whereArgs: [payload?['id']]);
      } else {
        await saveSet(StudySet.fromJson(payload!), queueSync: false);
      }
    } else if (entityType == 'subject' && !deleted) {
      await saveSubject(Subject.fromJson(payload!), queueSync: false);
    } else if (entityType == 'attempt' && !deleted) {
      await saveAttempt(StudyAttempt.fromJson(payload!), queueSync: false);
    }
  }

  Future<void> _queue(
    DatabaseExecutor txn,
    String id,
    String type,
    Map<String, dynamic>? payload, {
    bool deleted = false,
  }) async {
    const userId = 'user';
    final existing = await txn.query(
      'pending_changes',
      columns: ['base_revision', 'local_version'],
      where: 'user_id=? AND entity_id=?',
      whereArgs: [userId, id],
      limit: 1,
    );
    final baseRevision =
        existing.isEmpty ? 0 : existing.first['base_revision'] as int;
    final localVersion =
        existing.isEmpty ? 1 : (existing.first['local_version'] as int) + 1;
    await txn.insert(
      'pending_changes',
      {
        'user_id': userId,
        'entity_id': id,
        'entity_type': type,
        'base_revision': baseRevision,
        'local_version': localVersion,
        'deleted': deleted ? 1 : 0,
        'payload': payload == null ? null : jsonEncode(payload),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
