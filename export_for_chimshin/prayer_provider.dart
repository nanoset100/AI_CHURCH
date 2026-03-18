import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_canaan_church/models/prayer_request.dart';

class PrayerProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  List<PrayerRequest> _prayerRequests = [];
  List<PrayerRequest> get prayerRequests => _prayerRequests;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 기도제목 불러오기
  Future<void> fetchPrayerRequests() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _errorMessage = '로그인이 필요합니다.';
        return;
      }

      final response = await _supabase
          .from('prayer_requests')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _prayerRequests = (response as List)
          .map((data) => PrayerRequest.fromJson(data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching prayer requests: $e');
      _errorMessage = '기도제목을 불러오는 데 실패했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 기도제목 추가
  Future<bool> addPrayerRequest(String title, String category) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // 1. Supabase에 먼저 저장 (ID 등은 DB가 생성)
      // 이전에 테이블을 생성할 때 컬럼명이 text 였는지 title 이었는지 불확실하므로,
      // 일단 title 컬럼명으로 시도하고 안되면 catch에서 알려주도록 처리할 수도 있지만,
      // 최신 생성 쿼리에 title로 생성하라고 안내했으므로 title 사용. (실패 시 에러로그 출력)
      await _supabase.from('prayer_requests').insert({
        'user_id': userId,
        'title': title,
        'category': category,
        'is_answered': false,
      });

      // 2. 저장 후 목록 다시 불러오기
      await fetchPrayerRequests();
      return true;
    } catch (e) {
      debugPrint('Error adding prayer request: $e');
      return false;
    }
  }

  // 기도 응답 상태 변경 (토글)
  Future<bool> toggleAnsweredStatus(String id, bool currentStatus) async {
    try {
      // 1. 상태 즉시 업데이트 (Optimistic UI) 
      final index = _prayerRequests.indexWhere((p) => p.id == id);
      if (index >= 0) {
         // 불변성을 파괴하지 않고 리스트만 변경하기 위해 새로운 코드로 교체하는게 맞으나
         // 간소화를 위해 fetch로 모두 갱신합니다.
      }

      // 2. DB 업데이트
      await _supabase
          .from('prayer_requests')
          .update({'is_answered': !currentStatus})
          .eq('id', id);

      // 3. 서버 데이터로 동기화
      await fetchPrayerRequests();
      return true;
    } catch (e) {
      debugPrint('Error toggling status: $e');
      return false;
    }
  }

  // 기도제목 삭제
  Future<bool> deletePrayerRequest(String id) async {
    try {
      await _supabase
          .from('prayer_requests')
          .delete()
          .eq('id', id);

      await fetchPrayerRequests();
      return true;
    } catch (e) {
      debugPrint('Error deleting prayer request: $e');
      return false;
    }
  }
}
