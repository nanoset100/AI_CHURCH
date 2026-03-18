import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/providers/auth_provider.dart';

/// 인사말 섹션
class GreetingSection extends StatefulWidget {
  const GreetingSection({super.key});

  @override
  State<GreetingSection> createState() => _GreetingSectionState();
}

class _GreetingSectionState extends State<GreetingSection> {
  late String _greetingTitle;
  late String _greetingSubtitle;

  @override
  void initState() {
    super.initState();
    _updateGreeting();
  }

  void _updateGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    // 05:00 ~ 11:59: 아침
    if (hour >= 5 && hour < 12) {
      _greetingTitle = '좋은 아침입니다';
      _greetingSubtitle = '오늘 하루도 주님의 은혜가 가득하길 바랍니다';
    } 
    // 12:00 ~ 16:59: 오후
    else if (hour >= 12 && hour < 17) {
      _greetingTitle = '평안한 오후 되세요';
      _greetingSubtitle = '바쁜 일상 속에서도 주님을 기억하는 시간입니다';
    } 
    // 17:00 ~ 21:59: 저녁
    else if (hour >= 17 && hour < 22) {
      _greetingTitle = '은혜로운 저녁입니다';
      _greetingSubtitle = '하루를 돌아보며 주님께 감사하는 시간입니다';
    } 
    // 22:00 ~ 04:59: 밤
    else {
      _greetingTitle = '깊은 밤, 주님과 함께 쉬세요';
      _greetingSubtitle = '평안한 안식의 시간이 되길 기도합니다';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    
    // AuthProvider에서 사용자 이름 가져오기
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.displayName ?? '성도';
    final user = authProvider.currentUser;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '$_greetingTitle, $userName님',
                  style: notoSansKr.copyWith(
                    fontSize: 20, // 22에서 20으로 크기 축소
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 게스트/사용자 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: user == null ? Colors.orange : AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user == null ? '게스트' : '성도',
                      style: notoSansKr.copyWith(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _greetingSubtitle,
            style: notoSansKr.copyWith(
              fontSize: 14,
              color: AppTheme.textColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
