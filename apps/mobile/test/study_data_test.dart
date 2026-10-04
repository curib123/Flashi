import 'dart:convert';
import 'package:flashi/domain/study.dart';
import 'package:flashi/domain/study_package.dart';
import 'package:flashi/data/study_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

StudySet sample() => StudySet(title: 'Biology', kind: SetKind.quiz, questions: [StudyQuestion(type: QuestionType.multipleChoice, question: 'Plants use?', answer: 'Light', options: ['Light', 'Sound', 'Ice', 'Salt'], topic: 'Plants', explanation: 'Light provides energy.')]);
void main() {
  setUpAll(sqfliteFfiInit);
  test('all supported question types round-trip with safe structured data', () {
    for(final type in QuestionType.values) {
      final q=StudyQuestion(type:type,question:type==QuestionType.fillBlank?'Plants use ____.':'Plants use?',answer:type==QuestionType.matching?'':type==QuestionType.trueFalse?'True':'Light',options:type==QuestionType.multipleChoice?['Light','Sound','Ice','Salt']:type==QuestionType.trueFalse?['True','False']:[],pairs:type==QuestionType.matching?[const MatchPair('A','1'),const MatchPair('B','2')]:[]);
      expect(StudyQuestion.fromJson(q.toJson()).type,type);
    }
  });
  test('normalization does not grant partial or substring matches', () {
    final q=sample().questions.first;
    expect(q.matches(' light '),true);expect(q.matches('lig'),false);expect(q.matches('Light and Sound'),false);
  });
  test('portable preview derives counts and import rejects executable references', () {
    final pack=StudyPackage.pack([sample()],creator:'Student');
    final read=StudyPackage.decode(pack.encode());
    expect(read.questionCount,1);expect(read.creator,'Student');
    final bad=jsonDecode(pack.encode()) as Map<String,dynamic>;
    (bad['data']['sets'][0] as Map<String,dynamic>)['script']='file:///etc/passwd';
    expect(()=>StudyPackage.decode(jsonEncode(bad)),throwsFormatException);
  });
  test('corruption, incompatible version and invalid answers are rejected before restore', () {
    expect(()=>StudyPackage.decode('{'),throwsFormatException);
    final raw=jsonDecode(StudyPackage.pack([sample()]).encode()) as Map<String,dynamic>;
    raw['version']=99;expect(()=>StudyPackage.decode(jsonEncode(raw)),throwsFormatException);
    raw['version']=1;raw['data']['sets'][0]['questions'][0]['answer']='Wrong';
    expect(()=>StudyPackage.decode(jsonEncode(raw)),throwsFormatException);
  });
  test('SQLite persists offline content, snapshots and independently imported copies', () async {
    final db=await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    final repo=await StudyRepository.open(database:db);final set=sample();await repo.saveSet(set);
    final pack=StudyPackage.pack([set]);await repo.importPackage(pack,ImportBehavior.duplicate);
    final sets=await repo.sets();expect(sets.length,2);expect(sets[0].id==sets[1].id,false);expect(sets[0].questions.first.id==sets[1].questions.first.id,false);
    final attempt=StudyAttempt(setId:set.id,title:set.title,mode:'quiz',answers:[AnswerRecord(question:set.questions.first,response:'Salt',correct:false)]);
    await repo.saveAttempt(attempt);expect((await repo.attempts()).first.mistakes.length,1);
    expect(StudyPackage.decode((await repo.backup()).encode()).attempts.length,1);
    await db.close();
  });
  test('restore is transactional and preserves pending edits', () async {
    final db=await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);final repo=await StudyRepository.open(database:db);
    final set=sample();await repo.saveSet(set);await repo.importPackage(StudyPackage.backup(sets:[set],subjects:[],attempts:[]),ImportBehavior.replace,replaceLibrary:true);
    expect((await repo.sets()).length,1);expect((await repo.pendingChanges('user')).length,1);
    await db.close();
  });
  test('a sync acknowledgement never erases edits made during the request', () async {
    final db=await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);final repo=await StudyRepository.open(database:db);
    final set=sample();await repo.saveSet(set);final before=(await repo.pendingChanges('user')).first;
    await repo.saveSet(set.copyWith(title:'New title'));
    await repo.acknowledge('user',set.id,1,before.localVersion);
    expect((await repo.pendingChanges('user')).first.payload!['title'],'New title');await db.close();
  });
}
