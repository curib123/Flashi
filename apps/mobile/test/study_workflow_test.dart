import 'package:flashi/app.dart';
import 'package:flashi/domain/study.dart';
import 'package:flashi/data/study_repository.dart';
import 'package:flashi/features/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);
  testWidgets('guest can create, study and review mistakes without a network', (tester) async {
    final db=await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);final repo=await StudyRepository.open(database:db);final state=AppState(repo);await state.reload();
    await repo.saveSet(StudySet(title:'Plants',kind:SetKind.quiz,questions:[StudyQuestion(type:QuestionType.trueFalse,question:'Plants need light.',answer:'True',options:['True','False'],explanation:'Light powers photosynthesis.',topic:'Photosynthesis')]));await state.reload();
    tester.view.physicalSize=const Size(360,800);tester.view.devicePixelRatio=1;addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(FlashiApp(state:state));await tester.pumpAndSettle();
    expect(find.text('Assistant'),findsNothing);expect(find.text('Turn Notes Into Knowledge.'),findsOneWidget);
    await tester.tap(find.text('Plants').first);await tester.pumpAndSettle();
    await tester.tap(find.text('Start Quiz'));await tester.pumpAndSettle();
    await tester.tap(find.text('False'));await tester.tap(find.text('Check Answer'));await tester.pumpAndSettle();
    expect(find.text('Light powers photosynthesis.'),findsOneWidget);
    await tester.tap(find.text('Finish'));await tester.pumpAndSettle();
    expect(find.text('Review Mistakes'),findsOneWidget);expect((await repo.attempts()).first.score,0);
    expect(tester.takeException(),isNull);await tester.pumpWidget(const SizedBox());state.dispose();await db.close();
  });
}
