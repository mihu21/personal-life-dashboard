# Personal Life Dashboard

A local-first Flutter dashboard for Windows and Android. The **Class Schedule
module is functional**; Today summary, Tasks & Reminders, Shopping, and Spending
remain placeholders. Material 3 and Riverpod support light, dark, and system themes.

## Dashboard layout

The approved desktop layout is preserved: a 40-pixel Today bar with Settings on
the right, then four equal panels with 12-pixel margins and gaps. At widths of
900 logical pixels and above, the dashboard fills the viewport without scrolling.
The top-left panel shows the current/next class or a compact weekly timetable.
Use its expand button to open the full schedule.

On narrower windows and mobile, bottom navigation remains Schedule, Tasks,
Shopping, and Spending. Schedule has Schedule / Progress / History / Planning
sections and a Manage records button. Long lists and the full timetable scroll
within the module. The other three modules retain their placeholder presentation.

## First use

1. Open Schedule, then **Manage records** (the calendar/edit icon).
2. Set an optional overall graduation-credit target.
3. Confirm/edit the six starter categories. Names and targets are configurable;
   categories can be reordered or hidden without losing existing credits.
4. Create a current semester, then add courses, tags, and weekly meetings.

Setup can be skipped. No fictional courses are loaded automatically. **Load
fictional demo** is available in Manage records only before semesters or courses
exist. It requires confirmation and creates explicitly labeled demo semesters,
courses, a sample credit target, and a future plan with a sample conflict.

## Class Schedule capabilities

- Semester creation/editing, current/completed/planned status, archiving, and
  confirmed deletion. Making a semester current preserves previous courses.
- Course editing, credits, category, status, optional code/professor/location/notes,
  comma-separated tags, and multiple weekly meetings with individual locations.
- Course details, completion/withdrawal, duplication into another semester, and
  soft deletion. Duplication uses new course and meeting identifiers.
- Today and Week views, local date navigation, current/next class cues, free gaps,
  finished-class fading, a time-positioned seven-day timetable, and category accents.
- One-off cancellation, same-day rescheduling, room changes, and extra classes.
  Select the particular weekly meeting to change. A move to another date uses a
  cancellation on the original date and an extra class on the new date.
- Overall and per-category completed / in-progress / planned / potential credits.
  Failed and withdrawn courses earn no credits. Hidden categories retain credit
  accounting. Overall and category requirements are independent.
- Semester history with course details and historical schedules.
- Future plans, selected-semester graduation-impact previews, and weekly overlap
  warnings with all affected course names and overlap minutes. **Save anyway**
  allows an intentional conflict; adjacent meetings are not conflicts.

## Persistence and boundaries

Drift/SQLite stores academic records in `academic_records.sqlite` inside the
platform's application-support directory (`getApplicationSupportDirectory`).
Records persist across restarts. Entity IDs are UUIDs; mutable records carry
creation/update timestamps and deletion tombstones. A singleton academic setting
stores the overall target and setup preference. The database opens in a background
isolate through `drift_flutter`; Riverpod streams refresh dependent views.

Schema version is 1. Generated Drift code is included. When changing the schema,
add a migration and regenerate code; do not delete the database to migrate user data.
For a manual backup, close the app and copy the SQLite file and any sidecar files
from the application-support directory together.

The schedule uses device-local civil dates and minutes after midnight. Meetings
must finish on the same day (24:00 is allowed as an end). Weekly conflict warnings
compare planned/in-progress course meetings within one semester; the dated
schedule reflects exceptions. It does not implement recurrence beyond weekly
meetings, prerequisites, repeat-course credit substitution, or university-specific
rules. Completed credits count each completed course record once.

The desktop card is intentionally a compact reference. Open the full module for
all classes, editing, history, and planning. The clock refreshes every 30 seconds.
Tab/theme preferences remain in memory, as in the approved shell.

Tasks, Shopping, Spending, cloud sync, Firebase, and unrelated features are not
implemented.

## Run

Developed with Flutter 3.44.2 / Dart 3.12.2. Windows requires Visual Studio's
**Desktop development with C++** workload and Windows SDK. Android requires an
Android SDK and an emulator or USB-debugging device. Check `flutter doctor -v`.

Windows, from PowerShell:

```powershell
cd C:\Users\MiHu\Documents\personal-life-dashboard
flutter pub get
flutter run -d windows
```

Android, after connecting a device or starting an emulator:

```powershell
cd C:\Users\MiHu\Documents\personal-life-dashboard
flutter pub get
flutter devices
flutter run -d <android-device-id>
```

Replace `<android-device-id>` with the Android ID printed by `flutter devices`
(for example `emulator-5554`). To start a configured emulator:

```powershell
flutter emulators
flutter emulators --launch <emulator-id>
```

## Development and validation

```powershell
dart run build_runner build
dart format .
flutter analyze
flutter test
flutter build windows --debug
flutter build apk --debug
```

Tests cover database persistence/reopening, CRUD, category ordering, duplication,
validation and soft deletes; credit rules; meeting intervals, exceptions and gaps;
conflict review and save-anyway behavior; and populated desktop/mobile layouts,
including theme changes, resizing, history and planning navigation.

## Code layout

```text
lib/app/                          # Approved shell, navigation, themes
lib/features/class_schedule/
  data/                           # Drift schema, repository, reactive snapshot, demo
  domain/                         # Enums, drafts, schedule/credit/conflict functions
  providers/                      # Database/repository streams and clock
  presentation/                   # Dashboard card, full module, editors and views
lib/features/{tasks,shopping,spending}/  # Placeholders only
lib/shared/widgets/               # Shared placeholder components
```

The generated immutable Drift records serve as the data transfer objects used by
pure calculation functions. Domain logic has no widget dependencies; all writes
are centralized in the repository.

## Project documents

- `CODEX_CLASS_SCHEDULE_MODULE.md` — supplied implementation brief
- `docs/PROJECT_SCOPE.md` — scope and non-goals
- `docs/ARCHITECTURE_DECISIONS.md` — technical decisions
- `docs/CLASS_SCHEDULE_IMPLEMENTATION.md` — stage checkpoints and commit boundaries
