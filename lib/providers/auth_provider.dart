import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  String? _displayName;
  String? get displayName => _displayName;
  
  User? get currentUser => _supabase.auth.currentUser;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 게스트 모드 (비로그인 둘러보기) 상태
  bool _isGuestMode = false;
  bool get isGuestMode => _isGuestMode;

  AuthProvider() {
    _initDisplayName();
    // 인증 상태 변경 리스너 등록
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn || data.event == AuthChangeEvent.tokenRefreshed) {
        _isGuestMode = false; // 로그인 시 게스트 모드 해제
        _initDisplayName();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _displayName = null;
        _isGuestMode = false; // 로그아웃 시 게스트 모드 초기화
        notifyListeners();
      }
    });
  }

  /// 게스트 모드 설정
  void setGuestMode(bool value) {
    _isGuestMode = value;
    notifyListeners();
  }

  Future<void> _initDisplayName() async {
    final user = currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // 1. profiles 테이블에서 가져오기
      final response = await _supabase
          .from('profiles')
          .select('display_name')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && response['display_name'] != null) {
        _displayName = response['display_name'] as String;
      } else {
        // 2. Metadata에서 가져오기 (백업)
        _displayName = user.userMetadata?['display_name'] ?? user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? '성도';
      }
    } catch (e) {
      debugPrint('Error fetching display name: $e');
      _displayName = user.userMetadata?['display_name'] ?? '성도';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateDisplayName(String newName) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      // 1. Supabase Profiles 테이블 업데이트
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'display_name': newName,
        'email': user.email,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Auth Metadata 업데이트 (앱 재실행 시에도 어느 정도 유지되도록)
      await _supabase.auth.updateUser(UserAttributes(
        data: {'display_name': newName},
      ));

      _displayName = newName;
      return true;
    } catch (e) {
      debugPrint('Error updating display name: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
