import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ReflectOS 정석 패턴을 따르는 인증 서비스
/// 
/// 핵심 원칙:
/// 1. 회원가입 성공 후 자동 로그인 절대 금지
/// 2. 가입 완료 시 로그인 화면으로 리다이렉트
/// 3. 로그인 성공 시에만 HomeScreen 진입
class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// 회원가입
  /// 
  /// ReflectOS 패턴:
  /// - 회원가입 성공 시 자동 로그인하지 않음
  /// - 프로필 저장 실패해도 가입은 성공으로 처리
  /// - "이제 로그인해주세요" 메시지 반환
  static Future<AuthResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // 비밀번호 길이 검증
      if (password.length < 6) {
        return AuthResult(
          success: false,
          message: '비밀번호는 6자 이상이어야 합니다.',
        );
      }

      // Supabase Auth로 사용자 생성
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult(
          success: false,
          message: '회원가입에 실패했습니다.',
        );
      }

      final userId = response.user!.id;

      // display_name 설정 (없으면 이메일 앞부분 사용)
      final finalDisplayName = displayName?.trim().isEmpty ?? true
          ? email.split('@')[0]
          : displayName!.trim();

      // 프로필 저장 시도 (백그라운드, 실패해도 가입 성공)
      try {
        await _client.from('profiles').upsert({
          'id': userId,
          'email': email,
          'display_name': finalDisplayName,
        });
        
        return AuthResult(
          success: true,
          message: '회원가입이 완료되었습니다! 이제 로그인해주세요.',
        );
      } catch (profileError) {
        // 프로필 저장 실패해도 가입은 성공으로 처리 (ReflectOS 패턴)
        debugPrint('프로필 저장 실패 (백그라운드): $profileError');
        return AuthResult(
          success: true,
          message: '회원가입은 완료되었지만 프로필 생성에 실패했습니다. 로그인 후 설정에서 프로필을 완성해주세요.',
        );
      }
    } on AuthException catch (e) {
      // Supabase 에러 메시지 파싱
      final errorMsg = e.message.toLowerCase();
      if (errorMsg.contains('already registered') || 
          errorMsg.contains('already exists') ||
          errorMsg.contains('user already registered')) {
        return AuthResult(
          success: false,
          message: '이미 등록된 이메일입니다.',
        );
      } else if (errorMsg.contains('invalid') && errorMsg.contains('email')) {
        return AuthResult(
          success: false,
          message: '유효하지 않은 이메일 형식입니다.',
        );
      } else {
        return AuthResult(
          success: false,
          message: '회원가입 중 오류가 발생했습니다: ${e.message}',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: '회원가입 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  /// 로그인
  /// 
  /// ReflectOS 패턴:
  /// - 로그인 성공 시 세션 자동 저장
  /// - 성공 시 true 반환하여 HomeScreen 진입 허용
  static Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Supabase Auth로 로그인
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult(
          success: false,
          message: '로그인에 실패했습니다.',
        );
      }

      // 세션은 Supabase가 자동으로 관리
      return AuthResult(
        success: true,
        message: '환영합니다, ${response.user!.email}님!',
        user: response.user,
      );
    } on AuthException catch (e) {
      final errorMsg = e.message.toLowerCase();
      if (errorMsg.contains('invalid') && errorMsg.contains('password')) {
        return AuthResult(
          success: false,
          message: '이메일 또는 비밀번호가 올바르지 않습니다.',
        );
      } else if (errorMsg.contains('email not confirmed')) {
        return AuthResult(
          success: false,
          message: '이메일 인증이 필요합니다.',
        );
      } else {
        return AuthResult(
          success: false,
          message: '로그인 중 오류가 발생했습니다: ${e.message}',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: '로그인 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  /// 계정 삭제 (Apple 가이드라인 5.1.1v 준수)
  ///
  /// 1. profiles 테이블에서 사용자 데이터 삭제
  /// 2. Supabase RPC로 auth.users에서 계정 삭제
  /// 3. 로컬 세션 종료
  static Future<AuthResult> deleteAccount() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return AuthResult(
          success: false,
          message: '로그인된 사용자가 없습니다.',
        );
      }

      // 1. profiles 테이블 데이터 삭제
      try {
        await _client.from('profiles').delete().eq('id', userId);
      } catch (e) {
        debugPrint('profiles 삭제 실패 (계속 진행): $e');
      }

      // 2. Supabase RPC로 계정 삭제 (auth.users)
      await _client.rpc('delete_user');

      // 3. 로컬 세션 종료
      await _client.auth.signOut();

      return AuthResult(
        success: true,
        message: '계정이 성공적으로 삭제되었습니다.',
      );
    } catch (e) {
      debugPrint('계정 삭제 오류: $e');
      return AuthResult(
        success: false,
        message: '계정 삭제 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  /// 로그아웃
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// 현재 로그인된 사용자 정보 반환
  static User? get currentUser {
    return _client.auth.currentUser;
  }

  /// 로그인 상태 확인
  static bool get isAuthenticated {
    return _client.auth.currentUser != null;
  }
}

/// 인증 결과 모델
class AuthResult {
  final bool success;
  final String message;
  final User? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}
