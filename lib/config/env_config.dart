import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 변수 관리 클래스
///
/// 빌드 시 --dart-define-from-file=.env.json 으로 주입하거나
/// 실행 시 .env 에셋 파일에서 로드함 (Fallback 지원)
class EnvConfig {
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // 릴리즈 빌드에서 .env 로드 실패 시 로그 출력 (dart-define이 있을 수 있으므로 중단하지 않음)
      print('EnvConfig: .env file not found or failed to load. Falling back to dart-define.');
    }
  }

  static String get supabaseUrl => 
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '') != '' 
          ? const String.fromEnvironment('SUPABASE_URL') 
          : dotenv.get('SUPABASE_URL', fallback: '');

  static String get supabaseAnonKey => 
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '') != '' 
          ? const String.fromEnvironment('SUPABASE_ANON_KEY') 
          : dotenv.get('SUPABASE_ANON_KEY', fallback: '');

  /// URL과 필수 키가 설정되었는지 확인
  static bool get isConfigured {
    final url = supabaseUrl;
    final key = supabaseAnonKey;
    return url.isNotEmpty &&
        key.isNotEmpty &&
        url.startsWith('https://') &&
        url.contains('.supabase.co');
  }
}
