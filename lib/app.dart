import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/sermon_provider.dart';
import 'providers/prayer_provider.dart';
import 'screens/main_screen.dart';

class AiCanaanChurchApp extends StatelessWidget {
  const AiCanaanChurchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SermonProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
      ],
      child: MaterialApp(
        title: 'AI 가나안교회',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const MainScreen(),
        // 로그인 강요 없음 — 바로 메인 화면 진입
      ),
    );
  }
}
