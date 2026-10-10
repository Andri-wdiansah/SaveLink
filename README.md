# SaveLink by domoiki

Save what matters. Find it when you need it.

A polished personal link and notes manager built with Flutter. Works fully offline with SQLite storage. Designed for Android devices.

## Features
- Save links with titles, descriptions, tags, favorites, pins
- Create and edit notes
- Organize with collections
- Archive and restore items
- Search across links and notes
- Light, Dark, and System theme modes
- Native sharing and URL opening

## Technology
- Flutter / Dart
- Material Design 3
- SQLite via sqflite
- Riverpod state management

## Project layout
```
lib/
  app.dart                             app shell + bottom navigation
  data/database/database_helper.dart   SQLite schema and queries
  data/repositories/repository.dart    repository facade used by the UI
  data/providers/app_providers.dart    Riverpod providers (repository, lists)
  features/home|links|notes|collections|search|settings
  shared/widgets                       loading / empty / error states, cards
  shared/components                    Android share-intent handling
```

Each list screen reads its data from a `FutureProvider` that calls the
repository and renders one of three states: loading, error (with the real error
message plus a retry button) or content (with an empty state when the database
has no rows). Writes go through the repository and then invalidate the providers
so every tab sees the new data.

## Tests
- `flutter test` runs widget tests for every screen (empty, loading, error and
  CRUD flows) plus SQLite round-trip tests through `sqflite_common_ffi`.
- `flutter analyze` is expected to report no issues.

## Build and Development
This repository supports GitHub Codespaces and GitHub Actions for cloud-based development and APK builds.

### GitHub Actions
The `.github/workflows/android-build.yml` workflow validates code, runs tests, and produces a release APK artifact.

### Requirements
No local Android SDK or Flutter installation is required on your laptop. Use GitHub Codespaces for development and download the APK from workflow artifacts.

### Testing on Device
The target device is a Xiaomi Redmi Note 8 Pro (Android 11). Transfer the APK via USB and install manually.

## Known Limitations (Phase 1)
- Google Drive backup and restore are planned for a future phase; no cloud connection is implemented.
- No automated device-level tests have been executed in this workspace.
- The workspace does not contain a local Flutter SDK; all verification must occur in Codespaces or via GitHub Actions.
