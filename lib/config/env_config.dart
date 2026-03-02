import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 변수 관리 클래스
class EnvConfig {
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get supabaseUrl {
    return (dotenv.env['SUPABASE_URL'] ?? '').trim();
  }

  static String get supabaseAnonKey {
    return (dotenv.env['SUPABASE_ANON_KEY'] ?? '').trim();
  }

  /// URL과 키가 설정되었는지 확인
  static bool get isConfigured {
    final url = supabaseUrl;
    final key = supabaseAnonKey;
    return url.isNotEmpty &&
        key.isNotEmpty &&
        url.startsWith('https://') &&
        url.contains('.supabase.co');
  }
}
