# AI 가나안교회

AI 가나안교회는 교회 밖에서도 말씀과 기도를 이어가고 싶은 사용자를 위한 Flutter 앱입니다. 현재 버전은 `daily-wordnote` Firebase 프로젝트의 `public_sermons` 설교 데이터를 가져와 오늘 묵상할 말씀, 최근 말씀 목록, 개인 기도 노트를 제공합니다.

## 현재 기능

- **오늘의 말씀**: Firestore `public_sermons`에서 현재 시각 이전의 최신 공개 설교를 표시합니다.
- **최근 말씀**: 최신 공개 설교 7개를 가로 목록으로 보여줍니다.
- **말씀 찾기**: 최근 공개 설교를 키워드와 지역으로 검색합니다.
- **기도 노트**: 로그인 없이 기기에 개인 기도 노트를 저장합니다.
- **공유**: 설교 요약과 적용 내용을 공유할 수 있습니다.

## 기술 스택

- Flutter / Dart
- Firebase Core
- Cloud Firestore
- Provider
- SharedPreferences
- Google Fonts (Noto Sans KR)
- Share Plus

## 실행 방법

```bash
flutter pub get
flutter run
```

Chrome에서 확인하려면:

```bash
flutter run -d chrome
```

## 검사 및 테스트

```bash
flutter analyze lib test
flutter test
dart format lib test
```

일반 개발 점검은 `lib/`와 `test/`를 기준으로 합니다. 저장소에는 `logosflow/chimshin`에서 가져온 참고 코드와 이전 Supabase 점검 스크립트가 남아 있어, 전체 저장소를 무작정 분석하면 현재 앱과 무관한 오류가 섞일 수 있습니다.

## Firebase 데이터 구조

현재 앱은 Firebase 프로젝트 `daily-wordnote`의 top-level 컬렉션 `public_sermons`를 사용합니다.

주요 필드:

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `isPublic` | `bool` | 공개 설교 여부 |
| `broadcastDate` | `Timestamp` | 앱에 노출할 방송/공개 기준일 |
| `churchName` | `String` | 교회 이름 |
| `region` | `String` | 지역 |
| `pastor` | `String` | 설교자 |
| `title` | `String` | 설교 제목 |
| `bibleVerse` | `String` | 본문 |
| `summary` | `String` | 설교 요약 |
| `application` | `String` | 오늘의 적용 |
| `devotionals` | `Map<String, String>` | `day1`~`day6` 묵상, 선택 |
| `sermonDate` | `Timestamp` | 실제 설교일 |
| `createdAt` | `Timestamp` | 생성일 |
| `source` | `String` | 출처 |

첫 화면은 `broadcastDate`가 오늘인 문서만 찾지 않습니다. 매일 설교가 생성된다는 보장이 없기 때문에 `broadcastDate <= 현재 시각`인 공개 설교 중 가장 최신 문서를 보여줍니다.

## 프로젝트 구조

```text
lib/
├── main.dart                  # Firebase 초기화 및 앱 진입점
├── app.dart                   # Provider 등록 및 MaterialApp
├── firebase_options.dart      # Firebase 프로젝트 설정
├── models/
│   ├── public_sermon_model.dart
│   └── prayer_note_model.dart
├── providers/
│   ├── sermon_provider.dart
│   └── prayer_provider.dart
├── services/
│   ├── sermon_service.dart
│   └── prayer_note_service.dart
├── screens/
│   ├── main_screen.dart
│   ├── today/
│   ├── search/
│   └── prayer/
├── widgets/
└── theme/
```

## 화면 흐름

1. `main.dart`에서 Firebase와 한국어 날짜 포맷을 초기화합니다.
2. `AiCanaanChurchApp`이 `SermonProvider`, `PrayerProvider`를 등록합니다.
3. `MainScreen`이 하단 탭으로 `오늘의 말씀`, `말씀 찾기`, `기도 노트`를 전환합니다.
4. `TodayScreen`은 최신 공개 설교와 최근 말씀을 표시합니다.
5. `SearchScreen`은 Firestore 설교 목록을 검색/필터링합니다.
6. `PrayerScreen`은 로컬 기도 노트를 추가하고 삭제합니다.

## Legacy 참고 코드

이 저장소에는 원본/참고용으로 남아 있는 코드가 있습니다.

- `chimshin/`
- `export_for_chimshin/`
- 루트의 `check_*.dart`, `get_schema.dart` 등 Supabase 점검 스크립트

현재 AI 가나안교회 앱의 기준은 루트 `lib/`입니다. 위 파일들은 참고용으로만 보고, 현재 앱 기능을 수정할 때는 `lib/`, `test/`, Firebase 설정 파일을 중심으로 작업합니다.

## 현재 방향

이 앱은 지금 단계에서 Supabase 기반 AI 생성 설교 앱이 아니라, Firebase `public_sermons`를 소비하는 말씀/기도 앱입니다. 향후 AI 생성, 로그인, 동기화 기능을 추가할 수 있지만, 현재 구조를 먼저 안정화한 뒤 별도 제품 결정으로 진행하는 것을 권장합니다.
