import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:ai_canaan_church/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: authProvider.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.displayName ?? '성도';
    final userEmail = authProvider.currentUser?.email ?? '이메일 정보 없음';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          '마이페이지',
          style: notoSansKr.copyWith(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: authProvider.currentUser == null
          ? _buildGuestUI(context, notoSansKr, authProvider)
          : _buildProfileUI(context, notoSansKr, authProvider, userName, userEmail),
    );
  }

  Widget _buildGuestUI(BuildContext context, TextStyle notoSansKr, AuthProvider authProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, size: 60, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              '로그인이 필요한 서비스입니다',
              style: notoSansKr.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '회원가입 후 나만의 설교 보관함과\n기도제목 관리 기능을 이용해보세요.',
              textAlign: TextAlign.center,
              style: notoSansKr.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                authProvider.setGuestMode(false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                '로그인/회원가입 하기',
                style: notoSansKr.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileUI(BuildContext context, TextStyle notoSansKr, AuthProvider authProvider, String userName, String userEmail) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            
            // 이름 표시 및 수정 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: _isEditing 
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          autofocus: true,
                          style: notoSansKr.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: '이름을 입력하세요',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: authProvider.isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final success = await authProvider.updateDisplayName(_nameController.text);
                          if (!mounted) return;
                          if (success) {
                            setState(() => _isEditing = false);
                            messenger.showSnackBar(
                              const SnackBar(content: Text('이름이 성공적으로 저장되었습니다.')),
                            );
                          }
                        },
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$userName님',
                        style: notoSansKr.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                        onPressed: () {
                          _nameController.text = authProvider.displayName ?? '';
                          setState(() => _isEditing = true);
                        },
                      ),
                    ],
                  ),
            ),
            
            const SizedBox(height: 8),
            Text(
              userEmail,
              style: notoSansKr.copyWith(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await supabase.Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        // 로그아웃 시 인증 리스너가 guestMode를 false로 바꾸므로 AuthWrapper가 리다이렉트함
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '로그아웃',
                      style: notoSansKr.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
