# TASKS.md

> The single source of truth for progress: what is planned, what is being worked on, what is done. AI agents: this file is how you know where we are. Follow the protocol in Section 1 exactly.
> What to build comes from `PROJECT_BRIEF.md`. How it is built comes from `ARCHITECTURE.md` and `AGENTS.md`. Master spec: `FOLIO_IMPLEMENTATION_SPEC.md`.

---

## 0. Legend

| Marker | Meaning |
|--------|---------|
| `[ ]` | To do |
| `[~]` | In progress (only ONE task at a time) |
| `[x]` | Done and verified |
| `[!]` | Blocked (see Section 6) |
| `[-]` | Cancelled or skipped (keep it, add the reason) |

- **Task ID:** `T-001`, `T-002`, ... Never reuse or renumber IDs.
- **Priority:** `P0` = MVP must-have, `P1` = should-have, `P2` = nice-to-have.
- **Size:** `S` = under 30 min, one or two files. `M` = up to a few hours, a few files. `L` = too big (must be split).

---

## 1. Protocol for AI agents (MANDATORY)

Follow strictly: plan first, work on one task at a time, verify with `flutter analyze` and `flutter test`, and update this file upon completion.

---

## 2. Current focus

- **Task:** None
- **Goal (1 line):** Home page modular structure complete and verified.
- **Started:** 2026-11-10
- **Branch:** main
- **Steps:**
  - [x] Configure design tokens and typography
  - [x] Implement isolated Home presentation widgets (no icons)
  - [x] Setup Riverpod HomeController and immutable HomeState
  - [x] Implement MainShellScreen with text-only navigation
  - [x] Verify flutter analyze (0 warnings) and flutter test (passed)
- **Files touched so far:** lib/core/theme/*, lib/features/home/*, lib/features/shell/*, test/widget_test.dart
- **How to test:** flutter test
- **Notes / decisions made:** Clean separation of concerns strictly applied. Zero icons used.

---

## 3. Session handoff

- **Last updated:** 2026-11-10
- **What was done this session:** Initialized project docs (`AGENTS.md`, `PROJECT_BRIEF.md`, `ARCHITECTURE.md`, `TASKS.md`, `DECISIONS.md`, `README.md`) aligning with `FOLIO_IMPLEMENTATION_SPEC.md` and renamed the app to EBuk.
- **State of the app:** Clean Flutter starter template, passes `flutter analyze` with 0 issues.
- **Last working commit:** Initial commit
- **Uncommitted changes:** Documentation files.

---

## 4. Tasks (by Phase)

### Phase 0: Project Setup, Theme Tokens, Strings & Navigation Shell
- [x] `T-001` [P0, M] Configure dependencies in `pubspec.yaml` with pinned versions & justifications, create folder structure (`core/`, `data/`, `domain/`, `features/`).
- [x] `T-002` [P0, S] Implement `lib/core/strings.dart` as the single source of truth for all English UI text.
- [x] `T-003` [P0, M] Implement `lib/core/theme/` design tokens (#590907 maroon, #E8D2B5 beige, #A5A79B neutral) with Material 3 theme data (Light, Dark, and Reader Sepia/Dark palettes).
- [x] `T-004` [P0, M] Setup `go_router` shell navigation with bottom navigation bar (Home, Library, Settings) and initial placeholder screens. Verify with `flutter analyze`.

### Phase 1: Reader Spike & Prototype
- [ ] `T-005` [P0, M] Test candidate EPUB packages (`epub_view` vs `flutter_epub_viewer`) with sample EPUBs. Verify CFI position saving/restoration and font scaling. Document decision in `DECISIONS.md`.

### Phase 2: Domain Models & Local Database (Drift)
- [ ] `T-006` [P0, M] Define domain models (`Book`, `LocalBook`, `ReadingProgress`, `ReaderSettings`).
- [ ] `T-007` [P0, M] Configure Drift SQLite database schema (`books`, `reading_progress`, `search_history`) and repository implementations with unit tests.

### Phase 3: Gutendex Search & Book Details
- [ ] `T-008` [P0, M] Implement Gutendex API client with Dio (search, pagination, debounce, timeout handling, and caching).
- [ ] `T-009` [P0, M] Build Search Results screen with loading, empty, and error states.
- [ ] `T-010` [P0, M] Build Book Details screen with metadata, cover image, and dynamic description handling.

### Phase 4: Download Manager & Library Feature
- [ ] `T-011` [P0, M] Build DownloadManager service with progress reporting, cancellation, and retry capabilities.
- [ ] `T-012` [P0, M] Build Library screen displaying offline books, progress indicators, and delete options.

### Phase 5: Production Reader Implementation
- [ ] `T-013` [P0, L] Implement full-screen Reader route with TOC navigation, instant CFI resume on relaunch, and Reader theme switcher (Light, Sepia, Dark).

### Phase 6: Home Screen & Settings
- [ ] `T-014` [P1, M] Build Home screen featuring recent searches, category shortcuts, and "Continue Reading" card (zero network calls on launch).
- [ ] `T-015` [P1, M] Build Settings screen with app theme toggle, storage usage calculation, and Project Gutenberg attribution.

### Phase 7: Polish, Profiling & Release Build
- [ ] `T-016` [P0, M] Performance profiling, memory leak audit, `ListView.builder` image cache verification, and `--split-per-abi` release APK generation.

---

## 5. Backlog
- [ ] `T-017` [P2, S] Open Library description fallback if Gutendex summary is absent.

---

## 6. Blocked tasks
- None.

---

## 7. Known bugs
- None.

---

## 8. Done log
- None yet.
