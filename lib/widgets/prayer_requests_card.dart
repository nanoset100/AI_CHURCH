import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';

/// 나의 기도제목 카드
class PrayerRequestsCard extends StatelessWidget {
  const PrayerRequestsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    
    // TODO: 실제 데이터는 Provider나 상태 관리로 가져오기
    const prayerCount = 5;
    final prayerItems = [
      {'category': '가족', 'text': '아버지 건강 회복', 'answered': false},
      {'category': '직장', 'text': '프로젝트 성공', 'answered': false},
      {'category': '영적', 'text': '매일 말씀 묵상', 'answered': true},
    ];
    
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '기도하기',
                  style: notoSansKr.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 기도제목 리스트
          ...prayerItems.map((item) {
            final category = item['category'] as String;
            final text = item['text'] as String;
            final answered = item['answered'] as bool;
            
            Color categoryColor;
            switch (category) {
              case '가족':
                categoryColor = Colors.orange.shade300;
                break;
              case '직장':
                categoryColor = Colors.blue.shade300;
                break;
              case '영적':
                categoryColor = Colors.purple.shade300;
                break;
              default:
                categoryColor = Colors.grey.shade300;
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
  }
}
