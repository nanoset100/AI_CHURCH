import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:ai_canaan_church/models/sermon.dart';
import 'package:ai_canaan_church/services/ai_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 설교 상태 관리 Provider
class SermonProvider extends ChangeNotifier {
  final List<Sermon> _savedSermons = [];
  bool _isGenerating = false;
  Sermon? _currentSermon;
  String? _errorMessage;

  List<Sermon> get savedSermons => List.unmodifiable(_savedSermons);
  bool get isGenerating => _isGenerating;
  Sermon? get currentSermon => _currentSermon;
  String? get errorMessage => _errorMessage;
  int get sermonCount => _savedSermons.length;

  /// AI 설교 생성
  Future<Sermon?> generateSermon(String userPrompt) async {
    _isGenerating = true;
    _errorMessage = null;
    _currentSermon = null;
    notifyListeners();

    try {
      // AI 서비스를 통해 설교 생성 (3-5초 딜레이)
      final sermon = await AiService.generateSermon(
        userPrompt: userPrompt,
        delaySeconds: Random().nextInt(3) + 3, // 3-5초 랜덤
      );

      _currentSermon = sermon;
      _isGenerating = false;
      notifyListeners();

      return sermon;
    } catch (e) {
      _errorMessage = '설교 생성 중 오류가 발생했습니다: ${e.toString()}';
      _isGenerating = false;
      notifyListeners();
      return null;
    }
  }

  /// 설교 저장
  Future<bool> saveSermon(Sermon sermon) async {
    try {
      // Supabase에 저장 시도
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        try {
          await Supabase.instance.client.from('saved_sermons').insert({
            'user_id': userId,
            'title': sermon.title,
            'verse': sermon.verse,
            'content': sermon.content,
            'user_prompt': sermon.userPrompt,
            'created_at': sermon.createdAt.toIso8601String(),
          });
        } catch (e) {
          debugPrint('Supabase 저장 실패, 로컬 저장으로 대체: $e');
        }
      }

      // 로컬에도 저장 (Supabase 실패 시 대비)
      _savedSermons.insert(0, sermon);
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = '설교 저장 중 오류가 발생했습니다: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// 설교 삭제
  Future<bool> deleteSermon(String sermonId) async {
    try {
      // Supabase에서 삭제 시도
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        try {
          await Supabase.instance.client
              .from('saved_sermons')
              .delete()
              .eq('id', sermonId)
              .eq('user_id', userId);
        } catch (e) {
          debugPrint('Supabase 삭제 실패, 로컬 삭제로 대체: $e');
        }
      }

      // 로컬에서도 삭제
      _savedSermons.removeWhere((s) => s.id == sermonId);
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = '설교 삭제 중 오류가 발생했습니다: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// 저장된 설교 로드 (Supabase에서)
  Future<void> loadSavedSermons() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        return;
      }

      final response = await Supabase.instance.client
          .from('saved_sermons')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _savedSermons.clear();
      for (final item in response) {
        _savedSermons.add(Sermon(
          id: item['id'].toString(),
          title: item['title'] as String,
          verse: item['verse'] as String,
          content: item['content'] as String,
          userPrompt: item['user_prompt'] as String,
          createdAt: DateTime.parse(item['created_at'] as String),
        ));
      }

      notifyListeners();
    } catch (e) {
      debugPrint('저장된 설교 로드 실패: $e');
      // 로컬 저장소에서 로드 시도 (추후 구현)
    }
  }

  /// 현재 설교 초기화
  void clearCurrentSermon() {
    _currentSermon = null;
    _errorMessage = null;
    notifyListeners();
  }
}
