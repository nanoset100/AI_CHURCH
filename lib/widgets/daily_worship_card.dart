import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';

/// 오늘의 예배 카드
class DailyWorshipCard extends StatelessWidget {
  const DailyWorshipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    
    // TODO: 실제 데이터는 Provider나 상태 관리로 가져오기
    const worshipTitle = '새벽 기도의 능력';
    const pastorName = '김목사';
    const bibleVerse = '마태복음 6:5-15';
    const duration = '15분';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아이콘 영역
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '🌅',
                style: TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 예배',
                  style: notoSansKr.copyWith(
                    fontSize: 12,
                    color: AppTheme.textColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"$worshipTitle"',
                  style: notoSansKr.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$pastorName | $bibleVerse',
                  style: notoSansKr.copyWith(
                    fontSize: 12,
                    color: AppTheme.textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // 재생 버튼
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  duration,
                  style: notoSansKr.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
