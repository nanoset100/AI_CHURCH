# AI 가나안교회 (AI Canaan Church)

> **어디서나 함께하는 당신만의 영적 안식처**

## 📖 프로젝트 개요

**AI 가나안교회**는 교회에 출석하지 않으나 신앙을 유지하는 '가나안 성도' 240만 명을 위한 비대면 영적 케어 플랫폼입니다. 개인 맞춤형 AI 설교와 일상의 영적 리듬을 제공하여 제도권의 틀을 벗어난 자유로운 신앙생활을 지원합니다.

## ✨ 핵심 기능

### 1. AI 맞춤 설교 (핵심 기능)
- 사용자의 현재 고민(육아, 직장, 고립감 등)을 입력하면 AI가 위로의 말씀과 설교를 생성
- 3-5초의 자연스러운 생성 딜레이로 AI가 생각하는 듯한 UX 제공
- 생성된 설교는 보관함에 저장하여 언제든 다시 볼 수 있음

### 2. 홈 대시보드
- **오늘의 예배**: 매일 새로운 예배 콘텐츠 제공
- **오늘의 성경**: 일일 성경 읽기와 진행률 표시
- **기도 제목**: 개인 기도 제목 관리
- **주간 활동**: 예배, 성경 읽기, 연속 출석 기록 등 통계

### 3. 영적 보관함
- 생성된 AI 설교를 안전하게 보관
- Supabase와 로컬 이중 저장으로 데이터 안정성 보장
- 저장된 설교를 언제든 다시 열람 가능

## 🛠️ 기술 스택

### 프론트엔드
- **Flutter** (Dart): 크로스 플랫폼 네이티브 앱 개발
- **Provider**: 상태 관리 (AI 설교 생성, 저장, 삭제 등)
- **Google Fonts (Noto Sans KR)**: 한글 폰트 지원

### 백엔드 & 인프라
- **Supabase**: 
  - 인증 (회원가입, 로그인, 세션 관리)
  - 데이터베이스 (설교 저장, 프로필 관리)
- **flutter_dotenv**: 환경 변수 관리 (API 키 보안)

### 디자인
- **테마**: 따뜻한 베이지(#F5F5DC)와 신뢰감 있는 파란색(#4A90E2)
- **UI/UX**: 직관적이고 단순한 구성, 큰 폰트와 명확한 버튼 (시니어 친화적)

## 📁 프로젝트 구조

```
lib/
├── config/
│   └── env_config.dart          # 환경 변수 관리
├── models/
│   └── sermon.dart              # 설교 데이터 모델
├── providers/
│   └── sermon_provider.dart     # 설교 상태 관리 (Provider)
├── screens/
│   ├── home_screen.dart         # 홈 대시보드
│   ├── auth/
│   │   ├── login_screen.dart    # 로그인 화면
│   │   └── signup_screen.dart   # 회원가입 화면
│   ├── ai_sermon_dialog.dart    # AI 설교 생성 다이얼로그
│   ├── ai_sermon_loading_screen.dart  # 설교 생성 로딩 화면
│   └── ai_sermon_result_screen.dart   # 설교 결과 화면
├── services/
│   ├── auth_service.dart        # 인증 서비스 (ReflectOS 패턴)
│   └── ai_service.dart          # AI 설교 생성 서비스
├── theme/
│   └── app_theme.dart           # 앱 테마 정의
├── widgets/
│   ├── auth_wrapper.dart        # 인증 상태 래퍼
│   ├── greeting_section.dart    # 인사말 섹션
│   ├── ai_sermon_card.dart      # AI 설교 카드
│   ├── daily_worship_card.dart  # 오늘의 예배 카드
│   ├── daily_bible_card.dart    # 오늘의 성경 카드
│   ├── prayer_requests_card.dart # 기도 제목 카드
│   ├── saved_sermons_card.dart  # 보관된 설교 카드
│   ├── weekly_activity_card.dart # 주간 활동 카드
│   └── bottom_nav_bar.dart      # 하단 네비게이션 바
└── main.dart                    # 앱 진입점
```

## 🚀 시작하기

### 필수 요구사항
- Flutter SDK (>=3.0.0)
- Supabase 계정 및 프로젝트
- `.env` 파일 (환경 변수 설정)

### 설치 및 실행

1. **저장소 클론**
   ```bash
   git clone <repository-url>
   cd test009AICHURCH
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **환경 변수 설정**
   - `.env.example`을 참고하여 `.env` 파일 생성
   ```env
   SUPABASE_URL=your_supabase_url_here
   SUPABASE_ANON_KEY=your_supabase_anon_key_here
   ```

4. **Supabase 데이터베이스 설정**
   - `profiles` 테이블 생성 (id, email, display_name)
   - `saved_sermons` 테이블 생성 (id, user_id, title, verse, content, user_prompt, created_at)

5. **앱 실행**
   ```bash
   flutter run
   ```

## 🔐 인증 시스템 (ReflectOS 패턴)

본 프로젝트는 **ReflectOS 정석 패턴**을 따릅니다:

1. **회원가입**: 성공 시 자동 로그인하지 않고, 로그인 화면으로 리다이렉트
2. **프로필 저장**: 백그라운드에서 비동기 처리, 실패해도 가입은 성공으로 처리
3. **로그인**: 성공 시 즉시 HomeScreen으로 이동
4. **에러 처리**: Supabase `AuthException.message`를 그대로 사용자에게 표시

## 📱 주요 화면

### 홈 화면
- CustomScrollView와 Sliver 구조로 부드러운 스크롤
- 모든 카드 위젯을 SliverToBoxAdapter로 배치
- 하단 고정 네비게이션 바

### AI 설교 생성 플로우
1. **홈 화면** → AI 설교 카드 클릭
2. **다이얼로그** → 고민 입력 및 제안 키워드 선택
3. **로딩 화면** → 애니메이션과 성경 구절 표시 (3-5초)
4. **결과 화면** → 생성된 설교 표시 및 보관 기능

## 🎨 디자인 가이드라인

- **주요 색상**:
  - Primary: #4A90E2 (파란색)
  - Secondary: #F5F5DC (베이지)
  - Text: #333333
  - Background: #FAFAFA

- **폰트**: Noto Sans KR (모든 화면에 전역 적용)
- **Border Radius**: 16.0 (카드), 20.0 (AI 설교 카드 강조)

## 📝 개발 로드맵 (완료)

- [x] 1단계: 인프라 설정 및 폰트 고정
- [x] 2단계: UI 재건 (홈 화면 네이티브 이식)
- [x] 3단계: Supabase Auth 연동 (ReflectOS 패턴)
- [x] 4단계: AI 설교 생성 로직 연결

## 🤝 기여

프로젝트 개선을 위한 제안과 기여를 환영합니다!

## 📄 라이선스

이 프로젝트는 비상업적 목적으로 개발되었습니다.

---

**AI 가나안교회** - 어디서나 함께하는 당신만의 영적 안식처 🙏
