# Tasks & Reminders implementation and acceptance review

Implemented directly in the existing project. The initial Git working tree was
clean. No commits, pushes, history changes, data resets, or unrelated module
redesigns were performed.

## What changed

- Agenda (default), Week and Month are the only main task views.
- Tasks support title, notes, editable categories and colors, an optional reference
  to a current in-progress course, three priorities, Active/Completed status, completion timestamps, and timed,
  date-only or absent deadlines.
- Agenda groups overdue, earlier completed, today, tomorrow, this week, later and
  no-deadline work. Empty sections are hidden. Search covers title, notes, category
  and linked course name.
- Categories, priorities and statuses allow multiple selections. Groups combine
  with AND; selections within a group combine with OR. Category/priority empty
  selection means all; status requires at least one selection in the filter UI.
- Next 5/10/20/All limits upcoming dated results after filtering. Overdue and
  no-deadline sections are independently selectable, remain outside due-period
  boundaries, and do not consume the upcoming limit. This behavior is explained
  in the filter dialog. Next N days includes today; ranges include their last day.
  Date-only deadlines become overdue at the start of the following local day.
- Filters, search, and the upcoming limit persist in SQLite across navigation and
  restart. Reset changes the filter draft; Apply persists it; Cancel discards it.
- Week has full weekday names on wide screens and Mon/Tue-style selectors on small screens.
  Month distributes all 4–6 rows across the available height. The calendar itself
  does not scroll vertically. Busy days show a remainder count and open a task list.
  Category colors and 1/2/3 bars identify Low/Medium/High priority. A legend names
  the categories; narrow screens use indicators instead of shrinking task titles.
- Search includes the filter button in Agenda, Week and Month. The small dashboard
  card has view/filter/add/expand controls. Full and compact modules share view,
  date and saved filters. Agenda stays the startup default.
- Clicking any task first opens details with Edit, Delete, Complete (or Mark active)
  actions. Creation has no status picker; new tasks always start Active. Overdue
  remains an automatic indication on unfinished tasks, not a separate status.
- Categories can be added, renamed, recolored (palette or hex), and removed using
  the palette button or Manage categories in the editor. Removal requires a
  replacement category and preserves all tasks; saved category filters follow.
- The course picker offers only nondeleted in-progress courses in the current
  semester. Existing links to inactive courses are retained and can be unlinked.
- Existing themes, typography, cards and navigation are reused. Task text stays
  readable at 14–16px. Calendar dates allow horizontal scrolling at large text
  sizes when needed. The desktop 2x2 shell remains viewport-bound.

## Storage and migration

The existing `AcademicDatabase`/`academic_records.sqlite` moves from schema 3/4 to
schema 5 through Drift migrations. The task tables are:

- `task_records`: UUID ID, audit timestamps/tombstone, task fields, recurrence,
  completion time, and unique previous-occurrence ID.
- `task_reminders`: SQLite auto-increment notification ID, task reference,
  either deadline offset or absolute reminder time, and optional snooze time.
- `task_preferences`: saved Agenda filters/search/limit.
- `task_category_records`: category names and opaque ARGB colors.

The schema-5 upgrade maps To Do/In Progress to Active and Urgent to High in
existing rows. Completed states, task IDs, reminder IDs, dates, notes and recurrence
remain intact. Existing category names seed the category table. Saved old filter
values and old backup task values normalize to the new enums when read.

Existing academic tables and their rows are retained. Course links are soft IDs
into the existing course model: replacing academic data during backup restore
must not cascade-delete tasks. An unavailable course remains labelled as such
until the task is edited/unlinked. Courses are never duplicated into task storage.

Legacy event reminder arrays remain in `one_time_events.json` and continue to
round-trip through event editing and backups. They are inactive, hidden and never
converted into tasks. The old event service file is an inert compatibility file;
there is only one active notification service. The initial Tasks reconciliation
retires old OS schedules without rewriting the event JSON file. Existing manual
events, appointments, classes, NTHU periods and Graduation stay in Class Schedule.

Backup format 3 includes tasks, reminders, filters and editable category colors.
Formats 1 and 2 remain accepted. Format 1 preserves current task data; format 2
normalizes old status/priority values and retains category definitions. All task
payloads are parsed before replacement. Writes use the existing SQLite transaction
and event-file rollback. Notification schedules are reconciled after restore.

## Reminder and notification behavior

The previous platform implementation was refactored into the Tasks domain using
existing `flutter_local_notifications`, `flutter_timezone` and `timezone` packages.
**No new dependencies or platform permissions were added.** Existing Android
notification/boot receiver configuration and the Windows app identity are reused.

- A task may have zero or many reminders. Deadline presets are 0, 10, 30, 60, 180,
  1440, 4320 and 10080 minutes before the effective deadline. A custom date/time
  works even with no deadline. Date-only presets are relative to end of day.
- Presets follow deadline edits. Removing the deadline in the editor converts
  existing relative reminders to absolute times so they are not silently lost.
- Snooze in the editor offers 10 minutes, 1 hour, tomorrow at the current local
  time, and custom date/time. Save task applies it. Snooze affects only that
  reminder and occurrence; it never changes the deadline.
- SQLite commits before notification reconciliation. The app root watches task
  changes even when another module is selected. Startup, app resume, edits,
  deletion, completion and restore rebuild the OS mirror.
- A single serial queue reads the latest committed task data, cancels prior app
  notifications (including retired event notifications), and schedules only
  future reminders on active tasks. Stable integer IDs and per-task time
  deduplication prevent duplicate requests. Removed/deleted/completed reminders
  cannot reappear from stale queued edits. Past times are skipped.
- Android permission is requested only when the user saves reminders or retries.
  Inexact idle-compatible scheduling avoids adding exact-alarm permission.
  Windows schedules dated toasts using the existing app identity.
- OS failures/denied permission preserve saved task data, are visible in Tasks,
  and can be retried. Restart/resume also retries reconciliation. OS operations
  cannot be atomic with SQLite; the database remains authoritative after a crash.

## Recurrence decisions

Daily, weekly and monthly recurrence accepts a custom positive interval (1–999).
Completion retains the completed row and creates one successor in the same
transaction. Missed dates are skipped to the next unexpired occurrence, with no
bulk future-row generation. Monthly repeats keep the original day, clamped only
for short months (January 31 → February 28/29 → March 31). Calendar arithmetic
preserves local wall-clock time across DST boundaries.

Relative reminders follow the next deadline; custom reminders retain their day
offset and time; snooze resets for the new occurrence. A no-deadline task never
acquires a synthetic deadline. Its recurrence anchors to its earliest custom
reminder, or creation time when there are no custom reminders. The unique
previous-occurrence ID prevents duplicate successors after reopening and
recompleting a task, even if its successor was deleted.

## Validation and practical limits

Validation results are recorded below. The acceptance
checklist means implemented and verified by source review and the applicable
unit/widget/database/fake-notification tests. It does **not** claim physical-device
notification receipt. Actual Windows/Android toast display, notification permission
prompts, reboot delivery, battery restrictions and time-zone travel need device
acceptance testing. Android inexact alarms can be delayed by the OS. Snooze is
in-app; system-notification action buttons and notification-tap deep links are not
included. Future recurring occurrences are created on completion rather than
prepopulating the calendar. These decisions stay within the approved scope.

## Acceptance checklist — specification section 30


### Module separation

Existing Class Schedule/course/event tests; event editor/details regression assertions; task calendar widget tests.

- [x] Class Schedule still supports classes and manually added events.
- [x] Class Schedule no longer exposes reminder/notification configuration.
- [x] Removing reminder logic does not break Class Schedule.
- [x] Tasks calendars do not show Class Schedule entries.

### Tasks

Task editor field bindings and actions reviewed; repository CRUD/reopen/nullable-edit tests; priority/status/deadline domain tests; editor widget layout tests.

- [x] User can create a task.
- [x] User can edit a task.
- [x] User can delete a task.
- [x] User can complete a task.
- [x] Revised by the latest user request: new tasks start Active and can be Completed/reopened; old To Do/In Progress values migrate to Active.
- [x] Revised by the latest user request: Low / Medium / High only; old Urgent values migrate to High.
- [x] User can select a category.
- [x] User can optionally link a course.
- [x] User can add notes.
- [x] User can use date+time, date-only, or no deadline.

### Agenda

Task filter/sort/group domain tests; search/multi-select widget tests; persisted filter round-trip tests.

- [x] Agenda is the default Tasks & Reminders view.
- [x] No Daily calendar view exists.
- [x] Tasks are grouped appropriately.
- [x] Overdue tasks are clear.
- [x] No-deadline tasks are supported.
- [x] Next 5 / 10 / 20 / All works.
- [x] Multi-category filtering works.
- [x] Multi-priority filtering works.
- [x] Multi-status filtering works.
- [x] Due-period filtering works.
- [x] Combined filters work correctly.

### Week

Task-only input path reviewed; wide-column and narrow-selector widget tests at 1x/2x text; rendered desktop previews.

- [x] No hourly grid.
- [x] Shows task deadlines only.
- [x] No Class Schedule entries.
- [x] Responsive on desktop and mobile.

### Month

Calendar date grid and selected-date behavior reviewed; counts/title limits and responsive widget tests; rendered previews.

- [x] Standard calendar-style month layout.
- [x] Shows task indicators on due dates.
- [x] Selecting a date exposes that day's tasks.
- [x] No Class Schedule entries.
- [x] No overflow or unreadably small text.

### Reminders

Independent/custom/preset reminder domain tests; stable IDs; create/edit/delete/complete/retry lifecycle tests; live Riverpod-to-fake-backend integration; reopen tests.

- [x] A task can have zero reminders.
- [x] A task can have multiple reminders.
- [x] Custom reminder date/time works.
- [x] Reminder presets work.
- [x] Reminders are independent of deadlines.
- [x] No-deadline tasks can have reminders.
- [x] Editing reminders updates scheduled notifications.
- [x] Deleting a task cancels relevant notifications.
- [x] Completing a task handles future notifications correctly.
- [x] App restart preserves reminder/task state.

### Recurrence

Daily/weekly/monthly/custom date arithmetic; monthly anchor and leap-year tests; one-successor idempotence; no-deadline/custom-reminder recurrence tests.

- [x] Daily recurrence works.
- [x] Weekly recurrence works.
- [x] Monthly recurrence works.
- [x] Recurring tasks do not create runaway duplicate data.

### Regression

68-test pre-change baseline; full regression suite; schema-3 migration preserves course/meeting/category rows and byte-identical legacy event file; theme/responsive widget coverage.

- [x] Existing Graduation module still works.
- [x] Existing Class Schedule layout still works.
- [x] Existing course/event data is preserved.
- [x] Existing mobile/desktop responsive behavior outside this module is not unintentionally changed.
- [x] Existing dark/light theme behavior remains intact.

## Final check results

- Formatter: all 31 changed/new Dart files formatted.
- Static analysis: `dart analyze lib test` — **No issues found**.
- Existing baseline: **68 tests passed** before Class Schedule UI removal.
- Final full suite: `flutter test --no-pub` — **111 tests passed**; no unrelated
  pre-existing test failures and no remaining test failures.
- Additional rendered task audit: **18 task widget tests passed** with real fonts,
  including light/dark desktop previews. Standard tests also cover 320/390/900/1440
  widths at 1x/2x scaling; the existing whole-app responsive audit remains passing.
- Windows release build: **passed**. The first debug build compiled but could not
  link because the existing debug executable was open (LNK1168); that process was
  left running and the separate release build verified native compilation.
- Android debug build: **passed**. The existing `flutter_timezone` plugin emits a future Kotlin Gradle Plugin compatibility warning; dependencies were not changed.
- Drift code generation completed successfully; generated schema code is included.
- `git diff --check` passed.
- ZIP verification: **passed**: exactly 33 project-relative entries, CRC integrity checked, all extracted bytes matched the current source by SHA-256, and prohibited contents excluded.

The Flutter launcher initially lacked sandbox access to the SDK lockfile; checks
were run with approved SDK access. Commands used the installed Flutter/Dart tools
from this project directory. Drift's multiple-database warning in migration tests
comes from independent test connections to different temporary/in-memory files,
not from app runtime connections. No application database was opened for tests.

## Files added or modified

33 project files. The ZIP contains these paths only; no Git metadata, build outputs, caches, APKs or complete project copy.

- Modified: `README.md`
- Added: `docs/TASKS_AND_REMINDERS_IMPLEMENTATION.md`
- Modified: `lib/app/dashboard_app.dart`
- Modified: `lib/app/shell/dashboard_shell.dart`
- Modified: `lib/app/shell/desktop_dashboard.dart`
- Modified: `lib/app/shell/settings_dialog.dart`
- Modified: `lib/features/class_schedule/data/academic_database.dart`
- Modified: `lib/features/class_schedule/data/academic_database.g.dart`
- Modified: `lib/features/class_schedule/data/event_notification_service.dart`
- Modified: `lib/features/class_schedule/data/local_backup_service.dart`
- Modified: `lib/features/class_schedule/domain/one_time_event.dart`
- Modified: `lib/features/class_schedule/presentation/one_time_event_details.dart`
- Modified: `lib/features/class_schedule/presentation/one_time_event_editor.dart`
- Modified: `lib/features/class_schedule/providers/academic_providers.dart`
- Added: `lib/features/tasks/data/task_notification_service.dart`
- Added: `lib/features/tasks/data/task_repository.dart`
- Added: `lib/features/tasks/domain/task_logic.dart`
- Added: `lib/features/tasks/domain/task_types.dart`
- Added: `lib/features/tasks/presentation/task_categories_dialog.dart`
- Added: `lib/features/tasks/presentation/task_details.dart`
- Added: `lib/features/tasks/presentation/task_visuals.dart`
- Added: `lib/features/tasks/presentation/task_editor.dart`
- Added: `lib/features/tasks/presentation/task_filter_dialog.dart`
- Added: `lib/features/tasks/presentation/tasks_module.dart`
- Modified: `lib/features/tasks/presentation/tasks_placeholder.dart`
- Added: `lib/features/tasks/providers/task_providers.dart`
- Modified: `test/dashboard_shell_test.dart`
- Modified: `test/one_time_event_details_test.dart`
- Modified: `test/one_time_event_editor_layout_test.dart`
- Modified: `test/responsive_visual_audit_test.dart`
- Added: `test/task_logic_test.dart`
- Added: `test/task_repository_test.dart`
- Added: `test/tasks_widget_test.dart`

The two compatibility files overwrite the retired implementations when this
changed-files ZIP is extracted into another project copy. No file deletion step
is needed. Nothing has been committed or pushed.
