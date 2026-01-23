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
          // 포인트 컬러 배경으로 강조
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              AppTheme.primaryColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          // 그림자로 강조 효과
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 아이콘 영역
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '✨',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    '🎙️',
                    style: TextStyle(fontSize: 20),
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
                    '나만의 AI 설교 만들기',
                    style: notoSansKr.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '내 고민에 딱 맞는 맞춤 설교를 받아보세요',
                    style: notoSansKr.copyWith(
                      fontSize: 14,
                      color: AppTheme.textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // 화살표 아이콘
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
