import 'dart:convert';
import 'package:ai_canaan_church/models/public_sermon_model.dart';
import 'package:ai_canaan_church/providers/prayer_provider.dart';
import 'package:ai_canaan_church/providers/sermon_provider.dart';
import 'package:ai_canaan_church/screens/search/sermon_detail_screen.dart';
import 'package:ai_canaan_church/services/prayer_note_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final date = DateTime(2025, 3, 2);
  final sermon = PublicSermonModel(
      id: 'old',
      churchName: '',
      region: '',
      pastor: '',
      title: '함께 걷는 길',
      bibleVerse: '시편 23편',
      sermonDate: date,
      summary: '말씀 요약',
      application: '',
      broadcastDate: date,
      source: '',
      createdAt: date);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('공개 설교가 없는 날과 연결 실패를 구분하고 마지막 말씀을 보존한다', () async {
    var fail = false;
    var sermons = <PublicSermonModel>[];
    var cached = false;
    final p = SermonProvider(fetch: ({required limit, region}) async {
      if (fail) {
        throw FirebaseException(plugin: 'cloud_firestore', code: 'unavailable');
      }
      return (sermons: sermons, fromCache: cached);
    });
    await p.loadToday();
    expect(p.todaySermon, isNull);
    expect(p.homeMessage, isNull);
    fail = true;
    await p.loadToday();
    await p.loadRecent();
    expect(p.homeMessage, isNotNull);
    expect(p.todaySermon, isNull);
    expect(p.searchResults, isEmpty);
    expect(p.searchMessage, isNotNull);
    fail = false;
    sermons = [sermon];
    cached = true;
    await p.loadToday();
    expect(p.todaySermon, sermon);
    expect(p.homeMessage, contains('저장된 말씀'));
    fail = true;
    await p.loadToday();
    expect(p.todaySermon, sermon);
    fail = false;
    cached = false;
    sermons = [];
    await p.loadToday();
    expect(p.todaySermon, isNull);
  });

  testWidgets('과거 상세 말씀에서 기도하면 읽은 제목과 구절을 저장한다', (tester) async {
    final provider = PrayerProvider();
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(home: SermonDetailScreen(sermon: sermon))));
    final button = find.text('이 말씀으로 기도 쓰기');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '함께 걸을 용기를 주세요.');
    await tester.pump();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    final saved = (await PrayerNoteService.loadAll()).single;
    expect(saved.sermonTitle, sermon.title);
    expect(saved.bibleVerse, sermon.bibleVerse);
    expect(saved.content, '함께 걸을 용기를 주세요.');
  });

  test('이전 기록과 ID가 겹치는 백업도 보존하고 중복 복원을 건너뛴다', () async {
    final old = {
      'id': '123',
      'content': '이전 기록',
      'sermonTitle': null,
      'bibleVerse': null,
      'createdAt': 123
    };
    SharedPreferences.setMockInitialValues({
      'prayer_notes': jsonEncode([old])
    });
    final p = PrayerProvider();
    final backup = jsonDecode(await p.backup());
    backup['notes'][0]['content'] = '다른 기기에서 쓴 기도';
    final imported = PrayerNoteService.readBackup(jsonEncode(backup));
    expect(await p.restore(imported), 1);
    expect(await p.restore(imported), 0);
    expect((await PrayerNoteService.loadAll()).map((n) => n.content),
        unorderedEquals(['이전 기록', '다른 기기에서 쓴 기도']));
    expect(() => PrayerNoteService.readBackup('{"notes": []}'),
        throwsFormatException);
  });
}
