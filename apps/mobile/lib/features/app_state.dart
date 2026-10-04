import 'package:flashi/data/study_repository.dart';
import 'package:flashi/domain/study.dart';
import 'package:flashi/domain/study_package.dart';
import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  final StudyRepository repository;
  List<StudySet> sets = const [];
  List<Subject> subjects = const [];
  List<StudyAttempt> attempts = const [];
  bool loading = false;
  String? error;

  AppState(this.repository);

  Future<void> reload() async {
    loading = true;
    notifyListeners();
    try {
      sets = await repository.sets();
      subjects = await repository.subjects();
      attempts = await repository.attempts();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> saveSet(StudySet set) async {
    await repository.saveSet(set);
    await reload();
  }

  Future<void> deleteSet(StudySet set) async {
    await repository.deleteSet(set.id);
    await reload();
  }

  Future<void> saveAttempt(StudyAttempt attempt) async {
    await repository.saveAttempt(attempt);
    await reload();
  }

  Future<StudyPackage> backup({String creator = ''}) =>
      repository.backup(creator: creator);

  Future<void> import(
    StudyPackage package,
    ImportBehavior behavior, {
    bool replaceLibrary = false,
  }) async {
    await repository.importPackage(
      package,
      behavior,
      replaceLibrary: replaceLibrary,
    );
    await reload();
  }

  StudyAttempt? latestAttemptFor(String setId) {
    for (final attempt in attempts) {
      if (attempt.setId == setId) return attempt;
    }
    return null;
  }
}
