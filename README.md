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
