import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();

    // 임시 알림 데이터
    final notifications = [
      {
        'title': '새로운 기능 추가: 오디오 보관함',
        'body': '이제 생성된 설교를 데이터 걱정 없이 "보관된 설교"함에서 오프라인으로 들을 수 있습니다!',
        'date': '오늘',
        'isRead': false,
      },
      {
        'title': '새로운 설교 테마 업데이트',
        'body': '[관계] 주제 및 [용서]에 특화된 새로운 설교 톤과 성경 구절이 추가되었습니다.',
        'date': '어제',
        'isRead': true,
      },
      {
        'title': 'AI 가나안교회 출시 안내',
        'body': '환영합니다! 어디서나 함께하는 당신만의 영적 안식처, 가나안교회와 주님과 동행하세요.',
        'date': '3일 전',
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          '알림',
          style: notoSansKr.copyWith(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final isRead = notif['isRead'] as bool;

          return Container(
            color: isRead ? Colors.transparent : AppTheme.primaryColor.withValues(alpha: 0.05),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isRead ? Colors.grey.shade200 : AppTheme.secondaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications,
                  color: isRead ? Colors.grey.shade500 : AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              title: Text(
                notif['title'] as String,
                style: notoSansKr.copyWith(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  fontSize: 15,
                  color: AppTheme.textColor,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif['body'] as String,
                      style: notoSansKr.copyWith(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notif['date'] as String,
                      style: notoSansKr.copyWith(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
