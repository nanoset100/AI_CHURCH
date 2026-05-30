import 'package:ai_canaan_church/models/public_sermon_model.dart';
import 'package:ai_canaan_church/widgets/weekly_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WeeklyStrip shows recent sermons', (tester) async {
    final sermon = PublicSermonModel(
      id: 'test-sermon',
      churchName: '목포 하당로교회',
      region: '전남',
      pastor: '테스트 목사',
      title: '진짜 그리스도인',
      bibleVerse: '마태복음 13:25',
      sermonDate: DateTime(2026, 5, 25),
      summary: '테스트 설교 요약',
      application: '테스트 적용',
      broadcastDate: DateTime(2026, 5, 26),
      source: '데일리 말씀노트',
      createdAt: DateTime(2026, 5, 26),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeeklyStrip(
            sermons: [sermon],
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('최근 말씀'), findsOneWidget);
    expect(find.text('5/26'), findsOneWidget);
    expect(find.text('마태복음 13'), findsOneWidget);
  });
}
