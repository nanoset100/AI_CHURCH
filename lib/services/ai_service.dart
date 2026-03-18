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

        return Sermon(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '[$topic] ${sermonData['title']}',
          verse: sermonData['verse'].toString().split(' - ')[0], // 구절의 앞부분(성경 장절)만 추출
          content: sermonData['content'],
          userPrompt: keyword ?? '',
          topic: topic,
          situation: situation,
          length: length,
          tone: tone,
          keyword: keyword,
          createdAt: DateTime.now(),
        );
      } else {
        throw Exception('설교 생성 오류: ${response.status} - ${response.data}');
      }
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
