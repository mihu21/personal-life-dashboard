# Personal Life Dashboard

A personal dashboard for Windows and Android, built with Flutter, Material 3,
and Riverpod. The current implementation is an **application shell only**.

## What is implemented

- At widths of 900 logical pixels and above: a 40-pixel Today bar at the top
  and four equal panels in a 2×2 dashboard (Class Schedule,
  Tasks & Reminders, Shopping, Spending). The grid fills the available viewport
  width and height with 12-pixel margins and gaps; desktop content does not scroll.
- At narrower widths: separate placeholder pages with bottom navigation for
  Schedule, Tasks, Shopping, and Spending. This also supports narrow Windows
  windows and Android landscape layouts.
- Light, dark, and system themes. On desktop, open Settings at the right end of
  the Today bar to choose a theme. Mobile retains its top-right theme menu.
- Desktop panels resize with the window and use compact placeholder content.
  Narrow/mobile pages retain their scrollable layout and original presentation.

All five dashboard areas are explicitly marked as coming soon. There is no
sample course or financial data, SQLite/Drift setup, domain model, graduation
tracking, or module business logic. Tab and theme choices are transient and reset
when the app restarts; the theme defaults to the system setting.

## Requirements

Developed with Flutter 3.44.2 and Dart 3.12.2. Use a compatible stable Flutter SDK
with Dart 3.12.2 or later. Put Flutter's `bin` directory on your PATH.

- Windows: Visual Studio with the **Desktop development with C++** workload and
  Windows SDK.
- Android: Android SDK, accepted SDK licenses, and an Android emulator or a
  physical device with USB debugging enabled.

Check your toolchain with `flutter doctor -v`.

## Run on Windows

From PowerShell:

```powershell
cd C:\Users\MiHu\Documents\personal-life-dashboard
flutter pub get
flutter run -d windows
```

## Run on Android

Start an Android emulator or connect your device, then:

```powershell
cd C:\Users\MiHu\Documents\personal-life-dashboard
flutter pub get
flutter devices
flutter run -d <android-device-id>
```

Replace `<android-device-id>` with the Android ID printed by `flutter devices`
(for example, `flutter run -d emulator-5554`). To start a configured emulator:

```powershell
flutter emulators
flutter emulators --launch <emulator-id>
```

## Validation

```powershell
dart format .
flutter analyze
flutter test
```

Widget tests cover desktop placement, equal panel sizes and viewport containment
from 900×320 to 2560×1440, absence of desktop scrolling, mobile navigation, theme
switching, selection across resizing, and enlarged text.

## Code layout

```text
lib/
  main.dart                       # ProviderScope and startup
  app/
    dashboard_app.dart            # MaterialApp
    shell/                        # Responsive composition and transient UI state
    theme/                        # Material 3 light/dark themes
  features/
    class_schedule/presentation/  # Future schedule presentation entry point
    tasks/presentation/           # Placeholder only
    shopping/presentation/        # Placeholder only
    spending/presentation/        # Placeholder only
  shared/widgets/                 # Reusable placeholder presentation
```

Future Class Schedule work should replace its presentation entry point, adding
feature-owned domain/data layers and repository providers when that work is
requested. Keep business logic out of the shell and shared widgets. SQLite,
Drift, stable identifiers, semester history, and graduation accounting remain
future decisions to implement according to the architecture documents. Other
modules remain isolated until their own design phase.

## Project documents

- `docs/PROJECT_SCOPE.md` — long-term product scope and boundaries
- `docs/ARCHITECTURE_DECISIONS.md` — technical decisions and shell boundaries

The previously referenced `CODEX_CLASS_SCHEDULE_MODULE.md` is not present in this
checkout. Its detailed brief should be supplied before implementing that module.
Cloud synchronization remains out of scope.
