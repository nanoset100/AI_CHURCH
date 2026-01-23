import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';

/// 인사말 섹션
class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    
    // TODO: 실제 사용자 이름은 Provider나 상태 관리로 가져오기
    const userName = '은혜';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요, $userName님',
            style: notoSansKr.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '오늘도 주님과 함께하는 하루 되세요',
            style: notoSansKr.copyWith(
              fontSize: 14,
              color: AppTheme.textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
