import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/providers/activity_provider.dart';

/// 오늘의 성경 카드 (왕초보 성경통독 딥링크 전용)
class DailyBibleCard extends StatelessWidget {
  const DailyBibleCard({super.key});

  static const List<Map<String, dynamic>> _ntBooks = [
    {'name': '마태복음', 'chapters': 28},
    {'name': '마가복음', 'chapters': 16},
    {'name': '누가복음', 'chapters': 24},
    {'name': '요한복음', 'chapters': 21},
    {'name': '사도행전', 'chapters': 28},
    {'name': '로마서', 'chapters': 16},
    {'name': '고린도전서', 'chapters': 16},
    {'name': '고린도후서', 'chapters': 13},
    {'name': '갈라디아서', 'chapters': 6},
    {'name': '에베소서', 'chapters': 6},
    {'name': '빌립보서', 'chapters': 4},
    {'name': '골로새서', 'chapters': 4},
    {'name': '데살로니가전서', 'chapters': 5},
    {'name': '데살로니가후서', 'chapters': 3},
    {'name': '디모데전서', 'chapters': 6},
    {'name': '디모데후서', 'chapters': 4},
    {'name': '디도서', 'chapters': 3},
    {'name': '빌레몬서', 'chapters': 1},
    {'name': '히브리서', 'chapters': 13},
    {'name': '야고보서', 'chapters': 5},
    {'name': '베드로전서', 'chapters': 5},
    {'name': '베드로후서', 'chapters': 3},
    {'name': '요한일서', 'chapters': 5},
    {'name': '요한이서', 'chapters': 1},
    {'name': '요한삼서', 'chapters': 1},
    {'name': '유다서', 'chapters': 1},
    {'name': '요한계시록', 'chapters': 22},
  ];

  Future<void> _openBibleApp() async {
    final appUri = Uri.parse('android-app://com.bible_app.king_beginner_bible');
    final storeUri = Uri.parse('https://play.google.com/store/apps/details?id=com.bible_app.king_beginner_bible');
    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri);
      } else {
        await launchUrl(storeUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      await launchUrl(storeUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    
    // 오늘 날짜 기반 챕터 계산
    final now = DateTime.now();
    final dayOfYear = int.parse(DateFormat("D").format(now));
    final targetIndex = (dayOfYear - 1) % 260; 

    String bookName = '';
    int chapter = 1;

    int accumulated = 0;
    for (var book in _ntBooks) {
      if (targetIndex < accumulated + (book['chapters'] as int)) {
        bookName = book['name'] as String;
        chapter = targetIndex - accumulated + 1;
        break;
      }
      accumulated += book['chapters'] as int;
    }

    final progressPercent = ((targetIndex + 1) / 260 * 100).toInt();
    final dateString = DateFormat('M월 d일').format(now);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5), // 황금빛 따뜻한 톤
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3E5AB), width: 1.5),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('📖', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    '$bookName $chapter장',
                    style: notoSansKr.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5D4037),
                    ),
                  ),
                ],
              ),
              Text(
                dateString,
                style: notoSansKr.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8D6E63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 진행률 바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (targetIndex + 1) / 260,
              backgroundColor: const Color(0xFFEFEBE0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFBCAAA4)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '신약 연간 읽기 $progressPercent% 완료',
            style: notoSansKr.copyWith(
              fontSize: 12,
              color: const Color(0xFF8D6E63),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          
          // 읽기 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // 앱 활동 기록 남기기 (원하는 경우 유지)
                Provider.of<ActivityProvider>(context, listen: false).logBibleReading(bookName, chapter);
                // 외부 앱 열기
                _openBibleApp();
              },
              icon: const Icon(Icons.menu_book, color: Colors.white, size: 20),
              label: Text(
                '왕초보 성경통독으로 읽기',
                style: notoSansKr.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC08A3E), // 골드 브라운 컬러
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
