import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/lms/data/eeclass_parser.dart';
import 'package:personal_life_dashboard/features/lms/domain/lms_types.dart';

void main() {
  final parser = EeclassParser();

  String fixture(String name) =>
      File('test/fixtures/eeclass/$name').readAsStringSync();

  test('parses verified eeclass homework rows from Recent Events', () {
    final parsed = parser.parseRecentEvents(
      fixture('recent_events_with_assignments.html'),
    );

    expect(parsed.ignoredUnknownEvents, 0);
    expect(parsed.accountScope, 'user:38735');
    expect(parsed.assignments, hasLength(2));
    final first = parsed.assignments.first;
    expect(first.provider, LmsProvider.eeclass);
    expect(first.resourceType, LmsResourceType.homework);
    expect(first.externalId, '68172');
    expect(first.courseId, '33864');
    expect(first.title, 'week3_class_sheet_question_submit');
    expect(first.courseName, '計算機結構Computer Architecture');
    expect(first.dueAt, DateTime(2026, 9, 18, 12));
    expect(first.duePrecision, LmsDuePrecision.dateTime);
    expect(first.url, 'https://eeclass.nthu.edu.tw/course/homework/68172');
  });

  test('valid empty Recent Events is not a parsing failure', () {
    final parsed = parser.parseRecentEvents(
      fixture('recent_events_empty.html'),
    );
    expect(parsed.assignments, isEmpty);
    expect(parsed.ignoredUnknownEvents, 0);
  });

  test('login page is classified as an expired session', () {
    expect(
      () => parser.parseRecentEvents(fixture('login_page.html')),
      throwsA(isA<LmsSessionExpiredException>()),
    );
  });

  test('unexpected eeclass markup is a parse error, not zero assignments', () {
    expect(
      () => parser.parseRecentEvents(fixture('malformed_recent_events.html')),
      throwsA(isA<LmsParseException>()),
    );
  });

  test('localized table headings still parse by verified row structure', () {
    const html = '''
      <a href="/user/12345/info">Personal info</a>
      <table id="recentEventTable">
        <thead><tr><th>主旨</th><th>來源</th><th>期限</th></tr></thead>
        <tbody><tr>
          <td><a href="/course/homework/70001">作業一</a></td>
          <td><a href="/course/33999">測試課程</a></td>
          <td><div title="2026-10-02 23:59:59">2026-10-02</div></td>
        </tr></tbody>
      </table>
    ''';
    final parsed = parser.parseRecentEvents(html);
    expect(parsed.assignments, hasLength(1));
    expect(parsed.assignments.single.externalId, '70001');
    expect(parsed.assignments.single.dueAt, DateTime(2026, 10, 2, 23, 59));
  });

  test('unverified event types are counted and ignored', () {
    const html = '''
      <a href="/user/12345/info">Personal info</a>
      <table id="recentEventTable">
        <thead><tr><th>Subject</th><th>Source</th><th>Term</th></tr></thead>
        <tbody><tr>
          <td><a href="/course/something/99">Unverified item</a></td>
          <td>System event without a course link</td>
          <td><div title="2026-10-01 09:30:00">2026-10-01</div></td>
        </tr></tbody>
      </table>
    ''';
    final parsed = parser.parseRecentEvents(html);
    expect(parsed.assignments, isEmpty);
    expect(parsed.ignoredUnknownEvents, 1);
  });

  test('missing signed-in account identity fails safely', () {
    const html = '''
      <table id="recentEventTable">
        <thead><tr><th>Subject</th><th>Source</th><th>Term</th></tr></thead>
        <tbody></tbody>
      </table>
    ''';
    expect(
      () => parser.parseRecentEvents(html),
      throwsA(isA<LmsParseException>()),
    );
  });

  test('preview snapshot JSON round trip keeps assignment identity', () {
    final parsed = parser.parseRecentEvents(
      fixture('recent_events_with_assignments.html'),
    );
    final original = LmsPreviewSnapshot(
      items: parsed.assignments,
      accountScope: parsed.accountScope,
      ignoredUnknownEvents: parsed.ignoredUnknownEvents,
      syncedAt: DateTime(2026, 9, 16, 13, 42),
    );
    final restored = LmsPreviewSnapshot.fromJson(original.toJson());
    expect(restored.syncedAt, original.syncedAt);
    expect(restored.accountScope, 'user:38735');
    expect(
      restored.items.singleWhere((item) => item.externalId == '67426').title,
      'HW1',
    );
  });
}
