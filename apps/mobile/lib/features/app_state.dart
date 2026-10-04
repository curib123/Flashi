import 'package:flashi/data/study_repository.dart';
import 'package:flashi/domain/study.dart';
import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  final StudyRepository repository;

  List<StudySet> _sets = const [];
  List<StudyAttempt> _attempts = const [];
  bool _loading = false;

  AppState(this.repository);

  List<StudySet> get sets => _sets;
  List<StudyAttempt> get attempts => _attempts;
  bool get loading => _loading;

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    try {
      _sets = await repository.sets();
      _attempts = await repository.attempts();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> saveSet(StudySet set) async {
    await repository.saveSet(set);
    await reload();
  }

  Future<void> saveAttempt(StudyAttempt attempt) async {
    await repository.saveAttempt(attempt);
    await reload();
  }
}
