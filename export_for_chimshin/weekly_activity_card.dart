import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/providers/activity_provider.dart';

/// 이번 주 활동 카드 (통계)
class WeeklyActivityCard extends StatelessWidget {
  const WeeklyActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        final worshipDays = provider.worshipDaysThisWeek;
        final bibleDays = provider.bibleDaysThisWeek;
        final streakDays = provider.currentStreak;
        
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
              Text(
                '이번 주 활동',
                style: notoSansKr.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              
              if (provider.isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                ))
              else
                // 통계 영역
                Row(
                  children: [
                    // 예배 통계
                    Expanded(
                      child: _buildStatItem(
                        notoSansKr: notoSansKr,
                        icon: '🙏',
                        value: '$worshipDays일',
                        label: '예배',
                        iconColor: Colors.orange.shade200,
                      ),
                    ),
                    
                    // 구분선
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.grey.shade200,
                    ),
                    
                    // 성경 통계
                    Expanded(
                      child: _buildStatItem(
                        notoSansKr: notoSansKr,
                        icon: '📖',
                        value: '$bibleDays일',
                        label: '성경',
                        iconColor: Colors.blue.shade200,
                      ),
                    ),
                    
                    // 구분선
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.grey.shade200,
                    ),
                    
                    // 연속 통계
                    Expanded(
                      child: _buildStatItem(
                        notoSansKr: notoSansKr,
                        icon: '🔥',
                        value: '$streakDays일',
                        label: '연속',
                        iconColor: Colors.red.shade200,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatItem({
    required TextStyle notoSansKr,
    required String icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: notoSansKr.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: notoSansKr.copyWith(
            fontSize: 12,
            color: AppTheme.textColor.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
