import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../domain/lms_types.dart';

class EeclassRecentEvents {
  const EeclassRecentEvents({
    required this.assignments,
    required this.accountScope,
    required this.ignoredUnknownEvents,
  });

  final List<LmsItem> assignments;
  final String accountScope;
  final int ignoredUnknownEvents;
}

class EeclassParser {
  static const baseUrl = 'https://eeclass.nthu.edu.tw';

  EeclassRecentEvents parseRecentEvents(String html) {
    final document = html_parser.parse(html);
    if (_looksLikeLoginPage(document)) {
      throw const LmsSessionExpiredException();
    }

    final table = document.querySelector('#recentEventTable');
    if (table == null) {
      throw const LmsParseException(
        'eeclass returned an unexpected Recent Event page. No assignments were removed.',
      );
    }

    final headings = table.querySelectorAll('thead th');
    if (headings.length < 3) {
      throw const LmsParseException(
        'eeclass changed the Recent Event table format. No assignments were removed.',
      );
    }

    final accountScope = _accountScope(document);

    final assignments = <LmsItem>[];
    var ignoredUnknownEvents = 0;
    for (final row in table.querySelectorAll('tbody tr')) {
      final cells = row.querySelectorAll('td');
      if (cells.length < 3) {
        throw const LmsParseException(
          'eeclass returned a malformed Recent Event row.',
        );
      }
      final subjectLink = cells[0].querySelector('a');
      if (subjectLink == null) {
        throw const LmsParseException(
          'eeclass returned a Recent Event row without an item link.',
        );
      }

      final href = subjectLink.attributes['href']?.trim() ?? '';
      final homeworkMatch = RegExp(
        r'^/course/homework/(\d+)$',
      ).firstMatch(href);
      if (homeworkMatch == null) {
        ignoredUnknownEvents++;
        continue;
      }

      final courseLink = cells[1].querySelector('a');
      if (courseLink == null) {
        throw const LmsParseException(
          'eeclass returned an assignment without its course link.',
        );
      }

      final title = _clean(subjectLink.text);
      final courseName = _clean(courseLink.text);
      if (title.isEmpty || courseName.isEmpty) {
        throw const LmsParseException(
          'eeclass returned a Recent Event with a missing title or course name.',
        );
      }

      final due = _parseDueCell(cells[2]);
      final courseHref = courseLink.attributes['href']?.trim();
      final courseMatch = courseHref == null
          ? null
          : RegExp(r'^/course/(\d+)$').firstMatch(courseHref);

      assignments.add(
        LmsItem(
          provider: LmsProvider.eeclass,
          resourceType: LmsResourceType.homework,
          externalId: homeworkMatch.group(1)!,
          title: title,
          courseName: courseName,
          courseId: courseMatch?.group(1),
          dueAt: due.$1,
          duePrecision: due.$2,
          url: '$baseUrl$href',
        ),
      );
    }

    assignments.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return EeclassRecentEvents(
      assignments: assignments,
      accountScope: accountScope,
      ignoredUnknownEvents: ignoredUnknownEvents,
    );
  }

  String _accountScope(Document document) {
    for (final link in document.querySelectorAll('a[href]')) {
      final href = link.attributes['href']?.trim();
      if (href == null) continue;
      final match = RegExp(r'^/user/(\d+)/info$').firstMatch(href);
      if (match != null) return 'user:${match.group(1)}';
    }
    throw const LmsParseException(
      'eeclass did not expose the signed-in account identity. No Tasks were changed.',
    );
  }

  bool _looksLikeLoginPage(Document document) {
    final canonical = document
        .querySelector('link[rel="canonical"]')
        ?.attributes['href'];
    if (canonical != null && canonical.contains('/index/login')) return true;
    if (document.querySelector('form[action*="/index/login"]') != null) {
      return true;
    }
    final title = document.querySelector('title')?.text.toLowerCase() ?? '';
    return title.contains('login') &&
        document.querySelector('#recentEventTable') == null;
  }

  (DateTime, LmsDuePrecision) _parseDueCell(Element cell) {
    final precise = cell.querySelector('[title]')?.attributes['title']?.trim();
    if (precise != null && precise.isNotEmpty) {
      final match = RegExp(
        r'^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})(?::(\d{2}))?$',
      ).firstMatch(precise);
      if (match == null) {
        throw const LmsParseException(
          'eeclass returned an assignment deadline in an unknown format.',
        );
      }
      return (
        DateTime(
          int.parse(match.group(1)!),
          int.parse(match.group(2)!),
          int.parse(match.group(3)!),
          int.parse(match.group(4)!),
          int.parse(match.group(5)!),
        ),
        LmsDuePrecision.dateTime,
      );
    }

    final visible = _clean(cell.text);
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(visible);
    if (match == null) {
      throw const LmsParseException(
        'eeclass returned an assignment deadline in an unknown format.',
      );
    }
    return (
      DateTime(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      ),
      LmsDuePrecision.dateOnly,
    );
  }

  String _clean(String value) => value.replaceAll(RegExp(r'\s+'), ' ').trim();
}
