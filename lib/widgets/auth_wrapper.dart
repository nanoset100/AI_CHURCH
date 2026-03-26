import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_canaan_church/providers/auth_provider.dart';
import 'package:ai_canaan_church/screens/main_screen.dart';
import 'package:ai_canaan_church/screens/auth/login_screen.dart';

/// 인증 상태에 따라 화면을 자동 분기하는 Wrapper
/// 
/// ReflectOS 패턴:
/// - 로그인되어 있으면 MainScreen
/// - 로그인 안 되어 있으면 LoginScreen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProv, child) {
        return StreamBuilder<AuthState>(
          stream: Supabase.instance.client.auth.onAuthStateChange,
          builder: (context, snapshot) {
            // 초기 로딩 시 또는 연결 시도 중
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingScreen();
            }

            final session = snapshot.data?.session;
            final user = snapshot.data?.user;

            // 1. 세션과 사용자가 모두 유효한 경우 MainScreen 표시
            if (session != null && user != null) {
              return const MainScreen();
            } 
            
            // 2. 세션은 없지만 게스트 모드로 진입한 경우 MainScreen 표시 (둘러보기)
            if (authProv.isGuestMode) {
              return const MainScreen();
            }

            // 3. 그 외의 경우 (초기 진입, 로그아웃 등) LoginScreen 표시
            return const LoginScreen();
          },
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
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
}
