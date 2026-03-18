import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ai_canaan_church/providers/activity_provider.dart';

/// 오늘의 예배 카드
class DailyWorshipCard extends StatelessWidget {
  const DailyWorshipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    
    // MVP용 국내 유명 목사님 설교 유튜브 링크 연동 (예: 이찬수 목사님)
    const worshipTitle = '위기를 기회로 만드는 믿음';
    const pastorName = '이찬수 목사';
    const bibleVerse = '로마서 8:28';
    const duration = '35분';
    final Uri youtubeUrl = Uri.parse('https://www.youtube.com/results?search_query=%EC%9D%B4%EC%B0%AC%EC%88%98+%EB%AA%A9%EC%82%AC+%EC%84%A4%EA%B5%90'); // 검색결과 링크로 임시 대체 (실제 영상 링크로 변경 가능)
    
    return InkWell(
      onTap: () async {
        if (!await launchUrl(youtubeUrl, mode: LaunchMode.externalApplication)) {
          debugPrint('Could not launch $youtubeUrl');
        } else {
          // 영상 실행 성공 시 활동 기록 (Provider 호출 시 context 에러 방지 위해 mounted 체크)
          if (context.mounted) {
            Provider.of<ActivityProvider>(context, listen: false).logWorship(worshipTitle);
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
    ));
  }
}
