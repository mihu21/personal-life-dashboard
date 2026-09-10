# Personal Life Dashboard

A local-first personal dashboard for Windows and Android.

The app is intentionally being built module-by-module. The first implemented module will be the **Class Schedule** module.

## Current project status

This repository currently contains the project definition and implementation brief only.

The Flutter application itself will be created in the next development commit.

## Phase 1 — Class Schedule

The Class Schedule module will eventually include:

- Today and Week schedule views
- Current and next class awareness
- Free-time gaps
- Course locations
- Semester history
- Graduation credit tracking
- Custom graduation categories
- Course tags
- Future-semester planning
- Schedule conflict detection
- Graduation-impact previews
- One-off schedule exceptions

The rest of the dashboard will initially remain as visual placeholders:

- Today summary bar
- Tasks & Reminders
- Shopping
- Spending

## Target platforms

- Windows desktop
- Android

## Planned stack

- Flutter
- Dart
- Material 3
- SQLite
- Drift
- Riverpod

The application will be local-first. Cloud synchronization is intentionally out of scope for the first phase.

## Repository documents

- `CODEX_CLASS_SCHEDULE_MODULE.md` — detailed implementation brief for Codex
- `docs/PROJECT_SCOPE.md` — product scope and boundaries
- `docs/ARCHITECTURE_DECISIONS.md` — initial technical decisions

## Suggested first development step

After this initial commit is pushed, give Codex the contents of `CODEX_CLASS_SCHEDULE_MODULE.md` and ask it to implement the project incrementally.

Suggested next commit:

```text
feat: initialize Flutter application shell
```
