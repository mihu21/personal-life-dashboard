# Architecture Decisions

This document records the initial technical choices for the project.

The current increment implements the application shell only. Persistence,
identifiers, and academic domain decisions below remain planned work.

## ADR-001 — Flutter for client applications

**Decision:** Use Flutter for both Windows and Android.

**Reasoning:** The project needs substantially different desktop and mobile layouts while sharing the same data model and business logic.

## ADR-002 — Local-first persistence

**Decision:** Use SQLite as the source of truth on each device.

**Reasoning:** The app should remain useful without internet access and should not depend on a hosted backend.

## ADR-003 — Drift for SQLite access

**Decision:** Use Drift as the SQLite data layer.

**Reasoning:** Drift provides typed queries, migrations, reactive streams, and good Flutter integration.

## ADR-004 — Riverpod for application state

**Decision:** Use Riverpod for dependency/state management.

**Reasoning:** It works well with repository-driven Flutter applications and keeps state access testable.

## ADR-005 — UUID-style identifiers

**Decision:** Use string UUID identifiers rather than auto-increment-only IDs for user-created domain records.

**Reasoning:** Multi-device synchronization may be introduced later. Stable globally unique identifiers make that easier.

## ADR-006 — Responsive UI, not duplicated applications

**Decision:** Share domain/data logic while providing purpose-built desktop and mobile presentations.

Desktop should use a dashboard layout.

Mobile should use one primary module per page.

## ADR-007 — Cloud synchronization deferred

**Decision:** Do not implement synchronization in Phase 1.

**Reasoning:** First validate the local data model and user experience. The repository/data layer should nevertheless avoid choices that make sync difficult later.

## ADR-008 — Graduation category and course tags are separate

A course has one graduation-credit category for credit accounting, while it may have multiple informational tags.

Example:

```text
Natural Language Processing

Graduation category:
Professional Course

Tags:
AI
CS
Data Science
English-taught
```

This keeps graduation calculations deterministic while preserving flexible classification.

## ADR-009 — Preserve semester history

Past semesters and their schedules are historical records and must not be overwritten when a new semester becomes current.

## ADR-010 — Other dashboard modules remain isolated

Tasks, Shopping, Spending, and the Today summary should not receive real data models until their own design phase begins.

## ADR-011 — Shell and feature presentation boundaries

**Decision:** Keep application composition, responsive navigation, and themes in
`lib/app/`. Give each module a presentation entry point under `lib/features/` and
keep reusable visual components in `lib/shared/widgets/`.

**Reasoning:** The Class Schedule placeholder can be replaced without coupling
its future domain/data layer to desktop or mobile navigation. Introduce feature
repositories, domain types, and persistence only when implementing that module.

The shell uses a width breakpoint of 900 logical pixels. Wider windows show a
40-pixel Today summary at the top and a two-column, two-row dashboard.
`DesktopDashboard` assigns the remaining viewport height equally to both rows
and the full available width equally to both columns. Margins and gaps are 12
pixels, with no desktop scrolling or maximum content-width cap.

Desktop has no separate application toolbar. Settings opens from the right end
of the Today bar and contains the theme selector. Removing the former 48-pixel
toolbar gives each dashboard row 24 additional pixels at the same window size.

Feature presentation entry points accept a desktop presentation flag; shared
`DesktopModulePanel` supplies compact headers and short empty states without
altering the mobile cards. On short desktop windows, panel content contracts
and optional empty-state decoration is omitted before headers. No fake records,
metrics, or live-status indicators are introduced.

Below 900 logical pixels, the existing single-page layout, bottom navigation,
and vertical scrolling are retained, including when a Windows window is narrow.

Riverpod providers currently hold only the selected module and `ThemeMode`.
Both are in-memory preferences; theme defaults to the system setting. No
database packages or generated providers are needed for this increment.
