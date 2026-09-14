# NTHU Class Schedule Rework — Handoff

This snapshot contains the follow-up fixes after the initial NTHU handoff.

## Main fixes

- Fixed nullable `DateTime` clock initializer analyzer errors in `nthu_catalog_repository.dart`.
- Updated the academic test fixture to provide `ClassMeeting.needsReview`.
- Cleaned the catalog parser's flow-control braces.
- Added the official 11420 historical archive URL.
- Added NTHU-term inference for older semester records.

## Course-adding UX

Adding a current-semester class no longer requires navigating through Academic Records and multiple tabs.

The normal workflow is now:

1. Click `+` directly on the Class Schedule dashboard card, or `Add class` in the full Schedule view.
2. The app opens the official NTHU course search for that semester automatically.
3. Search and select a course.
4. Choose the required personal graduation category in the same dialog.
5. Click `Add course`.
6. The dialog stays open so more classes can be added immediately; click `Done` when finished.

Manual course entry remains in the overflow menu as a fallback, not the primary path.

## Other UX changes included

- Desktop Class Schedule module uses Schedule / Graduation / History / Planning navigation.
- Graduation requirements can be edited from the Graduation page in one editor, including the overall target and per-category minimum credits.
- Categories can also be created/edited while importing an NTHU course.
- Manual meetings and one-off reschedules use NTHU period codes instead of arbitrary HH:mm times.
- Week view uses NTHU timetable rows (`1, 2, 3, 4, n, 5 ... d`).
- Today view displays NTHU period codes prominently.

## Verification

Run on the development machine:

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test
flutter build windows --debug
```

This handoff was edited in an environment without a Flutter SDK, so the final snapshot has not been re-run through those commands here.
