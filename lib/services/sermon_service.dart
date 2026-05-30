import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/public_sermon_model.dart';

class SermonService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'public_sermons';

  // 오늘 앱에서 묵상할 최신 공개 설교
  static Future<PublicSermonModel?> getTodaySermon() async {
    try {
      final now = DateTime.now();
      final snap = await _db
          .collection(_col)
          .where('isPublic', isEqualTo: true)
          .where('broadcastDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('broadcastDate', descending: true)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty
          ? PublicSermonModel.fromFirestore(snap.docs.first)
          : null;
    } catch (e) {
      final recent = await getRecentSermons(limit: 30);
      for (final sermon in recent) {
        if (!sermon.broadcastDate.isAfter(DateTime.now())) {
          return sermon;
        }
      }
      return null;
    }
  }

  // 최근 공개 설교 7개
  static Future<List<PublicSermonModel>> getWeekSermons() async {
    try {
      final now = DateTime.now();
      final snap = await _db
          .collection(_col)
          .where('isPublic', isEqualTo: true)
          .where('broadcastDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('broadcastDate', descending: true)
          .limit(7)
          .get();
      return snap.docs.map(PublicSermonModel.fromFirestore).toList();
    } catch (e) {
      final recent = await getRecentSermons(limit: 30);
      return recent
          .where((sermon) => !sermon.broadcastDate.isAfter(DateTime.now()))
          .take(7)
          .toList();
    }
  }

  // 최근 30개
  static Future<List<PublicSermonModel>> getRecentSermons(
      {int limit = 30}) async {
    try {
      final snap = await _db
          .collection(_col)
          .where('isPublic', isEqualTo: true)
          .orderBy('broadcastDate', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map(PublicSermonModel.fromFirestore).toList();
    } catch (e) {
      return [];
    }
  }

  // 클라이언트 사이드 검색 (제목·본문·목사·교회·지역)
  static Future<List<PublicSermonModel>> search(String keyword) async {
    final all = await getRecentSermons(limit: 200);
    final q = keyword.toLowerCase();
    return all
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.bibleVerse.toLowerCase().contains(q) ||
            s.pastor.toLowerCase().contains(q) ||
            s.churchName.toLowerCase().contains(q) ||
            s.region.toLowerCase().contains(q))
        .toList();
  }

  // 지역 필터
  static Future<List<PublicSermonModel>> getByRegion(String region) async {
    try {
      final snap = await _db
          .collection(_col)
          .where('region', isEqualTo: region)
          .where('isPublic', isEqualTo: true)
          .orderBy('broadcastDate', descending: true)
          .limit(30)
          .get();
      return snap.docs.map(PublicSermonModel.fromFirestore).toList();
    } catch (e) {
      return [];
    }
  }

  // 개발용 Mock 데이터 (Firebase public_sermons 비어있을 때 폴백)
  static List<PublicSermonModel> getMockData() {
    final now = DateTime.now();
    const churches = [
      ('목포 중앙교회', '전남', '김길동 목사'),
      ('광주 서문교회', '광주', '이순신 목사'),
      ('서울 새문안교회', '서울', '박철수 목사'),
    ];
    const titles = [
      ('두려움을 이기는 믿음', '이사야 41:10'),
      ('하나님의 위로', '시편 23:1'),
      ('새 힘을 얻으리니', '이사야 40:31'),
      ('돌아오라', '누가복음 15:20'),
      ('빛 가운데 걸으라', '요한1서 1:7'),
      ('평화의 하나님', '빌립보서 4:7'),
      ('기도의 능력', '마태복음 7:7'),
    ];
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: i));
      final (church, region, pastor) = churches[i % 3];
      final (title, verse) = titles[i];
      return PublicSermonModel(
        id: 'mock_$i',
        churchName: church,
        region: region,
        pastor: pastor,
        title: title,
        bibleVerse: verse,
        sermonDate: date.subtract(const Duration(days: 1)),
        summary: '하나님은 우리에게 "두려워하지 말라"고 말씀하십니다. '
            '이 말씀은 단순한 위로가 아니라 하나님이 함께하신다는 약속입니다. '
            '인생의 어떤 상황에서도 하나님의 오른손이 우리를 붙드십니다.',
        application: '오늘 가장 두렵고 걱정되는 것 하나를 하나님께 내어놓으세요. '
            '말로 기도하기 어려우면 마음속으로만 해도 충분합니다.',
        broadcastDate: date,
        source: '극동방송 데일리 말씀노트 코너',
        createdAt: date,
      );
    });
  }
}
