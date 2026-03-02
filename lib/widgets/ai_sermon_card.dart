import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/screens/ai_sermon_dialog.dart';

/// AI 설교 만들기 카드 - 핵심 기능 (시각적으로 강조)
class AiSermonCard extends StatelessWidget {
  const AiSermonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    
    return GestureDetector(
      onTap: () {
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
