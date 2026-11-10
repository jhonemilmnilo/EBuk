# DECISIONS.md

> The memory of WHY. Every meaningful choice (stack, library, architecture, data model, approach) is recorded here with its reason, so we never have to re-argue it and so a new chat can understand the project without guessing.
> AI agents: read this before proposing changes to the stack, structure, or approach. Do not reverse a decision silently.
> What to build: `PROJECT_BRIEF.md`. How it is built: `ARCHITECTURE.md` and `AGENTS.md`. Progress: `TASKS.md`.

---

## 1. Protocol for AI agents (MANDATORY)

Log every architectural and stack decision here following the standard format. Do not silently change decisions.

---

## 2. Index

| ID | Date | Decision | Status |
|----|------|----------|--------|
| D-003 | 2026-11-10 | App Name rebranded to EBuk | Accepted |
| D-002 | 2026-11-10 | Zero-telemetry, zero-account, app-private storage architecture | Accepted |
| D-001 | 2026-11-10 | Flutter with Riverpod, Drift (SQLite), and go_router | Accepted |

---

## 3. Decision records (newest first)

### D-003: App Name rebranded to EBuk
- **Date:** 2026-11-10
- **Status:** Accepted
- **Context:** The initial working spec used the name "Folio", but the project repository and user request establish the name as **EBuk**.
- **Decision:** Change all user-facing, documentation, and app metadata references to **EBuk**.
- **Consequences:**
  - Clear and consistent identity matching `pubspec.yaml` and repository name.
  - Sourced as a single constant in `lib/core/constants/` or `lib/core/strings.dart`.

### D-002: Zero-telemetry, zero-account, app-private storage architecture
- **Date:** 2026-11-10
- **Status:** Accepted
- **Context:** Low-end Android devices suffer from memory consumption and battery drain caused by background services, analytics, and accounts.
- **Decision:** EBuk requires NO user accounts, NO cloud storage, and only the `INTERNET` Android permission. EPUB files are saved in app-private sandbox storage (`path_provider`).
- **Consequences:**
  - Zero storage permission dialogs required on modern Android.
  - Zero server maintenance costs.
  - Maximum privacy and instantaneous offline availability.

### D-001: Flutter with Riverpod, Drift (SQLite), and go_router
- **Date:** 2026-11-10
- **Status:** Accepted
- **Context:** Need a reactive, typed, and robust stack capable of high performance on 2GB RAM Android phones.
- **Decision:** Use Flutter stable with Riverpod 2.x for state management, Drift for typed reactive SQLite storage, and `go_router` for declarative navigation.
- **Consequences:**
  - Good: Type-safe SQL queries via Drift; predictable unidirectional data flow with Riverpod; clean deep-linking/routing.
  - Trade-off: Requires `build_runner` for code generation during development.
