import 'package:html/parser.dart' as html_parser;

import '../domain/lms_types.dart';

class ElearnActionEvents {
  const ElearnActionEvents({
    required this.assignments,
    required this.accountScope,
    required this.ignoredUnknownEvents,
  });

  final List<LmsItem> assignments;
  final String accountScope;
  final int ignoredUnknownEvents;
}

class ElearnParser {
  static const baseUrl = 'https://elearn.nthu.edu.tw';

  ElearnActionEvents parseActionEvents(Map<String, Object?> payload) {
    final rawUserId = payload['userId'];
    final userId = rawUserId?.toString().trim() ?? '';
    if (userId.isEmpty || userId == '0' || userId == 'null') {
      throw const LmsSessionExpiredException(
        'eLearn did not expose a signed-in account. Sign in again.',
      );
    }

    final rawEvents = payload['events'];
    if (rawEvents is! List) {
      throw const LmsParseException(
        'eLearn returned an unexpected timeline response. No Tasks were changed.',
      );
    }

    final assignments = <LmsItem>[];
    var ignoredUnknownEvents = 0;
    final seenExternalIds = <String>{};

    for (final rawEvent in rawEvents) {
      if (rawEvent is! Map) {
        throw const LmsParseException(
          'eLearn returned a malformed timeline event.',
        );
      }
      final event = rawEvent.cast<Object?, Object?>();
      final moduleName = _string(event['modulename']).toLowerCase();
      if (moduleName != 'assign') {
        ignoredUnknownEvents++;
        continue;
      }

      final instance = _positiveInt(event['instance']);
      final eventId = _positiveInt(event['id']);
      final externalId = (instance ?? eventId)?.toString();
      if (externalId == null) {
        throw const LmsParseException(
          'eLearn returned an assignment without a stable identity.',
        );
      }

      // A Moodle assignment can occasionally expose more than one calendar
      // event. Timeline sync treats the assignment instance itself as the
      // stable external identity and keeps the first actionable event.
      if (!seenExternalIds.add(externalId)) continue;

      final title = _firstNonEmpty([
        _string(event['activityname']),
        _string(event['name']),
      ]);
      if (title.isEmpty) {
        throw const LmsParseException(
          'eLearn returned an assignment without a title.',
        );
      }

      final course = event['course'];
      final courseMap = course is Map
          ? course.cast<Object?, Object?>()
          : const <Object?, Object?>{};
      final courseName = _firstNonEmpty([
        _string(courseMap['fullname']),
        _string(courseMap['shortname']),
        _string(event['coursefullname']),
        _string(event['coursename']),
      ]);
      if (courseName.isEmpty) {
        throw const LmsParseException(
          'eLearn returned an assignment without its course name.',
        );
      }
      final courseId =
          _positiveInt(courseMap['id']) ?? _positiveInt(event['courseid']);

      final timesort =
          _positiveInt(event['timesort']) ?? _positiveInt(event['timestart']);
      if (timesort == null) {
        throw const LmsParseException(
          'eLearn returned an assignment without a valid deadline.',
        );
      }
      final dueAt = DateTime.fromMillisecondsSinceEpoch(
        timesort * 1000,
        isUtc: true,
      ).toLocal();

      final action = event['action'];
      final actionMap = action is Map
          ? action.cast<Object?, Object?>()
          : const <Object?, Object?>{};
      final url = _firstNonEmpty([
        _string(event['url']),
        _string(actionMap['url']),
      ]);
      final normalizedUrl = url.isEmpty
          ? '$baseUrl/calendar/view.php?view=upcoming'
          : _absoluteUrl(url);

      final description = _htmlToText(_string(event['description']));

      assignments.add(
        LmsItem(
          provider: LmsProvider.elearn,
          resourceType: LmsResourceType.homework,
          externalId: externalId,
          title: title,
          courseName: courseName,
          courseId: courseId?.toString(),
          dueAt: dueAt,
          duePrecision: LmsDuePrecision.dateTime,
          url: normalizedUrl,
          description: description,
        ),
      );
    }

    assignments.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return ElearnActionEvents(
      assignments: assignments,
      accountScope: 'user:$userId',
      ignoredUnknownEvents: ignoredUnknownEvents,
    );
  }

  int? _positiveInt(Object? value) {
    final parsed = switch (value) {
      int number => number,
      num number => number.toInt(),
      String text => int.tryParse(text),
      _ => null,
    };
    return parsed != null && parsed > 0 ? parsed : null;
  }

  String _string(Object? value) => value?.toString() ?? '';

  String _firstNonEmpty(Iterable<String> values) {
    for (final value in values) {
      final cleaned = _clean(value);
      if (cleaned.isNotEmpty) return cleaned;
    }
    return '';
  }

  String _absoluteUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return value;
    if (uri.hasScheme) return uri.toString();
    if (value.startsWith('/')) return '$baseUrl$value';
    return '$baseUrl/$value';
  }

  String _htmlToText(String value) {
    if (value.trim().isEmpty) return '';
    return _clean(html_parser.parseFragment(value).text ?? '');
  }

  String _clean(String value) => value.replaceAll(RegExp(r'\s+'), ' ').trim();
}
