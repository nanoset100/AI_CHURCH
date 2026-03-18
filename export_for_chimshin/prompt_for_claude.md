# 침신 말씀노트 앱 기능 통합 가이드 (클로드 코드용 프롬프트)

클로드 코드님 반가워요! 기존 `ai_canaan_church` 프로젝트(Supabase + Provider)에 있던 핵심 기능 2가지(오늘의 성경, 나의 기도제목)를 현재의 `chimshin_bible_note` 프로젝트(Firebase + Riverpod)로 이식해주세요.

## 🎯 목표
1. **오늘의 성경 (Daily Bible)**: 메인 홈 화면에 고정된 특정 성경 구절 프리뷰 카드 표시 및 상세 화면 이동
2. **나의 기도제목 (Prayer Requests)**: 홈 화면에 내 기도 갯수 요약 카드 표시 및 기도 등록/관리 상세 화면 이동

---

## 🛠️ Step 1: 상태 관리 및 백엔드 서비스 변환 (Supabase -> Firebase)
기존 Supabase 기반의 코드를 Firebase + Riverpod 구조로 재작성해야 합니다.

### 1-1. 성경 데이터 관리 (`BibleService` & `BibleNotifier`)
*   **데이터 소스**: 성경 텍스트 데이터베이스가 Firebase Firestore에 구성되어 있다고 가정하거나, 혹은 기존 방식처럼 정적 데이터(`bible_data.dart`)를 활용해 주세요.
*   **Riverpod Provider**:
    *   초기화 시 기본 성경 구절(예: 마태복음 1장 1절)을 로드하는 `AsyncNotifier`를 만들어 주세요.
    *   상태 클래스는 `BibleVerse` 모델의 리스트가 되어야 합니다.

### 1-2. 기도제목 데이터 관리 (`PrayerService` & `PrayerNotifier`)
*   **데이터 모델 (`PrayerRequest`)**:
    ```dart
    class PrayerRequest {
       final String id;
       final String userId;
       final String title;
       final String content;
       final bool isAnswered;
       final DateTime createdAt;
       // ... copyWith, fromJson, toJson
    }
    ```
*   **Firestore 연동**: `users/{uid}/prayer_requests` 서브 컬렉션 또는 최상단 `prayer_requests` 컬렉션에 사용자 ID별 필터링 구조로 저장. CRUD 로직을 작성해 주세요.
*   **Riverpod Provider**: Firestore Streams 기반의 `StreamProvider<List<PrayerRequest>>` 형태로 구현하면 실시간 업데이트에 유리합니다.

---

## 🎨 Step 2: 홈 화면(`home_screen.dart`) UI 통합

`lib/presentation/screens/home/home_screen.dart`의 `SingleChildScrollView` 내부에 두 가지 핵심 카드를 삽입해 주세요. (위치는 `_TodayDevotionCard` 아래쪽이 적절합니다.)

### 2-1. `DailyBibleCard` 위젯 생성
*   기존 `lib/widgets/daily_bible_card.dart` 의 디자인(그림자, 아이콘, 코너 라운드 등)을 참고합니다.
*   `ConsumerWidget`으로 작성하여 `bibleProvider`를 구독합니다.
*   클릭 시 `BibleReadingScreen` (또는 `BibleSelectionScreen`)으로 내비게이션 되도록 설정해 주세요.

### 2-2. `PrayerRequestsCard` 위젯 생성
*   기존 `lib/widgets/prayer_requests_card.dart`의 레이아웃 (총 기도 개수 + 최근 2~3개 미리보기)을 활용합니다.
*   `ConsumerWidget`으로 `prayerRequestProvider`를 구독하여 로딩 중, 에러, 목록 상태를 분기 처리(AsyncValue)해 주세요.
*   클릭 시 `PrayerRequestsScreen`으로 이동하도록 `GoRouter` 혹은 `MaterialPageRoute`를 연결합니다.

---

## 🚀 Step 3: 상세 화면 이식

### 3-1. 통합형 성경 읽기 화면 (`BibleReadingScreen`)
*   최상단에 **책(Book) 드롭다운**과 **장(Chapter) 드롭다운**이 있는 "통합형" 화면 구조를 구현해야 합니다.
*   (선택) 기존에 사용했던 Supabase Storage 기반의 오디오 플레이어 로직(`audioplayers` 패키지)도 Firebase Storage URL 또는 외부 CDN URL을 통해 연동해 주세요.

### 3-2. 기도제목 관리 화면 (`PrayerRequestsScreen`)
*   FloatingActionButton으로 새 기도 추가 모달(혹은 다이얼로그) 띄우기 기능 구현.
*   각 기도제목 카드는 완료(응답받음) 체크 기능과 삭제 기능(Swipe-to-delete 혹은 아이콘 클릭)을 포함해야 합니다.
*   모든 상태 변화는 Riverpod의 Notifier를 통해 즉각적으로 UI에 반영되게 해주세요.

---

> 💡 **주요 참고 사항**
> * 디자인 시스템은 현재 `chimshin_bible_note`의 `AppColors` 및 텍스트 테마 규칙을 엄격히 준수해 주세요.
> * 불필요한 에러 방지를 위해, 기존 Supabase 클라이언트 코드가 Firebase/Riverpod 코드에 섞여 들어오지 않는지 반드시 점검해 주세요.
