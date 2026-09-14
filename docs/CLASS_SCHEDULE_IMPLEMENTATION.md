# Class Schedule implementation

The approved dashboard shell was retained. Class Schedule replaced only its
top-left placeholder and the mobile Schedule page. The supplied brief is now
available as `CODEX_CLASS_SCHEDULE_MODULE.md` in the repository.

## Incremental checkpoints

Each stage was formatted, analyzed, and tested before proceeding. Failures found
during a stage were corrected before its checkpoint:

| Stage | Scope | Passing tests at checkpoint |
|---|---|---:|
| 1 | Drift schema, repository, UUID/audit fields, persistence | 19 |
| 2 | Semester/category/course management and forms | 21 |
| 3 | Today/Week, clock, gaps, locations, dated exceptions | 28 |
| 4 | Credit progress and semester history | 31 |
| 5 | Planning, advisory conflicts, duplication, optional demo | 37 |

Final integration validation on 2026-09-10:

- `dart format .` completed.
- `flutter analyze` reported no issues.
- `flutter test` passed all 38 tests, including populated mobile at 200% text size.
- `flutter build windows --debug` produced the Windows executable.
- `flutter build apk --debug` produced the Android debug APK.
- Desktop Today/Week and mobile screenshots were rendered with Flutter widget
  tests and inspected. Preview images are in the ignored `build/previews/` folder.
- Native builds were verified; interactive device testing remains a manual check.

## Suggested logical commit boundaries

No commits are created automatically. Suggested review/commit groups:

1. `feat: add Drift academic storage and repositories` — dependency files,
   database/schema generation, repository, snapshots, types/drafts, providers,
   and persistence tests.
2. `feat: add academic record management` — editors, management/setup screens,
   course details, shell entry points, and management validation tests.
3. `feat: add today and week schedules with exceptions` — schedule engine,
   timetable, Today view, exceptions, clock integration, and schedule tests.
4. `feat: add academic progress and semester history` — credit calculations,
   progress/history screens, and credit/history tests.
5. `feat: add future semester planning and conflict warnings` — planning,
   overlap detection, review/save-anyway flow, demo seed, final integration tests,
   and updated project documents.

These groups describe logical review boundaries; shared entry-point files contain
changes from several stages and should be staged by hunk or reconstructed per
stage if individually buildable commits are desired.

## Deliberate boundaries

- The desktop shell remains a non-scrolling 2×2 grid with a 40-pixel Today bar.
- The compact schedule card prioritizes current/next class; the full module shows
  the complete day and scrollable timetable.
- Times are local, weekly meetings do not cross midnight, and timetable weeks
  start Monday and include weekends.
- One exception per meeting/date is supported. Edit the existing exception to
  combine a time change with a replacement room. Moves to another date are a
  cancellation plus an extra class.
- Weekly conflict warnings do not claim to be a full university scheduling or
  prerequisite engine. Planned credits remain projections, never completed credits.
- Every completed course record counts; repeat-course substitution rules are not
  inferred. Category targets and the overall target are independently configured.
- No Tasks, Shopping, Spending, Firebase, cloud sync, GPA, or unrelated features
  were implemented.
