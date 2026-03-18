import 'package:flutter/material.dart';
import 'package:ai_canaan_church/services/auth_service.dart';
import 'package:ai_canaan_church/screens/main_screen.dart';
import 'package:ai_canaan_church/screens/auth/login_screen.dart';

/// 인증 상태에 따라 화면을 자동 분기하는 Wrapper
/// 
/// ReflectOS 패턴:
/// - 로그인되어 있으면 MainScreen
/// - 로그인 안 되어 있으면 LoginScreen
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // 세션 확인
    final isAuth = AuthService.isAuthenticated;
    
    setState(() {
      _isAuthenticated = isAuth;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // 초기 로딩 화면
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'AI 가나안교회',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 인증 상태에 따라 화면 분기
    if (_isAuthenticated) {
      return const MainScreen();
    } else {
      return const LoginScreen();
    }
  }
}
