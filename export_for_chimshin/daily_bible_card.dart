import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/providers/bible_provider.dart';
import 'package:ai_canaan_church/providers/activity_provider.dart';
import 'package:ai_canaan_church/screens/bible_reading_screen.dart';

/// 오늘의 성경 카드 (진행바 포함)
class DailyBibleCard extends StatelessWidget {
  const DailyBibleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    
    return Consumer<BibleProvider>(
      builder: (context, bibleProvider, child) {
        final dailyVerse = bibleProvider.dailyVerse;
        final isLoading = bibleProvider.isLoading;

        String bibleTitle = '마태복음 1장';
        String verseText = '성경 말씀을 불러오는 중...';
        
        if (!isLoading && dailyVerse != null) {
          bibleTitle = '${dailyVerse.bookName} ${dailyVerse.chapter}장';
          verseText = dailyVerse.verseText;
        } else if (!isLoading && bibleProvider.errorMessage != null) {
          verseText = bibleProvider.errorMessage!;
        }

        return InkWell(
          onTap: () {
            if (dailyVerse != null) {
              // 화면 이동 전 활동 기록 남기기
              Provider.of<ActivityProvider>(context, listen: false).logBibleReading(
                dailyVerse.bookName,
                dailyVerse.chapter,
              );
              
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BibleReadingScreen(
                    initialBookName: dailyVerse.bookName,
                    initialChapter: dailyVerse.chapter,
                  ),
                ),
              );
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
                      '📖',
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
                        '오늘의 성경',
                        style: notoSansKr.copyWith(
                          fontSize: 12,
                          color: AppTheme.textColor.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bibleTitle,
                        style: notoSansKr.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        verseText,
                        style: notoSansKr.copyWith(
                          fontSize: 12,
                          color: AppTheme.textColor.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // 읽기 버튼
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '읽기',
                    style: notoSansKr.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
