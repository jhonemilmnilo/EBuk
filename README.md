# EBuk

A fast, lightweight, distraction-free Android e-book reader for free public-domain books from Project Gutenberg.

**Status:** In Development · **Platform:** Android (minSdk 24+) · **Last verified setup:** 2026-11-10

---

## 1. What it does

- **Instant Search:** Browse and search free public-domain classics via Gutendex with pagination and query caching.
- **Offline Reading:** Download EPUB files directly to app-private storage and read without internet.
- **Precision Resume:** Automatically preserves and restores your exact reading position (CFI) across app restarts and font scaling.
- **Battery & Memory Friendly:** Cold start in under 2s on 2GB RAM Android phones. Zero ads, zero tracking, zero accounts.

Full goals and scope: see `PROJECT_BRIEF.md` and `FOLIO_IMPLEMENTATION_SPEC.md`.

## 2. Tech stack

Flutter (Material 3) · Dart 3.12+ · Riverpod · go_router · Dio · Drift (SQLite) · path_provider · cached_network_image

Exact architecture and rules: see `AGENTS.md` and `ARCHITECTURE.md`.

## 3. Prerequisites

| Tool | Required version | Check with | Get it from |
|------|------------------|------------|-------------|
| Flutter SDK | 3.24+ (current: 3.44) | `flutter --version` | [flutter.dev](https://flutter.dev) |
| Dart SDK | 3.5+ (current: 3.12) | `dart --version` | Bundled with Flutter |
| Android SDK | API 24+ | `flutter doctor` | Android Studio |
| Git | any recent | `git --version` | [git-scm.com](https://git-scm.com) |

**Accounts needed:** None.

## 4. Quick start

```bash
# 1. Install dependencies
flutter pub get

# 2. Verify static analysis
flutter analyze

# 3. Run the app on an Android device or emulator
flutter run
```

## 5. Common commands

| Purpose | Command |
|---------|---------|
| Run app | `flutter run` |
| Run tests | `flutter test` |
| Code analysis | `flutter analyze` |
| Format code | `dart format .` |
| Build release APK | `flutter build apk --split-per-abi` |
| Drift code generation | `dart run build_runner build --delete-conflicting-outputs` |
