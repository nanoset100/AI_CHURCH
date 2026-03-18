# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AI Canaan Church (AI 가나안교회) — a Flutter cross-platform app (iOS, Android, Web) providing AI-generated personalized sermons and daily spiritual content for Korean non-attending believers. All UI text is in Korean.

## Development Commands

```bash
flutter pub get          # Install dependencies

# 개발 실행 (.env.json 필수)
flutter run --dart-define-from-file=.env.json
flutter run -d chrome --dart-define-from-file=.env.json

flutter analyze          # Static analysis
flutter test             # Run tests
dart format lib/         # Format code

# 릴리스 빌드 (.env.json 또는 CI/CD 시크릿 사용)
flutter build apk --release --dart-define-from-file=.env.json
flutter build ipa --release --dart-define-from-file=.env.json
flutter build web --release --dart-define-from-file=.env.json
```

## Environment Setup

`.env.json` 파일을 프로젝트 루트에 생성 (`.env.json.example` 참고):
```json
{
  "SUPABASE_URL": "https://<project>.supabase.co",
  "SUPABASE_ANON_KEY": "<anon-key>"
}
```
- `.env.json`은 `.gitignore`에 포함되어 커밋되지 않음
- `EnvConfig`는 `String.fromEnvironment()`로 컴파일타임 상수를 읽음
- 키가 바이너리에 내장되어 앱 번들에 평문 파일로 노출되지 않음
- 설정 누락 시 앱이 설정 오류 화면을 표시하고 크래시하지 않음

## Architecture

### Initialization Flow (main.dart)
`EnvConfig.load()` → validate config → `Supabase.initialize()` → `MultiProvider` wraps `MaterialApp` → `AuthWrapper` routes to login or home based on auth state.

### Layer Structure
- **config/** — Environment variable loading (`EnvConfig`, static accessors)
- **models/** — Data classes with JSON serialization (`Sermon`)
- **providers/** — ChangeNotifier-based state management (`SermonProvider` manages generation state, current/saved sermons, errors)
- **services/** — Static method classes for business logic (`AuthService` for Supabase Auth, `AiService` for sermon generation)
- **screens/** — Full-page views (home dashboard, auth screens, AI sermon flow)
- **widgets/** — Reusable UI components composed into screens
- **theme/** — `AppTheme` with Material 3, color constants, and globally-forced Noto Sans KR font

### Authentication (ReflectOS Pattern)
The auth system follows a specific pattern documented in the codebase:
1. Sign-up creates the user but does NOT auto-login — redirects to login screen
2. Profile save to `profiles` table is async and non-blocking — signup succeeds even if profile save fails
3. Login success navigates directly to HomeScreen
4. `AuthWrapper` widget listens to Supabase auth state and routes accordingly

### AI Sermon Flow
Dialog (user enters concern) → LoadingScreen → ResultScreen (display + save option). `AiService`가 Supabase Edge Function `generate-sermon`을 호출하여 실제 AI 설교를 생성.

### Data Storage
Dual strategy: primary storage in Supabase PostgreSQL (`saved_sermons` table), with in-memory fallback for offline resilience.

### Supabase Tables
- `profiles`: id, email, display_name
- `saved_sermons`: id, user_id, title, verse, content, user_prompt, created_at

RLS policies need configuration via `supabase_rls_fix.sql`.

## Design Constants

- Primary: `#4A90E2`, Secondary: `#F5F5DC`, Text: `#333333`, Background: `#FAFAFA`
- Card border radius: 16.0, AI sermon card: 20.0
- Font: Noto Sans KR applied globally via `GoogleFonts.notoSansKrTextTheme()`
- Senior-friendly design: large fonts, clear buttons, simple navigation

## Key Dependencies

- `supabase_flutter` — Auth, database, real-time
- `provider` — State management via ChangeNotifier
- `google_fonts` — Korean font support (Noto Sans KR)
