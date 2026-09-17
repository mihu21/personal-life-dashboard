import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/lms/data/elearn_parser.dart';
import 'package:personal_life_dashboard/features/lms/domain/lms_types.dart';

void main() {
  final parser = ElearnParser();

  Map<String, Object?> payload({
    Object? userId = 24680,
    List<Object?>? events,
  }) => {
    'kind': 'ok',
    'userId': userId,
    'events':
        events ??
        [
          {
            'id': 901,
            'name': 'Programming Assignment 1 (Due date)',
            'activityname': 'Programming Assignment 1',
            'description': '<p>Submit <strong>one ZIP</strong> file.</p>',
            'courseid': 77,
            'modulename': 'assign',
            'instance': 321,
            'timesort': 1790092800,
            'url': 'https://elearn.nthu.edu.tw/mod/assign/view.php?id=555',
            'course': {
              'id': 77,
              'fullname': 'Introduction to Computer Networks',
              'shortname': 'CS2100',
            },
            'action': {
              'name': 'Add submission',
              'url': 'https://elearn.nthu.edu.tw/mod/assign/view.php?id=555',
            },
          },
        ],
  };

  test('parses Moodle assignment action events into normalized LMS items', () {
    final parsed = parser.parseActionEvents(payload());

    expect(parsed.accountScope, 'user:24680');
    expect(parsed.ignoredUnknownEvents, 0);
    expect(parsed.assignments, hasLength(1));
    final item = parsed.assignments.single;
    expect(item.provider, LmsProvider.elearn);
    expect(item.resourceType, LmsResourceType.homework);
    expect(item.externalId, '321');
    expect(item.courseId, '77');
    expect(item.courseName, 'Introduction to Computer Networks');
    expect(item.title, 'Programming Assignment 1');
    expect(item.description, 'Submit one ZIP file.');
    expect(item.dueAt.toUtc(), DateTime.utc(2026, 9, 22, 16));
    expect(item.duePrecision, LmsDuePrecision.dateTime);
    expect(
      item.url,
      'https://elearn.nthu.edu.tw/mod/assign/view.php?id=555',
    );
  });

  test('ignores non-assignment timeline actions', () {
    final parsed = parser.parseActionEvents(
      payload(
        events: [
          {
            'id': 1,
            'name': 'Quiz 1',
            'modulename': 'quiz',
            'instance': 8,
            'timesort': 1790092800,
          },
        ],
      ),
    );
    expect(parsed.assignments, isEmpty);
    expect(parsed.ignoredUnknownEvents, 1);
  });

  test('deduplicates multiple calendar events for one assignment instance', () {
    final base = (payload()['events']! as List).single as Map<String, Object?>;
    final parsed = parser.parseActionEvents(
      payload(
        events: [
          base,
          {...base, 'id': 902, 'timesort': 1790265540},
        ],
      ),
    );
    expect(parsed.assignments, hasLength(1));
    expect(parsed.assignments.single.externalId, '321');
  });

  test('missing signed-in Moodle account is an expired session', () {
    expect(
      () => parser.parseActionEvents(payload(userId: 0)),
      throwsA(isA<LmsSessionExpiredException>()),
    );
  });

  test('malformed timeline response fails safely instead of looking empty', () {
    expect(
      () => parser.parseActionEvents({'userId': 123, 'events': 'bad'}),
      throwsA(isA<LmsParseException>()),
    );
  });

  test('relative eLearn URLs are normalized to the eLearn origin', () {
    final event = (payload()['events']! as List).single as Map<String, Object?>;
    final parsed = parser.parseActionEvents(
      payload(events: [{...event, 'url': '/mod/assign/view.php?id=555'}]),
    );
    expect(
      parsed.assignments.single.url,
      'https://elearn.nthu.edu.tw/mod/assign/view.php?id=555',
    );
  });
}
