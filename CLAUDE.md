# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AI Canaan Church (AI 가나안교회) — a Flutter cross-platform app (iOS, Android, Web) providing AI-generated personalized sermons and daily spiritual content for Korean non-attending believers. All UI text is in Korean.

## Development Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device
flutter run -d chrome    # Run on web
flutter run -d <device>  # Run on specific device
flutter analyze          # Static analysis
flutter test             # Run tests
dart format lib/         # Format code
flutter build apk --release  # Android release build
flutter build web --release  # Web release build
```

## Environment Setup

Requires a `.env` file in project root (see `.env.example`):
```
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_ANON_KEY=<anon-key>
```
The `.env` file is bundled as a Flutter asset. `EnvConfig.load()` validates the URL format before Supabase initialization; if invalid, the app shows a config error screen instead of crashing.

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
Dialog (user enters concern) → LoadingScreen (3-5s simulated delay) → ResultScreen (display + save option). Currently uses sample data in `AiService`; real AI integration is pending.

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
- `flutter_dotenv` — .env file loading
