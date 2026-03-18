import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_canaan_church/models/bible_verse.dart';

class BibleProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  List<BibleVerse> _currentChapter = [];
  List<BibleVerse> get currentChapter => _currentChapter;

  BibleVerse? _dailyVerse;
  BibleVerse? get dailyVerse => _dailyVerse;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 매일 오늘의 말씀 카드용 프리뷰 구절 
  Future<void> fetchDailyPreview() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 우선 마태복음 1장 전체를 로드해둠 (카드 클릭시 빠르게 보여주기 위함)
      await fetchChapter('마태복음', 1);

      if (_currentChapter.isNotEmpty) {
        // 프리뷰 구절은 1절로 설정
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
