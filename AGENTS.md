# AGENTS.md

This file provides guidance to Codex when working with this repository.

## Project Overview

AI Canaan Church (AI 가나안교회) is a Flutter cross-platform app for Korean non-attending believers. The current app shows public sermon content from the `daily-wordnote` Firebase project and provides a local prayer note feature.

All user-facing app text should remain Korean.

## Current Product Shape

- **오늘의 말씀**: shows the latest public sermon from Firestore `public_sermons`.
- **말씀 찾기**: searches and filters recent public sermons by keyword and region.
- **기도 노트**: stores personal prayer notes locally with `SharedPreferences`.
- No login is required in the current app.
- Supabase/Auth/AI generation code in older docs is legacy context, not the current app architecture.

## Development Commands

```bash
flutter pub get
flutter run
flutter run -d chrome

flutter analyze lib test
flutter test
dart format lib test

flutter build apk --release
flutter build ipa --release
flutter build web --release
```

Use `flutter analyze lib test` for normal app checks. Plain `flutter analyze` is configured to ignore legacy/import folders, but the app-owned source is `lib/` and `test/`.

## Backend and Data

The app uses Firebase, not Supabase.

- Firebase project: `daily-wordnote`
- Main collection: `public_sermons`
- Firestore config: `lib/firebase_options.dart`
- Android config: `android/app/google-services.json`
- Rules file: `firestore.rules`

Expected `public_sermons` fields:

- `isPublic` (`bool`)
- `broadcastDate` (`Timestamp`)
- `churchName` (`String`)
- `region` (`String`)
- `pastor` (`String`)
- `title` (`String`)
- `bibleVerse` (`String`)
- `summary` (`String`)
- `application` (`String`)
- `devotionals` (`Map<String, String>`, optional)
- `sermonDate`, `createdAt`, `source`

The first screen intentionally loads the latest public sermon with `broadcastDate <= now`, not only a sermon whose date is today. This prevents old mock data from appearing when a recent sermon exists but no sermon was published today.

## Architecture

### Initialization Flow

`main.dart` initializes Firebase and Korean date formatting, then runs `AiCanaanChurchApp`.

`app.dart` registers providers and opens `MainScreen`.

### Layer Structure

- `models/` - Firestore and local data models
- `providers/` - `ChangeNotifier` state for sermons and prayer notes
- `services/` - Firestore and local persistence access
- `screens/` - full-page tab screens
- `widgets/` - reusable cards, strips, tiles, and dialogs
- `theme/` - Material 3 theme and Noto Sans KR

### Main User Flow

`MainScreen` uses bottom navigation with three tabs:

1. `TodayScreen`
2. `SearchScreen`
3. `PrayerScreen`

`SermonProvider.loadToday()` loads:

- latest public sermon for the hero card
- latest 7 public sermons for the recent strip
- mock data only when Firestore has no usable sermon data or the query fails completely

`SermonProvider.loadRecent()` powers the search tab.

## Legacy and Imported Code

This repository still contains material copied or exported from `logosflow/chimshin`:

- `chimshin/`
- `export_for_chimshin/`
- root-level Supabase/schema checking scripts such as `check_*.dart`

Treat these as reference or legacy files unless the user explicitly asks to work on them. Do not use them as the current app architecture.

## Design Notes

- Current theme colors are defined in `lib/theme/app_theme.dart`.
- Font is globally set with `GoogleFonts.notoSansKrTextTheme()`.
- Keep UI senior-friendly: large text, simple navigation, clear actions.
- Prefer concise Korean copy that matches the current Firebase public sermon experience.

## Working Rules

- Keep changes focused on the root Flutter app unless asked otherwise.
- Do not reintroduce Supabase dependencies for current app work.
- Do not convert the app back to AI-generated sermon flow without an explicit product decision.
- Run `flutter analyze lib test` and `flutter test` after code changes.
