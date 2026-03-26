import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/services/auth_service.dart';
import 'package:ai_canaan_church/providers/auth_provider.dart';
import 'package:ai_canaan_church/screens/profile_screen.dart';
import 'package:ai_canaan_church/screens/notification_screen.dart';
import 'package:ai_canaan_church/screens/privacy_policy_screen.dart';
import 'package:ai_canaan_church/screens/auth/login_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _handleDeleteAccount(BuildContext context) async {
    // 1단계 확인
    final step1 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('계정 삭제', style: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text(
          '계정을 삭제하면 모든 데이터(설교, 기도제목 등)가 영구적으로 삭제됩니다.\n\n정말 삭제하시겠습니까?',
          style: GoogleFonts.notoSansKr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('취소', style: GoogleFonts.notoSansKr(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('계속', style: GoogleFonts.notoSansKr(color: Colors.red)),
          ),
        ],
      ),
    );

    if (step1 != true || !context.mounted) return;

    // 2단계 최종 확인
    final step2 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('최종 확인', style: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text(
          '이 작업은 되돌릴 수 없습니다.\n계정을 영구 삭제합니다.',
          style: GoogleFonts.notoSansKr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('취소', style: GoogleFonts.notoSansKr(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('계정 삭제', style: GoogleFonts.notoSansKr(color: Colors.white)),
          ),
        ],
      ),
    );

    if (step2 != true || !context.mounted) return;

    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await AuthService.deleteAccount();

    if (!context.mounted) return;
    Navigator.of(context).pop(); // 로딩 닫기

    if (result.success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message, style: GoogleFonts.notoSansKr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('로그아웃', style: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold)),
        content: Text('정말 로그아웃 하시겠습니까?', style: GoogleFonts.notoSansKr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('취소', style: GoogleFonts.notoSansKr(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('로그아웃', style: GoogleFonts.notoSansKr(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await AuthService.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    final authProv = Provider.of<AuthProvider>(context);
    final user = authProv.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          '더보기',
          style: notoSansKr.copyWith(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // 프로필 섹션 (로그인 여부에 따라 다름)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: user == null
                ? _buildGuestProfile(context, notoSansKr, authProv)
                : _buildUserProfile(context, notoSansKr, user),
          ),
          const SizedBox(height: 12),

          // 메뉴 섹션 1 (공통 메뉴)
          Container(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.campaign_outlined, color: AppTheme.textColor),
                  title: Text('공지사항', style: notoSansKr),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationScreen()),
                    );
                  },
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppTheme.textColor),
                  title: Text('앱 정보', style: notoSansKr),
                  trailing: Text('v1.0.0', style: notoSansKr.copyWith(color: Colors.grey, fontSize: 12)),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'AI 가나안교회',
                      applicationVersion: 'v1.0.0',
                      applicationLegalese: '개발: 나너셋\n문의: nanoset@naver.com',
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          '어디서나 함께하는 당신만의 영적 안식처',
                          style: GoogleFonts.notoSansKr(fontSize: 13),
                        ),
                      ],
                    );
                  },
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.textColor),
                  title: Text('개인정보처리방침', style: notoSansKr),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 메뉴 섹션 2 (계정 관련 버튼)
          if (user != null)
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text('로그아웃', style: notoSansKr.copyWith(color: Colors.red)),
                    onTap: () => _handleLogout(context),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                    title: Text('계정 삭제', style: notoSansKr.copyWith(color: Colors.red)),
                    subtitle: Text('모든 데이터가 영구 삭제됩니다', style: notoSansKr.copyWith(color: Colors.grey, fontSize: 12)),
                    onTap: () => _handleDeleteAccount(context),
                  ),
                ],
              ),
            )
          else
            Container(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.login, color: AppTheme.primaryColor),
                title: Text('로그인 및 회원가입', style: notoSansKr.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
                onTap: () {
                  authProv.setGuestMode(false);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context, TextStyle notoSansKr, AuthProvider authProv) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person_outline, size: 36, color: Colors.grey),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '게스트님',
                style: notoSansKr.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '로그인하여 더 많은 기능을 이용해보세요',
                style: notoSansKr.copyWith(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfile(BuildContext context, TextStyle notoSansKr, dynamic user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: const Icon(Icons.person, size: 36, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.userMetadata?['display_name'] ?? '성도님',
                style: notoSansKr.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                user.email ?? '',
                style: notoSansKr.copyWith(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Text('프로필 수정', style: notoSansKr.copyWith(color: AppTheme.textColor, fontSize: 12)),
        ),
      ],
    );
  }
  }
}
