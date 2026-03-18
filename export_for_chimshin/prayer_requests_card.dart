import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/providers/prayer_provider.dart';
import 'package:ai_canaan_church/screens/prayer_requests_screen.dart';

/// 나의 기도제목 카드
class PrayerRequestsCard extends StatelessWidget {
  const PrayerRequestsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    
    return Consumer<PrayerProvider>(
      builder: (context, provider, child) {
        final allPrayers = provider.prayerRequests;
        final prayerCount = allPrayers.length;
        
        // 홈 화면에서는 최대 3개까지만 표시 (미응답 우선, 최신순 필터링은 Provider에서 이미 최신순으로 가져옴)
        // 응답되지 않은 기도를 먼저 보여주도록 정렬
        final sortedPrayers = List.of(allPrayers)..sort((a, b) {
          if (a.isAnswered == b.isAnswered) return 0;
          return a.isAnswered ? 1 : -1;
        });
        
        final displayPrayers = sortedPrayers.take(3).toList();

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        '🙏',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '나의 기도제목',
                          style: notoSansKr.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textColor.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$prayerCount개의 기도제목',
                          style: notoSansKr.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PrayerRequestsScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '관리하기',
                        style: notoSansKr.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (provider.isLoading && displayPrayers.isEmpty)
                const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
              else if (displayPrayers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      '작성된 기도제목이 없습니다.\n관리하기 버튼을 눌러 기도제목을 추가해 보세요.',
                      style: notoSansKr.copyWith(color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                // 기도제목 리스트
                ...displayPrayers.map((prayer) {
                  final category = prayer.category;
                  final text = prayer.title;
                  final answered = prayer.isAnswered;
                  
                  Color categoryColor;
                  switch (category) {
                    case '가족':
                      categoryColor = Colors.orange.shade300;
                      break;
                    case '직장':
                      categoryColor = Colors.blue.shade300;
                      break;
                    case '건강':
                      categoryColor = Colors.red.shade300;
                      break;
                    case '교회':
                      categoryColor = Colors.green.shade300;
                      break;
                    case '개인':
                      categoryColor = Colors.purple.shade300;
                      break;
                    default:
                      categoryColor = Colors.grey.shade400;
                  }
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: answered ? AppTheme.secondaryColor.withValues(alpha: 0.3) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: answered ? Colors.green.shade200 : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: notoSansKr.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            text,
                            style: notoSansKr.copyWith(
                              fontSize: 14,
                              color: AppTheme.textColor,
                              decoration: answered ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (answered)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '응답',
                              style: notoSansKr.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
