# 침신 말씀노트 앱 기능 통합 가이드 (클로드 코드용 프롬프트)

클로드, 현재 작업 중인 `chimshin_bible_note` 프로젝트(Firebase + Riverpod 사용)에 기존 `ai_canaan_church` 앱의 핵심 기능들을 이식하고 화면을 개편해 줘.

[작업 지침]
1. 홈 화면 (home_screen.dart) 통합 및 '이번 주 활동' 추가
- `lib/presentation/screens/home/home_screen.dart`의 스크롤 뷰 안에 기존 가나안교회 앱의 `DailyBibleCard`와 `PrayerRequestsCard`를 추가해. (위치는 `_TodayDevotionCard` 아래쪽)
- 그리고 홈 화면의 맨 아래쪽(`_QuickMenu` 주요 기능 아래)에 가나안교회 앱에 있는 **'이번 주 활동 (WeeklyActivityCard)'**을 통째로 이식해 줘. 
- (주의: 모든 카드의 상태 관리는 Firebase + Riverpod 구조로 수동 변환해야 해)

2. 통폐합된 설교 상세 화면 (sermon_detail_screen.dart) 개편
- 어제 이미 `_SummaryTab` 내부에 오디오 플레이어(TTS) 로직과 UI가 추가되어 있어! 이 부분을 잘 활용해야 해.
- 기존 설교 상세 화면에 있던 3개의 탭(요약, 핵심 포인트, 주중 묵상) 구조를 완전히 **삭제**해버려. 단일 스크롤 화면(SingleChildScrollView)으로 변경해.
- 삭제되는 `_SummaryTab` 안에 구현되어 있던 **오디오 플레이어 코드와 로직**을 꺼내서 상세 화면의 최상단(제목 및 정보 아래 영역)으로 끌어올려 배치해 줘.
- 오디오 플레이어 바로 아래에는 탭 없이 오직 **'설교 요약' 텍스트** 하나만 쭉 보여지도록 해. (핵심 포인트와 주중 묵상 내용은 이 화면에서 아예 삭제)

3. 상세 화면 (Screen) 이식 고려사항
- `BibleReadingScreen`: 최상단에 (책 - 장)을 고를 수 있는 2개의 드롭다운 버튼을 가진 통합형 UI를 구현해 줘.
- `PrayerRequestsScreen`: 리스트 뷰와 새 기도제목 추가(FAB), 스와이프 삭제 등 기존의 CRUD 화면을 Riverpod 상태와 연결해서 똑같이 만들어 줘.

기존 Supabase(가나안교회)용 클라이언트 코드나 Provider 코드가 이번 Firebase+Riverpod 프로젝트에 절대 섞여 들어오지 않도록 로직을 완전히 Riverpod에 맞춰 전환해줘.
