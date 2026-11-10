# EBuk: Implementation Specification

Android-only, personal-use, lightweight e-book reader built with Flutter. Formerly codenamed Folio, now officially named EBuk.
Users search free public-domain books, download them, and read them offline.
The approved UI design is provided as an image (screens: Home, Search states, Book Details,
Library, Reader in Light/Sepia/Dark, Settings, Style Guide). Match it exactly.

---

## 0. Rules for the implementing agent

1. Everything used must be free and open source. No paid services, no API keys, no accounts.
2. Keep the app lightweight. It must run smoothly on low-end Android devices (2 GB RAM class).
3. Before adding any package, check pub.dev: it must be actively maintained, null-safe, and
   compatible with the current stable Flutter. Pin versions. Justify each package in a short comment in `pubspec.yaml`.
4. No deprecated APIs. Run `flutter analyze` with zero warnings after every phase.
5. Work phase by phase (Section 12). After each phase: analyze, run tests, and summarize what was done. Do not skip ahead.
6. All user-facing text lives in one file (`lib/core/strings.dart`). English only, professional tone. No slang, emojis, or filler copy.
7. Do not add features that are not in this document.
8. Android permissions: `INTERNET` only. Store books in app-private storage so no storage permission is needed.

---

## 1. Tech stack

| Concern | Choice |
|---|---|
| Framework | Flutter (stable), Dart, Material 3 |
| Platform | Android only (confirm sensible `minSdk`, suggested 24) |
| State management | Riverpod |
| Navigation | go_router |
| HTTP and downloads | Dio |
| Local database | Drift (SQLite) |
| Preferences | shared_preferences |
| Image caching | cached_network_image |
| File paths | path_provider |
| EPUB rendering | Decided in Phase 1 prototype (`epub_view` vs `flutter_epub_viewer`, or another maintained option) |
| Testing | flutter_test, plus mocktail if needed |

---

## 2. Data sources

- **Gutendex** (Project Gutenberg JSON API): primary source for search, metadata, covers, and EPUB download links. No key required.
  - Search: `GET /books?search=<query>`; topic filter: `topic=<topic>`; language: `languages=en`.
  - Pagination via the `next` URL in the response.
  - Use the `application/epub+zip` entry in `formats` for download and the `image/jpeg` entry for the cover.
  - The public server may be slow. Use timeouts, retry once, and cache responses.
  - Verify whether a `summaries` field exists in the current API for the description. If a description is unavailable, hide the description section instead of showing placeholder text.
- **Open Library**: optional, Phase 2 only (description fallback). Not part of the MVP.
- Attribution to Project Gutenberg (and any other source used) is required in Settings > About.

---

## 3. Architecture

Feature-first structure with clear layers. Data flow: UI > Riverpod provider > Repository > (API or local DB).

```
lib/
  core/        theme, routes, strings, constants, utils
  data/        api client (Gutendex), database (Drift), repositories, download service
  domain/      models: Book, LocalBook, ReadingProgress, ReaderSettings
  features/
    home/  search/  book_details/  library/  reader/  settings/
```

Business logic must not live in widgets.

---

## 4. Theme and design tokens

Use only this palette and its tints/shades. Define tokens once in `core/theme`.

| Role | Color |
|---|---|
| Primary / accent | `#590907` (buttons, active states, progress, key icons) |
| Background / surface | `#E8D2B5` |
| Secondary / neutral | `#A5A79B` (cards, dividers, borders, inactive icons, cover placeholders) |
| Text on beige | `#590907` or a very dark tint of it |
| Text on primary | `#E8D2B5` |

- `#A5A79B` must never be used as text on `#E8D2B5` (low contrast).
- WCAG AA contrast for all readable text.
- Themes: Light, Dark (very dark maroon-tinted background, `#E8D2B5` text, `#590907` accents), and System.
- Reader themes: Light (beige), Sepia, Dark. Reader theme is independent of the app theme.
- Flat design: no blur, no large shadows, no heavy gradients. Corner radius 8-12 dp. Screen padding 16 dp. Touch targets at least 48 dp.
- Typography: Roboto for UI. Optional serif for reading. Title 20-22 sp, section label 14 sp medium, body 16 sp, caption 12 sp.
- Icons: Material Symbols (outlined) only.

---

## 5. Navigation

- Bottom navigation: **Home, Library, Settings**.
- Routes: `/home`, `/search?q=`, `/book/:id`, `/library`, `/reader/:id`, `/settings`.
- Reader is a full-screen route with no bottom navigation.
- Back behavior must be predictable. Back from Reader returns to the previous screen.

---

## 6. Local database (Drift)

Tables:
- **books**: id (Gutenberg id), title, authors, languages, subjects, coverUrl, epubUrl, description (nullable), source
- **downloads**: bookId, filePath, fileSize, status (queued/downloading/completed/failed), downloadedAt
- **reading_progress**: bookId (unique), cfi, chapterIndex, progressPercent, lastReadAt
- **favorites**: bookId, addedAt
- **recent_searches**: query, searchedAt (keep the last 10, unique by query)

Use indexed lookups. Migrations must be defined from version 1.

Reader and app preferences (theme, font size, font, line spacing, keep screen on, reading mode) go in shared_preferences.

---

## 7. Feature requirements

### 7.1 Home
- Search bar with placeholder "Search by title or author". Tapping it focuses it and submitting opens Search Results.
- **No book listings and no API calls on launch.** This is a hard rule.
- "Recent Searches" list with a "Clear" action (shown only if history exists). Tapping an item runs the search.
- "Browse by Category" chips (Fiction, History, Philosophy, Poetry, Science, Biography). Static list. Tapping a chip runs a topic search.
- "Continue Reading" card: most recently read book (cover, title, author, progress bar, percentage, "Resume" button). Data comes from the local DB only. Hidden if nothing has been opened.

### 7.2 Search Results
- Query is trimmed; minimum 2 characters. Debounce 500 ms if search-as-you-type is used.
- Compact list item: cover thumbnail, title, author, language, "Downloaded" label if applicable.
- Pagination: load the next page on scroll end or via a "Load more" button. Small page batches.
- Cache results per query for the session. Do not refetch identical queries.
- Cancel in-flight requests when the query changes.
- States: Loading ("Searching..."), Empty ("No results found. Try a different title or author."), Error ("Unable to connect. Check your internet connection and try again." with "Retry").

### 7.3 Book Details
- Cover, title, author, language, subjects (chips), description (expandable "Read more", only if available).
- Primary button states: "Download" > "Downloading... N%" with a cancel option > "Read".
- Secondary: "Add to Favorites" / "Remove from Favorites".
- Footer: "Source: Project Gutenberg".
- If the book is already downloaded, show "Read" immediately (works offline).

### 7.4 Download manager
- Download the EPUB with Dio to `<app documents>/books/<id>.epub`.
- Write to a temporary `.part` file and rename on success, so no half-written file is ever treated as a valid book.
- Progress updates throttled (for example every 1% or 200 ms) to avoid excess rebuilds.
- Cancel deletes the partial file. Failures show a clear message with "Retry".
- Check available storage before starting. Handle redirects and timeouts.
- Validate the file after download (non-zero size, opens as a valid EPUB archive). On failure, delete and report.
- Persist status in the DB. On app start, mark any stale "downloading" records as failed.
- Foreground downloads are sufficient (personal use). Do not add background services.

### 7.5 Library
- Tabs: **Downloaded** and **Favorites**.
- List item: cover, title, author, progress bar, last-read date.
- Overflow or long-press menu: "Remove from Device" (deletes the file and download record, keeps reading progress), "Remove from Favorites". Confirm destructive actions.
- Sort: Recently Read, Title, Author.
- Empty state: "Your library is empty. Search for a book to get started."
- Works fully offline. Never makes network calls.

### 7.6 Reader (highest priority)

**Behavior**
- Full-screen reading view. Top and bottom bars hidden by default; tapping the center toggles them.
- Top bar: back, title (truncated), Table of Contents, Settings.
- Bottom bar: progress slider, current chapter name, percentage.
- Table of Contents: bottom sheet or drawer, current chapter highlighted, tap to jump.
- Reader Settings sheet: Font Size (slider), Font (Sans / Serif), Line Spacing (Compact / Standard / Relaxed), Theme (Light / Sepia / Dark). Changes apply live without reloading the book.
- Reading mode: horizontal paging or vertical scroll (setting).
- Keep screen on while reading (setting).

**Save and resume (must be flawless)**
- Save position as an **EPUB CFI** (not page numbers, which change with font size and screen size). Also store chapterIndex and progressPercent as a fallback.
- Save triggers: page or scroll change (debounced, about 1 second), app lifecycle `paused`/`inactive`/`detached`, leaving the reader (dispose), and before opening another book.
- Writes must be atomic upserts on `reading_progress` and must never block the UI thread.
- On open: restore to the saved CFI immediately. If the CFI fails, fall back to chapterIndex then percent. Show a brief non-blocking message: "Resumed from your last position."
- Restored position must remain correct after changing font size, font, line spacing, theme, or orientation.
- Force-closing the app, a crash, or low-memory kill must lose at most about 1 second of reading position.

**Performance**
- Load only the current chapter plus a pre-load of the next. Never hold the whole book as rendered content.
- Parse the EPUB off the main thread (isolate).
- Minimize rebuilds (const widgets, narrow provider scopes, `select`).
- Opening a typical novel should show the saved page quickly; show a lightweight loading state meanwhile.
- Limit image memory in chapters. Release resources on dispose.

### 7.7 Settings
- **Appearance:** Theme (System / Light / Dark).
- **Reading:** default font size, font, line spacing, keep screen on.
- **Storage:** "Downloaded Books" total size (computed from real files), "Clear Cache" (image and search cache only, never downloaded books or progress).
- **About:** version (from package info), "Data Sources and Attribution" (Project Gutenberg and any other source used, with their required notices), "Privacy" (short statement: no accounts, no analytics, data stored on device).

---

## 8. Performance and low-end device requirements

- Release builds with code shrinking. Build APKs with `--split-per-abi`.
- `ListView.builder` for all lists. `const` constructors wherever possible.
- Decode covers at display size (`memCacheWidth`/`cacheWidth`). Cache covers on disk with a size limit.
- No blur, `Opacity` layers, or `saveLayer`-heavy effects. Simple, short transitions only.
- No unnecessary packages, no analytics, no ads, no background services.
- Target: cold start under about 2 seconds on a low-end device, scrolling without visible jank, stable memory while reading.
- Profile with `flutter run --profile` and DevTools on a low-end device or emulator profile.

---

## 9. Error handling

- Typed failures (network, timeout, server, storage, parsing). Map each to a clear, professional user message from `strings.dart`.
- No raw exception text in the UI. No silent failures.
- Offline: Search shows the error state; Library and Reader keep working.
- Corrupt or missing book file: show "This book could not be opened. Remove it from your device and download it again."

---

## 10. Testing

- Unit tests: repositories, Gutendex response parsing, download service (success, cancel, failure), progress save/restore logic.
- Widget tests: Home (no books shown), Search states, Book Details button states, Library empty state.
- Manual test matrix: restore position after force-stop; after changing font size; after rotation; after phone restart; after low-memory kill; download interrupted by airplane mode; airplane-mode reading; large book (1000+ pages); low-end device.

---

## 11. Acceptance criteria

1. App launch makes **zero** network requests and shows no book listings.
2. Search returns results, paginates, caches, and handles loading, empty, and error states.
3. A book can be downloaded, cancelled, retried, and read offline.
4. Reopening any book lands on the exact saved position, including after force-stop and font changes.
5. All screens match the approved design in Light, plus Reader in Sepia and Dark.
6. `flutter analyze` reports no issues; all tests pass.
7. Release APK installs and runs smoothly on a low-end Android device.
8. All text is English and professional, sourced from `strings.dart`.

---

## 12. Build order

| Phase | Scope | Checkpoint |
|---|---|---|
| 0 | Project setup, folder structure, theme tokens, strings, routing shell with bottom navigation | App runs; empty screens themed correctly |
| 1 | **Reader prototype**: test candidate EPUB packages with 2-3 sample EPUBs; verify CFI save/restore, font-size change, load speed, memory | Written recommendation of the final EPUB package |
| 2 | Database, models, repositories | Unit tests passing |
| 3 | Search: Gutendex client, debounce, pagination, cache, Search Results and Book Details | All states implemented |
| 4 | Download manager and Library | Download, cancel, retry, delete work |
| 5 | Final Reader with save/resume, TOC, settings | Acceptance criterion 4 verified |
| 6 | Home (recent searches, categories, Continue Reading) and Settings | Acceptance criterion 1 verified |
| 7 | Polish, performance profiling, release build | Acceptance criteria 6-8 verified |

---

## 13. Notes on the design mockup

- Sample books in the mockup (for example "1984") are placeholders. Do not hardcode them. Some titles may not be available on Project Gutenberg. Use real data from the API.
- The storage size shown in Settings (for example "1.2 GB") is sample data. Compute the real value.
- The app name "Folio" is a working name and should be a single constant so it can be changed easily.
