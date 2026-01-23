import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/config/env_config.dart';
import 'package:ai_canaan_church/widgets/auth_wrapper.dart';
import 'package:ai_canaan_church/providers/sermon_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 웹 렌더러 설정 (한글 지원)
  if (kIsWeb) {
    // HTML 렌더러 사용 권장
  }
  
  // 환경 변수 로드
  await EnvConfig.load();
  
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
