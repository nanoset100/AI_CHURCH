import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_canaan_church/models/sermon.dart';

/// 실제 Supabase Edge Functions을 사용하여 설교를 생성하는 서비스
class AiService {
  /// AI 설교 생성 고도화
  static Future<Sermon> generateSermon({
    required String topic,
    String? situation,
    required String length,
    String? tone,
    String? keyword,
  }) async {

    try {
      // ✅ 1단계: 로그인 여부 확인
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('로그인이 필요합니다. 다시 로그인해 주세요.');
      }

      // ✅ 2단계: JWT 토큰 갱신 (만료 방지)
      try {
        await Supabase.instance.client.auth.refreshSession();
        debugPrint('✅ JWT 토큰 갱신 성공');
      } catch (refreshError) {
        debugPrint('⚠️ 토큰 갱신 실패 (기존 세션으로 재시도): $refreshError');
        // 갱신 실패해도 기존 세션으로 시도 (완전히 만료된 경우에만 401 발생)
      }

      // ✅ 3단계: Edge Function 호출
      final response = await Supabase.instance.client.functions.invoke(
        'generate-sermon',
        body: {
          'topic': topic,
          'situation': situation,
          'length': length,
          'tone': tone,
          'keyword': keyword,
        },
      );

      if (response.status == 200) {
        final sermonData = response.data;

        // 응답이 Map 형태인지 확인 (파싱 오류 방지)
        if (sermonData is! Map) {
          throw Exception('서버 응답 형식 오류: ${sermonData.runtimeType}');
        }

        // ✅ 서버 측 에러 응답 처리
        if (sermonData.containsKey('error')) {
          throw Exception(sermonData['error']?.toString() ?? '서버 오류가 발생했습니다.');
        }

        final title = sermonData['title']?.toString() ?? topic;
        final verse = sermonData['verse']?.toString() ?? '';
        final content = sermonData['content']?.toString() ?? '';

        return Sermon(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '[$topic] $title',
          verse: verse.split(' - ')[0],
          content: content,
          userPrompt: keyword ?? '',
          topic: topic,
          situation: situation,
          length: length,
          tone: tone,
          keyword: keyword,
          createdAt: DateTime.now(),
        );
      } else if (response.status == 401) {
        // ✅ 401 전용 처리: 세션 만료 안내
        throw Exception('로그인 세션이 만료되었습니다. 앱을 재시작하거나 다시 로그인해 주세요.');
      } else if (response.status == 429) {
        // ✅ 429 처리: 사용 한도 초과
        throw Exception('오늘 설교 생성 한도(5회)를 초과했습니다. 내일 다시 시도해 주세요.');
      } else {
        throw Exception('설교 생성 오류: ${response.status} - ${response.data}');
      }
    } on FunctionException catch (e) {
      // ✅ FunctionException 전용 처리 (401 포함)
      debugPrint('FunctionException: status=${e.status}, details=${e.details}');
      if (e.status == 401) {
        throw Exception('로그인 세션이 만료되었습니다. 앱을 재시작하거나 다시 로그인해 주세요.');
      }
      throw Exception('설교 생성 중 오류가 발생했습니다: ${e.details}');
    } catch (e) {
      throw Exception('설교 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 제안 키워드 목록 반환
  static List<String> getSuggestedKeywords() {
    return [
      '육아 스트레스',
      '인간관계',
      '불안과 걱정',
      '감사 훈련',
    ];
  }
}
