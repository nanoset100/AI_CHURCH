import 'package:ai_canaan_church/widgets/faith_connections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('작은 화면과 큰 글씨에서 기도제목으로 이동한다', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var opened = false;
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: Scaffold(
            body: SingleChildScrollView(
          child: FaithConnections(onPrayerTap: () => opened = true),
        )),
      ),
    ));
    expect(find.text('유튜브 쇼츠'), findsOneWidget);
    expect(find.text('왕초보성경통독'), findsOneWidget);
    expect(find.textContaining('대표기도'), findsNothing);
    await tester.ensureVisible(find.text('나의 기도제목'));
    await tester.tap(find.text('나의 기도제목'));
    expect(opened, isTrue);
    expect(tester.takeException(), isNull);
  });
}
