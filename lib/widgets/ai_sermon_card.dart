import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/providers/auth_provider.dart';
import 'package:ai_canaan_church/screens/auth/login_screen.dart';
import 'package:ai_canaan_church/screens/ai_sermon_dialog.dart';

/// AI 설교 만들기 카드 - 핵심 기능 (시각적으로 강조)
class AiSermonCard extends StatelessWidget {
  const AiSermonCard({super.key});

  void _showLoginRequiredDialog(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('로그인 필요', style: notoSansKr.copyWith(fontWeight: FontWeight.bold)),
        content: Text('AI 맞춤 설교 만들기는 로그인이 필요한 기능입니다. 로그인하시겠습니까?', style: notoSansKr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('나중에', style: notoSansKr.copyWith(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 게스트 모드 해제 및 로그인 화면으로 이동
              Provider.of<AuthProvider>(context, listen: false).setGuestMode(false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7F7FD5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('로그인하기', style: notoSansKr.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    
    return GestureDetector(
      onTap: () {
        final authProv = Provider.of<AuthProvider>(context, listen: false);
        
        if (authProv.currentUser == null) {
          _showLoginRequiredDialog(context);
          return;
        }

        // AI 설교 생성 다이얼로그 열기
        showDialog(
          context: context,
          builder: (_) => const AiSermonDialog(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // 보라색/블루 그라데이션으로 더 프리미엄한 느낌
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7F7FD5), // 소프트 퍼플
              Color(0xFF86A8E7), // 소프트 블루
              Color(0xFF91EAE4), // 민트 블루
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          // 그림자로 입체감 부여
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F7FD5).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // 아이콘 영역 - 더 세련된 디자인
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.amber[200],
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI 맞춤 설교 만들기',
                    style: notoSansKr.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '주제에 맞는 말씀과 설교를 받아보세요',
                    style: notoSansKr.copyWith(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // 화살표 아이콘
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
