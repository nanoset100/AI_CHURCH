/// 환경 변수 관리 클래스
///
/// 빌드 시 --dart-define-from-file=.env.json 으로 주입
/// 키가 바이너리에 컴파일되어 평문 파일로 노출되지 않음
class EnvConfig {
  static const String _supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');
  static const String _supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static Future<void> load() async {
    // dart-define 방식에서는 런타임 로드 불필요
  }

  static String get supabaseUrl => _supabaseUrl;

  static String get supabaseAnonKey => _supabaseAnonKey;

  /// URL과 필수 키가 설정되었는지 확인
  static bool get isConfigured {
    return _supabaseUrl.isNotEmpty &&
        _supabaseAnonKey.isNotEmpty &&
        _supabaseUrl.startsWith('https://') &&
        _supabaseUrl.contains('.supabase.co');
  }
}
