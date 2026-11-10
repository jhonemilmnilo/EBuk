# PROJECT_BRIEF.md

> The "what and why" of this project. AI agents: read this before planning or building any feature. If a request conflicts with the scope below, point it out and ask before proceeding.
> Technical details (stack, commands, folders) live in `AGENTS.md`. Structure and data flow live in `ARCHITECTURE.md`. Task progress lives in `TASKS.md`.

---

## 1. One-line summary

A lightweight, distraction-free Android e-book reader that lets users search, download, and read public-domain books offline with zero accounts or ads.

## 2. Problem

- **What problem does this solve?** Existing e-reader apps are often bloated with subscription paywalls, ads, account requirements, battery-draining telemetry, and cloud synchronizations that perform poorly on budget Android devices.
- **How do people deal with it today?** They download ad-heavy commercial readers or struggle with clunky PDF viewers and browser-based readers.
- **Why is that not good enough?** Low-end Android devices lag, storage is consumed with unnecessary caching/analytics, and privacy is compromised by mandatory logins.

## 3. Target users

| User type | Who they are | What they need |
|-----------|--------------|----------------|
| Everyday Reader | Casual & avid readers who love classic literature | Fast, clean search, simple offline downloads, and smooth reading |
| Budget Device User | Users on low-end Android phones (2 GB RAM) | Fast cold boot (<2s), minimal RAM/battery consumption, no background bloat |

- **Tech level of users:** Non-technical to general mobile users.
- **Devices:** Android only (minSdk 24+, optimized for low-end 2GB RAM devices).
- **Language(s) of the app:** English only, professional tone.

## 4. Goals and success

- **Main goal:** Provide a snappy, reliable e-book reading experience from Gutenberg's catalog to local offline storage with instant resume.
- **How I will know it works:**
  - Cold launch in under 2 seconds on entry-level Android devices.
  - App launch performs zero network calls.
  - Reader saves and restores exact reading progress (CFI/position) even across app restarts or font adjustments.
  - `flutter analyze` has 0 warnings and tests pass consistently.

## 5. Features

### Must have (MVP: the app is not usable without these)
- [ ] Gutendex search integration with pagination, debounce, and query caching.
- [ ] Book details view showing author, title, cover, and description (hiding if unavailable).
- [ ] Offline EPUB download manager with cancel, retry, and progress status.
- [ ] EPUB reading engine with page navigation, Table of Contents (TOC), and position restore.
- [ ] Reader theme support: Light (Beige), Sepia, and Dark with customizable font sizes.
- [ ] Local Library displaying downloaded books, reading progress, and delete options.
- [ ] App settings with theme toggle (Light/Dark/System), storage computation, and Gutenberg attribution.

### Should have (important, build right after MVP)
- [ ] Recent searches history on Home screen.
- [ ] Curated Gutenberg topic shortcuts (e.g. Fiction, History, Science).
- [ ] Continue Reading quick-jump card on Home.

### Could have (nice to have, only if time allows)
- [ ] Open Library description fallback if Gutendex summary is absent.
- [ ] Custom serif vs sans-serif reader typography switcher.

## 6. Key user flows

**Flow 1: Search and Download a Book**
1. User opens Search or taps a category/recent query from Home.
2. System queries Gutendex (debounced), presenting book cards with titles, authors, and cover thumbnails.
3. User selects a book to open Book Details.
4. User taps "Download"; system downloads the `application/epub+zip` payload to private storage and indexes it in Drift DB.

**Flow 2: Reading Offline with Exact Resume**
1. User opens Library (or taps "Continue Reading" on Home).
2. User taps a downloaded book; Reader screen opens full-screen.
3. Reading engine jumps immediately to the saved progress point.
4. User adjusts font size or theme; layout refits cleanly without losing the reading position.
5. On exit or backgrounding, system commits progress to Drift.

## 7. Scope: what is NOT included

**Out of scope (strictly enforced):**
- Paid features, subscriptions, in-app purchases, or ads.
- User accounts, cloud accounts, remote sync, or social logins.
- PDF, MOBI, or audio book formats (EPUB only).
- Background services or telemetry/analytics.
- Cloudflare, Firebase, Supabase, or custom server backends.

**Explicit non-goals:**
- This is NOT a commercial bookstore; it is a clean reader for public-domain titles.

## 8. Constraints

- **Budget / hosting:** 100% free and open source. Zero operational server costs.
- **Permissions:** Android `INTERNET` only. Books stored in app-private storage.
- **Design:** Strict adherence to `#590907` (maroon), `#E8D2B5` (beige), and `#A5A79B` (neutral). Material Symbols outlined icons.
