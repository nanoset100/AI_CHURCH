import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/config/env_config.dart';
import 'package:ai_canaan_church/widgets/auth_wrapper.dart';
import 'package:ai_canaan_church/providers/sermon_provider.dart';
import 'package:ai_canaan_church/providers/bible_provider.dart';
import 'package:ai_canaan_church/providers/prayer_provider.dart';
import 'package:ai_canaan_church/providers/activity_provider.dart';
import 'package:ai_canaan_church/providers/auth_provider.dart' as app_auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 웹 렌더러 설정 (한글 지원)
  if (kIsWeb) {
    // HTML 렌더러 사용 권장
  }
  
  // 환경 변수 로드
  await EnvConfig.load();

  // Supabase 설정 검증
  if (!EnvConfig.isConfigured) {
    runApp(_SupabaseConfigErrorApp(
      message: 'Supabase URL 또는 Anon Key가 .env에 올바르게 설정되지 않았습니다.\n'
          'Supabase 대시보드 > Settings > API에서 값을 복사해 .env 파일을 수정하세요.',
    ));
    return;
  }

  // Supabase 초기화
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SermonProvider()),
        ChangeNotifierProvider(create: (_) => BibleProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
      ],
      child: MaterialApp(
        title: 'AI 가나안교회',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Supabase 설정 오류 시 표시할 화면
class _SupabaseConfigErrorApp extends StatelessWidget {
  final String message;

  const _SupabaseConfigErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI 가나안교회',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.settings_suggest, size: 64, color: AppTheme.primaryColor),
                const SizedBox(height: 24),
                Text(
                  '연결 설정이 필요합니다',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
