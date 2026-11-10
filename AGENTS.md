# AGENTS.md: Project Rules

> Project-specific instructions for AI agents. Global rules in `~/.gemini/GEMINI.md` still apply. This file adds details for THIS project only.
> Keep this file short and accurate. Update it whenever the stack, commands, or structure change.

---

## 1. Project overview

- **Name:** EBuk
- **What it does:** Android-only, personal-use, lightweight e-book reader. Users search free public-domain books via Project Gutenberg (Gutendex), download them, and read them offline.
- **Who uses it:** Book readers looking for a minimal, fast, distraction-free reading experience on Android.
- **Status:** In progress (MVP setup)
- **Details:** see `PROJECT_BRIEF.md` (goals, features, scope), `FOLIO_IMPLEMENTATION_SPEC.md` (master spec), and `ARCHITECTURE.md` (structure, data flow).
- **Current work:** see `TASKS.md`.

## 2. Tech stack

| Layer | Choice | Version |
|-------|--------|---------|
| Language | Dart | ^3.12.0 (Flutter 3.44.0) |
| Framework | Flutter (Material 3) | 3.44.0 |
| UI / Styling | Custom theme tokens (#590907 maroon, #E8D2B5 beige, #A5A79B neutral) | Native Material 3 |
| State Management | Riverpod (flutter_riverpod) | 2.x |
| Navigation | go_router | 14.x |
| HTTP & Downloads | Dio | 5.x |
| Database | Drift (SQLite) + sqlite3_flutter_libs | 2.x |
| Preferences | shared_preferences | 2.x |
| Image Caching | cached_network_image | 3.x |
| File Storage / Paths | path_provider (app-private storage) | 2.x |
| EPUB Engine | Candidate tested in Phase 1 (epub_view / flutter_epub_viewer) | TBD |
| Hosting / Deploy | Android APK (--split-per-abi) | minSdk 24 |
| Package manager | flutter pub | n/a |
| Testing | flutter_test, mocktail | n/a |

**Rules about the stack:**
- Use only the stack above. Do not introduce a new framework, ORM, or major library without asking first.
- Every package must be free, open-source, null-safe, and justified with a short comment in `pubspec.yaml`.
- Run `flutter analyze` with zero warnings after every phase.
- Use `flutter pub` only.

## 3. Commands

Run these from the project root. Always use these exact commands; do not guess alternatives.

| Purpose | Command |
|---------|---------|
| Install dependencies | `flutter pub get` |
| Run dev / debug | `flutter run` |
| Build release APK | `flutter build apk --split-per-abi` |
| Run all tests | `flutter test` |
| Run one test file | `flutter test test/<filename>_test.dart` |
| Lint / static analysis | `flutter analyze` |
| Code generation (Drift/Riverpod) | `dart run build_runner build --delete-conflicting-outputs` |
| Format code | `dart format .` |

## 4. Folder structure

```
ebuk/
├── lib/
│   ├── core/         # Theme tokens, routes, strings (single source of truth), constants, utils
│   ├── data/         # API client (Gutendex), database (Drift), repositories, download service
│   ├── domain/       # Models: Book, LocalBook, ReadingProgress, ReaderSettings
│   └── features/     # Feature-first modules
│       ├── home/          # Search bar, recent searches, categories, continue reading
│       ├── search/        # Search results, pagination, filters, cache
│       ├── book_details/  # Metadata, download trigger, description
│       ├── library/       # Downloaded books, progress, delete action
│       ├── reader/        # EPUB viewer, TOC, font/theme controls, progress tracking
│       └── settings/      # Theme toggle, font settings, storage management, about/attribution
├── test/             # Unit and widget tests
├── assets/           # Bundled fonts or placeholder graphics (if required)
├── pubspec.yaml      # Pinned dependencies with justifications
└── AGENTS.md         # This file
```

**Placement rules:**
- Business logic must NEVER live inside widgets. Flow: UI -> Riverpod provider -> Repository -> (API or local DB).
- All user-facing text MUST live in `lib/core/strings.dart`. No hardcoded strings in widgets.
- Do not edit or create files inside build output (`build/`, `.dart_tool/`).

## 5. Conventions

**Naming**
- Files: `snake_case.dart` (e.g. `book_card.dart`)
- Variables / functions: `camelCase`
- Classes / widgets / enums: `PascalCase`
- Constants: `lowerCamelCase` or `UPPER_SNAKE_CASE` (standard Dart style: prefer `lowerCamelCase` for constants)

**Code style**
- Strict null safety. No `!` force unwrapping unless strictly validated.
- `const` constructors wherever possible to maximize performance on low-end devices.
- No heavy animations, blur, `Opacity` widgets, or `saveLayer` calls.
- Decode images at display size using `memCacheWidth` / `cacheWidth`.

**Data and API**
- All external book metadata comes from Gutendex API.
- All local database operations go through Drift DAOs / repositories.
- Android permissions: `INTERNET` only. Books live in app-private storage (`path_provider`).

## 6. Environment variables & Secrets

- EBuk has NO backend accounts, NO API keys, and NO paid services.
- Everything runs on free public endpoints (Gutendex).
- No `.env` secrets required.

## 7. Project-specific rules

**Do:**
- Keep memory low: designed for 2GB RAM Android devices.
- App launch must make ZERO network requests and show no book listings until user interacts.
- Store books in app-private storage so no storage runtime permissions are requested.
- Maintain WCAG AA contrast on `#E8D2B5` beige and `#590907` maroon.

**Don't:**
- Do not introduce Firebase, Supabase, analytics, or ads.
- Do not add features outside `FOLIO_IMPLEMENTATION_SPEC.md`.
- Never use `#A5A79B` as text directly on `#E8D2B5` (low contrast).

## 8. Definition of done

A task is done only when ALL of these are true:
1. Feature works as specified in `FOLIO_IMPLEMENTATION_SPEC.md`.
2. `flutter analyze` reports zero warnings or errors.
3. Relevant unit/widget tests pass via `flutter test`.
4. User-facing strings are strictly in `lib/core/strings.dart`.
5. Progress is reflected in `TASKS.md`.

## 9. Known gotchas

- Gutendex public server can occasionally experience high latency. Set network timeouts and retry once with cached responses.
- In `pubspec.yaml`, pin exact compatible versions for Flutter 3.44.0 / Dart 3.12.
