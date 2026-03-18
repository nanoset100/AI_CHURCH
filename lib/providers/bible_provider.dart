import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_canaan_church/models/bible_verse.dart';
import 'package:ai_canaan_church/data/bible_data.dart';

class BibleProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<BibleVerse> _currentChapter = [];
  List<BibleVerse> get currentChapter => _currentChapter;

  BibleVerse? _dailyVerse;
  BibleVerse? get dailyVerse => _dailyVerse;

  // 오늘의 성경 책/장 정보 (홈 카드 표시용)
  String _dailyBookName = '';
  int _dailyChapterNumber = 1;
  String get dailyBookName => _dailyBookName;
  int get dailyChapterNumber => _dailyChapterNumber;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// 오늘 날짜 기반으로 (책이름, 장번호) 반환
  /// 신약 260장을 순서대로 순환 (약 9개월 주기)
  /// 오늘 날짜 기반으로 (책이름, 장번호) 반환
  /// 성경 전체 (구약+신약) 총 1189장을 순서대로 순환
  static ({String bookName, int chapter}) getTodaysBibleChapter() {
    // 성경 66권을 평탄화한 (책, 장) 목록 생성
    final allChapters = <({String bookName, int chapter})>[];
    
    // 구약 + 신약 합치기
    final allBooks = [...BibleData.oldTestament, ...BibleData.newTestament];
    
    for (final book in allBooks) {
      final name = book['name'] as String;
      final chapters = book['chapters'] as int;
      for (int c = 1; c <= chapters; c++) {
        allChapters.add((bookName: name, chapter: c));
      }
    }
    // 총 1,189장 (약 3.2년 주기)

    // 오늘 날짜의 epoch 날짜를 인덱스로 사용 (매일 바뀜)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysSinceEpoch = today.difference(DateTime(2024, 1, 1)).inDays; 

    final index = daysSinceEpoch % allChapters.length;
    return allChapters[index];
  }

  // 매일 오늘의 말씀 카드용 프리뷰 구절
  Future<void> fetchDailyPreview() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 오늘 날짜 기반으로 책/장 결정
      final today = getTodaysBibleChapter();
      _dailyBookName = today.bookName;
      _dailyChapterNumber = today.chapter;

      await fetchChapter(today.bookName, today.chapter);

      if (_currentChapter.isNotEmpty) {
        _dailyVerse = _currentChapter.first;
      }
    } catch (e) {
      debugPrint('Error fetching daily preview: $e');
      _errorMessage = '오늘의 성경을 불러오지 못했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 특정 장(Chapter) 전체 절과 소제목 목록 가져오기
  Future<void> fetchChapter(String bookName, int chapter) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      // UI를 깜빡이지 않도록 이전 데이터를 지우지 않고 바로 덮어씀

      final response = await _supabase
          .from('bible_subtitles_rows')
          .select()
          .eq('book_name', bookName)
          .eq('chapter', chapter)
          .order('verse_number', ascending: true);

      _currentChapter = (response as List)
          .map((data) => BibleVerse.fromJson(data))
          .toList();
          
    } catch (e) {
      debugPrint('Error fetching chapter: $e');
      _errorMessage = '성경 말씀을 불러오는 중 오류가 발생했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
