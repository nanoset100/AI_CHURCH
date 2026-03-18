import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  int _worshipDaysThisWeek = 0;
  int get worshipDaysThisWeek => _worshipDaysThisWeek;

  int _bibleDaysThisWeek = 0;
  int get bibleDaysThisWeek => _bibleDaysThisWeek;

  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> logWorship(String sermonTitle) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _supabase.from('worship_logs').insert({
        'user_id': userId,
        'worship_id': sermonTitle,
      });
      await fetchActivityStats(); // 업데이트
    } catch (e) {
      debugPrint('Error logging worship: $e');
    }
  }

  Future<void> logBibleReading(String bookName, int chapter) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      // 오늘 이미 읽은 기록이 있는지 확인 (선택 사항)
      // 예배와 달리 성경은 하루 1번, 아니 다중 기록도 상관은 없음.
      await _supabase.from('bible_reading_logs').insert({
        'user_id': userId,
        'book': bookName,
        'chapter': chapter,
      });
      await fetchActivityStats(); // 업데이트
    } catch (e) {
      debugPrint('Error logging bible reading: $e');
    }
  }

  Future<void> fetchActivityStats() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final now = DateTime.now();
      // 이번 주 월요일 0시 계산
      final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
      
      // 예배 활동 내역 가져오기
      final worshipResponse = await _supabase
          .from('worship_logs')
          .select('created_at')
          .eq('user_id', userId)
          .gte('created_at', monday.toIso8601String());

      // 성경 읽기 내역 가져오기
      final bibleResponse = await _supabase
          .from('bible_reading_logs')
          .select('created_at')
          .eq('user_id', userId)
          .gte('created_at', monday.toIso8601String());

      // 이번주 일수 계산 (중복 날짜 제거)
      final worshipDatesThisWeek = (worshipResponse as List)
          .map((row) => DateTime.parse(row['created_at'] as String).toLocal())
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet();

      final bibleDatesThisWeek = (bibleResponse as List)
          .map((row) => DateTime.parse(row['created_at'] as String).toLocal())
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet();

      _worshipDaysThisWeek = worshipDatesThisWeek.length;
      _bibleDaysThisWeek = bibleDatesThisWeek.length;

      // 전체 스트릭 계산 (최근 활동을 기반으로 전체 테이블 조회, limit 100 등)
      // 단순히 지난 30일 간의 데이터로 스트릭을 계산
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      final recentWorship = await _supabase
          .from('worship_logs')
          .select('created_at')
          .eq('user_id', userId)
          .gte('created_at', thirtyDaysAgo.toIso8601String())
          .order('created_at', ascending: false);

      final recentBible = await _supabase
          .from('bible_reading_logs')
          .select('created_at')
          .eq('user_id', userId)
          .gte('created_at', thirtyDaysAgo.toIso8601String())
          .order('created_at', ascending: false);

      Set<DateTime> allActiveDates = {};
      for (var row in (recentWorship as List)) {
        final d = DateTime.parse(row['created_at'] as String).toLocal();
        allActiveDates.add(DateTime(d.year, d.month, d.day));
      }
      for (var row in (recentBible as List)) {
        final d = DateTime.parse(row['created_at'] as String).toLocal();
        allActiveDates.add(DateTime(d.year, d.month, d.day));
      }

      _currentStreak = _calculateStreak(allActiveDates.toList());
      
    } catch (e) {
      debugPrint('Error fetching activity stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int _calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    
    // 내림차순 정렬
    dates.sort((a, b) => b.compareTo(a));
    
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    int streak = 0;
    DateTime dateToCheck = todayDate;

    // 만약 오늘 활동이 없고 어제부터 활동이 시작되었다면 체크 시작일을 어제로 변경
    if (!dates.contains(todayDate) && dates.contains(yesterdayDate)) {
      dateToCheck = yesterdayDate;
    } else if (!dates.contains(todayDate) && !dates.contains(yesterdayDate)) {
      // 어제와 오늘 모두 활동이 없으면 연속 0일
      return 0;
    }

    for (int i = 0; i < dates.length; i++) {
      if (dates.contains(dateToCheck)) {
        streak++;
        dateToCheck = dateToCheck.subtract(const Duration(days: 1));
      } else {
        break; // 연속성 끊김
      }
    }

    return streak;
  }
}
