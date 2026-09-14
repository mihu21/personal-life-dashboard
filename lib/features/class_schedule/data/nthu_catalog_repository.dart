import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import '../domain/nthu_academic.dart';
import 'academic_database.dart';

const nthuCatalogLandingUrl =
    'https://curricul.site.nthu.edu.tw/p/404-1208-111356.php?Lang=zh-tw';
const nthuCurrentJsonUrl =
    'https://www.ccxp.nthu.edu.tw/ccxp/INQUIRE/JH/OPENDATA/open_course_data.json';
const nthu113ArchiveUrl =
    'https://curricul.site.nthu.edu.tw/var/file/208/1208/img/1657/111all-113all_courses_redo.xlsx';
const nthu11410ArchiveUrl =
    'https://curricul.site.nthu.edu.tw/var/file/208/1208/img/1350/11410_course_data_fin.xlsx';
const nthu11420ArchiveUrl =
    'https://curricul.site.nthu.edu.tw/var/file/208/1208/img/1657/11420courses_1150603.xlsx';

typedef CatalogDownloader = Future<Uint8List> Function(Uri uri);

enum NthuCatalogSearchField { all, name, code, professor, department }

class NthuCatalogUnavailable implements Exception {
  const NthuCatalogUnavailable(this.message);
  final String message;

  @override
  String toString() => message;
}

class NthuCatalogPayload {
  const NthuCatalogPayload({
    required this.term,
    required this.sourceType,
    required this.sourceUrl,
    required this.fetchedAt,
    required this.courses,
    this.sourceUpdatedAt,
  });

  final NthuTerm term;
  final NthuCatalogSourceType sourceType;
  final String sourceUrl;
  final DateTime fetchedAt;
  final DateTime? sourceUpdatedAt;
  final List<NthuCatalogCourseModel> courses;
}

abstract interface class NthuCatalogSource {
  bool supports(NthuTerm term, DateTime now);
  Future<NthuCatalogPayload> load(NthuTerm term);
}

class NthuCurrentJsonSource implements NthuCatalogSource {
  NthuCurrentJsonSource({
    CatalogDownloader? downloader,
    DateTime Function()? now,
  }) : downloader = downloader ?? downloadOfficialCatalog,
       _now = now ?? (() => DateTime.now());

  final CatalogDownloader downloader;
  final DateTime Function() _now;

  @override
  bool supports(NthuTerm term, DateTime now) => term == NthuTerm.current(now);

  @override
  Future<NthuCatalogPayload> load(NthuTerm term) async {
    final bytes = await downloader(Uri.parse(nthuCurrentJsonUrl));
    final courses = parseCurrentJson(bytes, requestedTermCode: term.code);
    if (courses.isEmpty) {
      throw NthuCatalogUnavailable(
        'The official latest feed does not currently contain ${term.displayName}.',
      );
    }
    return NthuCatalogPayload(
      term: term,
      sourceType: NthuCatalogSourceType.currentJson,
      sourceUrl: nthuCurrentJsonUrl,
      fetchedAt: _now(),
      courses: courses,
    );
  }

  static List<NthuCatalogCourseModel> parseCurrentJson(
    List<int> bytes, {
    required String requestedTermCode,
  }) {
    final term = NthuTerm(requestedTermCode);
    final decoded = jsonDecode(decodeNthuJson(bytes));
    if (decoded is! List) {
      throw const FormatException('The official NTHU JSON root is not a list.');
    }
    return [
      for (final value in decoded)
        if (value is Map)
          ..._normalizeCurrentRecord(
            value.map((key, value) => MapEntry('$key', '${value ?? ''}')),
            term,
          ),
    ];
  }
}

class NthuHistoricalArchiveSource implements NthuCatalogSource {
  NthuHistoricalArchiveSource({
    CatalogDownloader? downloader,
    DateTime Function()? now,
  }) : downloader = downloader ?? downloadOfficialCatalog,
       _now = now ?? (() => DateTime.now());

  final CatalogDownloader downloader;
  final DateTime Function() _now;

  static String? officialUrlFor(NthuTerm term) => switch (term.code) {
    '11310' || '11320' => nthu113ArchiveUrl,
    '11410' => nthu11410ArchiveUrl,
    '11420' => nthu11420ArchiveUrl,
    _ => null,
  };

  @override
  bool supports(NthuTerm term, DateTime now) =>
      term != NthuTerm.current(now) && officialUrlFor(term) != null;

  @override
  Future<NthuCatalogPayload> load(NthuTerm term) async {
    final url = officialUrlFor(term);
    if (url == null) {
      throw NthuCatalogUnavailable(
        'No stable official archive download is configured for ${term.displayName}. '
        'Use an official NTHU archive file from the catalog landing page.',
      );
    }
    final bytes = await downloader(Uri.parse(url));
    return parseArchive(
      bytes,
      term: term,
      sourceUrl: url,
      sourceType: NthuCatalogSourceType.historicalArchive,
      fetchedAt: _now(),
    );
  }

  static NthuCatalogPayload parseArchive(
    List<int> bytes, {
    required NthuTerm term,
    required String sourceUrl,
    required NthuCatalogSourceType sourceType,
    DateTime? fetchedAt,
  }) {
    final rows = _readXlsxRows(bytes);
    final courses = <NthuCatalogCourseModel>[];
    for (final row in rows) {
      final rowTerm = _first(row, ['學年期', '學期', 'termCode', 'term_code']);
      final officialCode = _first(row, ['科號', '科號/組別', '課程代碼']);
      final identifierTerm = RegExp(
        r'^\s*(\d{5})',
      ).firstMatch(officialCode)?.group(1);
      final exactTerm = rowTerm.isNotEmpty ? rowTerm.trim() : identifierTerm;
      if (exactTerm != term.code || identifierTerm != term.code) {
        continue;
      }
      final schedule = _first(row, ['上課時間', '教室與上課時間']);
      final location = _first(row, ['教室', '上課教室']);
      final model = _normalize(
        term: term,
        officialCode: officialCode,
        chineseName: _first(row, ['中文課名', '課程中文名稱']),
        englishName: _first(row, ['英文課名', '課程英文名稱']),
        credits: _first(row, ['學分數', '學分']),
        language: _first(row, ['語言', '授課語言']),
        instructors: _first(row, ['教師', '授課教師']),
        notes: _first(row, ['備註']),
        cancellation: _first(row, ['停開註記', '停課註記']),
        restrictions: _first(row, ['擋修說明', '課程限制說明']),
        requiredElective: _first(row, ['列必選修系所班別', '必選修說明']),
        department: _first(row, ['系所全名', '開課單位']),
        subject: _first(row, ['代碼', '課程字頭']),
        schedule: schedule,
        location: location,
        meetings: parseNthuSchedule(schedule, location: location),
      );
      if (model != null) {
        courses.add(model);
      }
    }
    if (courses.isEmpty) {
      throw NthuCatalogUnavailable(
        'The selected official archive contains no exact ${term.code} records.',
      );
    }
    return NthuCatalogPayload(
      term: term,
      sourceType: sourceType,
      sourceUrl: sourceUrl,
      fetchedAt: fetchedAt ?? DateTime.now(),
      courses: courses,
    );
  }
}

class NthuCatalogRepository {
  NthuCatalogRepository(
    this.db, {
    List<NthuCatalogSource>? sources,
    DateTime Function()? now,
  }) : sources =
           sources ?? [NthuCurrentJsonSource(), NthuHistoricalArchiveSource()],
       _now = now ?? (() => DateTime.now());

  final AcademicDatabase db;
  final List<NthuCatalogSource> sources;
  final DateTime Function() _now;
  static const _uuid = Uuid();

  Future<NthuCatalogTerm?> cachedTerm(String termCode) => (db.select(
    db.nthuCatalogTerms,
  )..where((table) => table.termCode.equals(termCode))).getSingleOrNull();

  Future<List<NthuCatalogCourseModel>> search(
    String termCode, {
    String query = '',
    NthuCatalogSearchField field = NthuCatalogSearchField.all,
    String? department,
    String? language,
    String? dayCode,
  }) async {
    NthuTerm(termCode);
    final rows =
        await (db.select(db.nthuCatalogCourses)..where(
              (table) =>
                  table.termCode.equals(termCode) & table.deletedAt.isNull(),
            ))
            .get();
    final ids = rows.map((row) => row.id).toSet();
    final meetingRows = ids.isEmpty
        ? <NthuCatalogMeeting>[]
        : await (db.select(db.nthuCatalogMeetings)..where(
                (table) =>
                    table.catalogCourseId.isIn(ids) & table.deletedAt.isNull(),
              ))
              .get();
    final meetingsByCourse = <String, List<NthuCatalogMeeting>>{};
    for (final meeting in meetingRows) {
      meetingsByCourse
          .putIfAbsent(meeting.catalogCourseId, () => [])
          .add(meeting);
    }
    final result = rows
        .map((row) {
          final meetings = meetingsByCourse[row.id] ?? const [];
          return NthuCatalogCourseModel(
            id: row.id,
            termCode: row.termCode,
            officialCourseCode: row.officialCourseCode,
            chineseName: row.chineseName,
            englishName: row.englishName,
            credits: row.credits,
            teachingLanguage: row.teachingLanguage,
            instructorNames: _splitStored(row.instructorNames),
            notes: row.notes,
            cancellationFlag: row.cancellationFlag,
            restrictions: row.restrictions,
            requiredElectiveMetadata: row.requiredElectiveMetadata,
            department: row.department,
            subject: row.subject,
            rawScheduleText: row.rawScheduleText,
            rawLocationText: row.rawLocationText,
            meetings: [
              for (final meeting in meetings)
                NthuCatalogMeetingModel(
                  dayCode: meeting.dayCode,
                  startPeriod: meeting.startPeriod,
                  endPeriod: meeting.endPeriod,
                  scheduleCode: meeting.scheduleCode,
                  location: meeting.location,
                ),
            ],
          );
        })
        .where((course) {
          return _matchesCatalogSearch(course, query, field) &&
              (department == null || course.department == department) &&
              (language == null || course.teachingLanguage == language) &&
              (dayCode == null ||
                  course.meetings.any((meeting) => meeting.dayCode == dayCode));
        })
        .toList();
    result.sort((a, b) => a.officialCourseCode.compareTo(b.officialCourseCode));
    return result;
  }

  bool _matchesCatalogSearch(
    NthuCatalogCourseModel course,
    String query,
    NthuCatalogSearchField field,
  ) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    final values = switch (field) {
      NthuCatalogSearchField.all => <String>[
        course.officialCourseCode,
        course.chineseName,
        course.englishName,
        course.instructorNames.join(' '),
        course.department,
      ],
      NthuCatalogSearchField.name => <String>[
        course.chineseName,
        course.englishName,
      ],
      NthuCatalogSearchField.code => <String>[
        course.officialCourseCode,
        course.subject,
      ],
      NthuCatalogSearchField.professor => <String>[
        course.instructorNames.join(' '),
      ],
      NthuCatalogSearchField.department => <String>[course.department],
    };
    return values.any((value) => value.toLowerCase().contains(needle));
  }

  Future<NthuCatalogPayload> refresh(NthuTerm term) async {
    final source = sources
        .where((candidate) => candidate.supports(term, _now()))
        .firstOrNull;
    if (source == null) {
      throw NthuCatalogUnavailable(
        'Official catalog unavailable for ${term.displayName}. Cached data, if any, remains usable. '
        'You can import an official NTHU archive file manually.',
      );
    }
    final payload = await source.load(term);
    await cache(payload);
    return payload;
  }

  Future<NthuCatalogPayload> importOfficialArchive(
    List<int> bytes,
    NthuTerm term,
  ) async {
    final payload = NthuHistoricalArchiveSource.parseArchive(
      bytes,
      term: term,
      sourceUrl: nthuCatalogLandingUrl,
      sourceType: NthuCatalogSourceType.manualArchive,
      fetchedAt: _now(),
    );
    await cache(payload);
    return payload;
  }

  Future<void> cache(NthuCatalogPayload payload) => db.transaction(() async {
    final now = payload.fetchedAt;
    await db
        .into(db.nthuCatalogTerms)
        .insertOnConflictUpdate(
          NthuCatalogTermsCompanion.insert(
            id: payload.term.code,
            termCode: payload.term.code,
            displayName: payload.term.displayName,
            fetchedAt: now,
            sourceType: payload.sourceType.name,
            sourceUrl: payload.sourceUrl,
            sourceUpdatedAt: Value(payload.sourceUpdatedAt),
            updatedAt: Value(now),
          ),
        );
    await (db.update(
      db.nthuCatalogCourses,
    )..where((table) => table.termCode.equals(payload.term.code))).write(
      NthuCatalogCoursesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    for (final course in payload.courses) {
      if (course.termCode != payload.term.code) {
        continue;
      }
      await db
          .into(db.nthuCatalogCourses)
          .insertOnConflictUpdate(
            NthuCatalogCoursesCompanion.insert(
              id: course.id,
              termCode: course.termCode,
              officialCourseCode: course.officialCourseCode,
              chineseName: course.chineseName,
              englishName: course.englishName,
              credits: course.credits,
              teachingLanguage: course.teachingLanguage,
              instructorNames: course.instructorNames.join('\n'),
              notes: course.notes,
              cancellationFlag: course.cancellationFlag,
              restrictions: course.restrictions,
              requiredElectiveMetadata: course.requiredElectiveMetadata,
              department: course.department,
              subject: course.subject,
              rawScheduleText: course.rawScheduleText,
              rawLocationText: course.rawLocationText,
              fetchedAt: now,
              deletedAt: const Value(null),
              updatedAt: Value(now),
            ),
          );
      await (db.delete(
        db.nthuCatalogMeetings,
      )..where((table) => table.catalogCourseId.equals(course.id))).go();
      for (final meeting in course.meetings) {
        await db
            .into(db.nthuCatalogMeetings)
            .insert(
              NthuCatalogMeetingsCompanion.insert(
                id: _uuid.v4(),
                catalogCourseId: course.id,
                dayCode: meeting.dayCode,
                startPeriod: meeting.startPeriod,
                endPeriod: meeting.endPeriod,
                scheduleCode: meeting.scheduleCode,
                location: meeting.location,
              ),
            );
      }
    }
  });
}

Future<Uint8List> downloadOfficialCatalog(Uri uri) async {
  if (uri.scheme != 'https' || !uri.host.endsWith('nthu.edu.tw')) {
    throw ArgumentError('Only official NTHU HTTPS sources are allowed.');
  }
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
  try {
    final request = await client.getUrl(uri);
    request.headers.set(
      HttpHeaders.userAgentHeader,
      'PersonalLifeDashboard/0.1',
    );
    final response = await request.close().timeout(const Duration(seconds: 45));
    if (response.statusCode != HttpStatus.ok) {
      throw NthuCatalogUnavailable(
        'Official NTHU catalog returned HTTP ${response.statusCode}.',
      );
    }
    final builder = BytesBuilder(copy: false);
    await for (final chunk in response) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  } on NthuCatalogUnavailable {
    rethrow;
  } catch (error) {
    throw NthuCatalogUnavailable(
      'Could not download the official NTHU catalog: $error',
    );
  } finally {
    client.close(force: true);
  }
}

String decodeNthuJson(List<int> source) {
  final bytes = Uint8List.fromList(source);
  if (bytes.length >= 2 && bytes[0] == 0xff && bytes[1] == 0xfe) {
    return _decodeUtf16(bytes.sublist(2), littleEndian: true);
  }
  if (bytes.length >= 2 && bytes[0] == 0xfe && bytes[1] == 0xff) {
    return _decodeUtf16(bytes.sublist(2), littleEndian: false);
  }
  final sample = bytes.take(64).toList();
  final oddNulls = [
    for (var i = 1; i < sample.length; i += 2) sample[i],
  ].where((value) => value == 0).length;
  final evenNulls = [
    for (var i = 0; i < sample.length; i += 2) sample[i],
  ].where((value) => value == 0).length;
  if (oddNulls > sample.length ~/ 8) {
    return _decodeUtf16(bytes, littleEndian: true);
  }
  if (evenNulls > sample.length ~/ 8) {
    return _decodeUtf16(bytes, littleEndian: false);
  }
  return utf8.decode(bytes, allowMalformed: false).replaceFirst('\ufeff', '');
}

String _decodeUtf16(Uint8List bytes, {required bool littleEndian}) {
  if (bytes.length.isOdd) {
    throw const FormatException('Invalid UTF-16 byte length.');
  }
  final units = <int>[];
  for (var i = 0; i < bytes.length; i += 2) {
    units.add(
      littleEndian
          ? bytes[i] | bytes[i + 1] << 8
          : bytes[i] << 8 | bytes[i + 1],
    );
  }
  return String.fromCharCodes(units).replaceFirst('\ufeff', '');
}

Iterable<NthuCatalogCourseModel> _normalizeCurrentRecord(
  Map<String, String> row,
  NthuTerm term,
) sync* {
  final officialCode = row['科號']?.trim() ?? '';
  if (!officialCode.startsWith(term.code)) {
    return;
  }
  final roomSchedule = row['教室與上課時間'] ?? '';
  final meetings = <NthuCatalogMeetingModel>[];
  final rooms = <String>[];
  for (final line in const LineSplitter().convert(roomSchedule)) {
    final parts = line.split('\t').map((part) => part.trim()).toList();
    if (parts.every((part) => part.isEmpty)) {
      continue;
    }
    final schedule = parts.length > 1 ? parts.last : parts.first;
    final room = parts.length > 1 ? parts.take(parts.length - 1).join(' ') : '';
    if (room.isNotEmpty) {
      rooms.add(room);
    }
    meetings.addAll(parseNthuSchedule(schedule, location: room));
  }
  final model = _normalize(
    term: term,
    officialCode: officialCode,
    chineseName: row['課程中文名稱'] ?? '',
    englishName: row['課程英文名稱'] ?? '',
    credits: row['學分數'] ?? '',
    language: row['授課語言'] ?? '',
    instructors: row['授課教師'] ?? '',
    notes: row['備註'] ?? '',
    cancellation: row['停開註記'] ?? '',
    restrictions: [
      row['擋修說明'],
      row['課程限制說明'],
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join('\n'),
    requiredElective: row['必選修說明'] ?? '',
    department: [row['系所全名'], row['開課單位'], row['開課單位名稱'], row['開課系所']]
        .whereType<String>()
        .map((value) => value.trim())
        .firstWhere(
          (value) => value.isNotEmpty,
          orElse: () => _departmentFromCode(officialCode, term.code),
        ),
    subject: _departmentFromCode(officialCode, term.code),
    schedule: roomSchedule,
    location: rooms.toSet().join(' / '),
    meetings: meetings,
  );
  if (model != null) {
    yield model;
  }
}

NthuCatalogCourseModel? _normalize({
  required NthuTerm term,
  required String officialCode,
  required String chineseName,
  required String englishName,
  required String credits,
  required String language,
  required String instructors,
  required String notes,
  required String cancellation,
  required String restrictions,
  required String requiredElective,
  required String department,
  required String subject,
  required String schedule,
  required String location,
  required List<NthuCatalogMeetingModel> meetings,
}) {
  final creditValue = double.tryParse(credits.trim());
  if (!officialCode.trim().startsWith(term.code) ||
      creditValue == null ||
      creditValue < 0 ||
      chineseName.trim().isEmpty && englishName.trim().isEmpty) {
    return null;
  }
  final normalizedCode = officialCode.trim().replaceAll(RegExp(r'\s+'), ' ');
  return NthuCatalogCourseModel(
    id: '${term.code}:$normalizedCode',
    termCode: term.code,
    officialCourseCode: normalizedCode,
    chineseName: chineseName.trim(),
    englishName: englishName.trim(),
    credits: creditValue,
    teachingLanguage: language.trim(),
    instructorNames: instructors
        .split(RegExp(r'[\n\t,]+'))
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList(),
    notes: notes.trim(),
    cancellationFlag: cancellation.trim(),
    restrictions: restrictions.trim(),
    requiredElectiveMetadata: requiredElective.trim(),
    department: department.trim(),
    subject: subject.trim(),
    rawScheduleText: schedule.trim(),
    rawLocationText: location.trim(),
    meetings: meetings,
  );
}

List<Map<String, String>> _readXlsxRows(List<int> bytes) {
  final archive = ZipDecoder().decodeBytes(bytes, verify: true);
  String entryText(String name) {
    final file = archive.find(name);
    if (file == null) {
      throw FormatException('Missing XLSX entry: $name');
    }
    return utf8.decode(file.content, allowMalformed: false);
  }

  final sharedFile = archive.find('xl/sharedStrings.xml');
  final shared = sharedFile == null
      ? <String>[]
      : XmlDocument.parse(utf8.decode(sharedFile.content))
            .findAllElements('si', namespace: '*')
            .map(
              (element) => element
                  .findAllElements('t', namespace: '*')
                  .map((text) => text.innerText)
                  .join(),
            )
            .toList();
  final sheetNames =
      archive.files
          .map((file) => file.name)
          .where(RegExp(r'^xl/worksheets/sheet\d+\.xml$').hasMatch)
          .toList()
        ..sort();
  final output = <Map<String, String>>[];
  for (final sheetName in sheetNames) {
    final document = XmlDocument.parse(entryText(sheetName));
    List<String>? headers;
    for (final row in document.findAllElements('row', namespace: '*')) {
      final values = <int, String>{};
      for (final cell in row.findElements('c', namespace: '*')) {
        final reference = cell.getAttribute('r') ?? '';
        final column = _columnIndex(reference);
        final raw = cell.descendantElements
            .where(
              (element) =>
                  element.name.local == 'v' || element.name.local == 't',
            )
            .map((element) => element.innerText)
            .join();
        final value = cell.getAttribute('t') == 's' && raw.isNotEmpty
            ? shared[int.parse(raw)]
            : raw;
        values[column] = value;
      }
      if (values.isEmpty) {
        continue;
      }
      final width = values.keys.reduce((a, b) => a > b ? a : b) + 1;
      final ordered = [for (var i = 0; i < width; i++) values[i] ?? ''];
      if (headers == null) {
        if (ordered.contains('科號')) {
          headers = ordered;
        }
        continue;
      }
      final mapped = <String, String>{};
      for (var i = 0; i < headers.length && i < ordered.length; i++) {
        if (headers[i].trim().isNotEmpty) {
          mapped[headers[i].trim()] = ordered[i];
        }
      }
      if (mapped.isNotEmpty) {
        output.add(mapped);
      }
    }
  }
  return output;
}

int _columnIndex(String reference) {
  var value = 0;
  for (final unit in reference.codeUnits) {
    if (unit < 65 || unit > 90) {
      break;
    }
    value = value * 26 + unit - 64;
  }
  return value - 1;
}

String _first(Map<String, String> row, List<String> names) {
  for (final name in names) {
    final value = row[name]?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }
  return '';
}

String _departmentFromCode(String code, String term) =>
    RegExp(
      r'^[A-Za-z]+',
    ).firstMatch(code.substring(term.length).trim())?.group(0) ??
    '';

List<String> _splitStored(String value) =>
    value.split('\n').where((item) => item.trim().isNotEmpty).toList();
