import 'dart:math' as math;

const nthuMinimumTermCode = '11310';

class NthuPeriod {
  const NthuPeriod(this.code, this.startMinute, this.endMinute);

  final String code;
  final int startMinute;
  final int endMinute;

  String get startLabel => _minuteLabel(startMinute);
  String get endLabel => _minuteLabel(endMinute);
  String get timeLabel => '$startLabel–$endLabel';
}

const nthuPeriods = <NthuPeriod>[
  NthuPeriod('1', 8 * 60, 8 * 60 + 50),
  NthuPeriod('2', 9 * 60, 9 * 60 + 50),
  NthuPeriod('3', 10 * 60 + 10, 11 * 60),
  NthuPeriod('4', 11 * 60 + 10, 12 * 60),
  NthuPeriod('n', 12 * 60 + 10, 13 * 60),
  NthuPeriod('5', 13 * 60 + 20, 14 * 60 + 10),
  NthuPeriod('6', 14 * 60 + 20, 15 * 60 + 10),
  NthuPeriod('7', 15 * 60 + 30, 16 * 60 + 20),
  NthuPeriod('8', 16 * 60 + 30, 17 * 60 + 20),
  NthuPeriod('9', 17 * 60 + 30, 18 * 60 + 20),
  NthuPeriod('a', 18 * 60 + 30, 19 * 60 + 20),
  NthuPeriod('b', 19 * 60 + 30, 20 * 60 + 20),
  NthuPeriod('c', 20 * 60 + 30, 21 * 60 + 20),
  NthuPeriod('d', 21 * 60 + 30, 22 * 60 + 20),
];

const nthuDayCodes = <String>['M', 'T', 'W', 'R', 'F', 'S', 'U'];
const nthuDayNames = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

NthuPeriod? nthuPeriod(String? code) => nthuPeriods
    .where((period) => period.code == code?.toLowerCase())
    .firstOrNull;

int nthuPeriodIndex(String code) =>
    nthuPeriods.indexWhere((period) => period.code == code.toLowerCase());

/// A clock gap counts as usable free time only when it contains at least one
/// complete NTHU class period. The short transition intervals between
/// consecutive periods are intentionally not treated as free time.
bool containsWholeNthuPeriod(int startMinute, int endMinute) =>
    nthuPeriods.any(
      (period) =>
          period.startMinute >= startMinute &&
          period.endMinute <= endMinute,
    );

String nthuDayCode(int weekday) => nthuDayCodes[weekday - 1];

int? nthuWeekday(String code) {
  final index = nthuDayCodes.indexOf(code.toUpperCase());
  return index < 0 ? null : index + 1;
}

class NthuPeriodRange {
  const NthuPeriodRange(this.startPeriod, this.endPeriod);

  final String startPeriod;
  final String endPeriod;

  int get startIndex => nthuPeriodIndex(startPeriod);
  int get endIndex => nthuPeriodIndex(endPeriod);
  int get startMinute => nthuPeriods[startIndex].startMinute;
  int get endMinute => nthuPeriods[endIndex].endMinute;
  Iterable<NthuPeriod> get periods =>
      nthuPeriods.getRange(startIndex, endIndex + 1);
}

NthuPeriodRange? nthuRangeForMinutes(int start, int end) {
  final first = nthuPeriods.indexWhere((period) => period.startMinute == start);
  final last = nthuPeriods.indexWhere((period) => period.endMinute == end);
  if (first < 0 || last < first) return null;
  return NthuPeriodRange(nthuPeriods[first].code, nthuPeriods[last].code);
}

class NthuCatalogMeetingModel {
  const NthuCatalogMeetingModel({
    required this.dayCode,
    required this.startPeriod,
    required this.endPeriod,
    required this.scheduleCode,
    this.location = '',
  });

  final String dayCode;
  final String startPeriod;
  final String endPeriod;
  final String scheduleCode;
  final String location;

  int get weekday => nthuWeekday(dayCode)!;
  int get startMinute => nthuPeriod(startPeriod)!.startMinute;
  int get endMinute => nthuPeriod(endPeriod)!.endMinute;
}

List<NthuCatalogMeetingModel> parseNthuSchedule(
  String schedule, {
  String location = '',
}) {
  final matches = RegExp(
    r'([MTWRFSU])\s*([1234Nn56789AaBbCcDd])',
    caseSensitive: false,
  ).allMatches(schedule);
  final byDay = <String, Set<int>>{};
  for (final match in matches) {
    final day = match.group(1)!.toUpperCase();
    final periodIndex = nthuPeriodIndex(match.group(2)!.toLowerCase());
    if (nthuWeekday(day) != null && periodIndex >= 0) {
      byDay.putIfAbsent(day, () => <int>{}).add(periodIndex);
    }
  }
  final result = <NthuCatalogMeetingModel>[];
  for (final day in nthuDayCodes) {
    final indices = (byDay[day]?.toList() ?? <int>[])..sort();
    if (indices.isEmpty) continue;
    var blockStart = indices.first;
    var previous = indices.first;
    void addBlock() {
      final range = nthuPeriods.getRange(blockStart, previous + 1).toList();
      result.add(
        NthuCatalogMeetingModel(
          dayCode: day,
          startPeriod: range.first.code,
          endPeriod: range.last.code,
          scheduleCode: range.map((period) => '$day${period.code}').join(),
          location: location.trim(),
        ),
      );
    }

    for (final index in indices.skip(1)) {
      if (index != previous + 1) {
        addBlock();
        blockStart = index;
      }
      previous = index;
    }
    addBlock();
  }
  return result;
}

String nthuScheduleCode({
  required String dayCode,
  required String startPeriod,
  required String endPeriod,
}) {
  final start = nthuPeriodIndex(startPeriod);
  final end = nthuPeriodIndex(endPeriod);
  if (start < 0 || end < start || nthuWeekday(dayCode) == null) return '';
  return nthuPeriods
      .getRange(start, end + 1)
      .map((period) => '${dayCode.toUpperCase()}${period.code}')
      .join();
}

class NthuTerm {
  const NthuTerm._(this.code);

  factory NthuTerm(String code) {
    if (!isValidCode(code)) {
      throw ArgumentError.value(code, 'code', 'Unsupported NTHU term code.');
    }
    return NthuTerm._(code);
  }

  final String code;

  static bool isValidCode(String? code) {
    if (code == null || !RegExp(r'^\d{3}(10|20)$').hasMatch(code)) {
      return false;
    }
    return int.parse(code) >= int.parse(nthuMinimumTermCode);
  }

  int get academicYear => int.parse(code.substring(0, 3));
  bool get isFall => code.endsWith('10');
  int get calendarYear => academicYear + 1911 + (isFall ? 0 : 1);
  String get season => isFall ? 'Fall' : 'Spring';
  String get displayName => '$academicYear $season';
  String get calendarLabel => '$calendarYear $season';
  DateTime get approximateStart =>
      isFall ? DateTime(calendarYear, 9, 1) : DateTime(calendarYear, 2, 1);
  DateTime get approximateEnd => isFall
      ? DateTime(calendarYear + 1, 1, 31)
      : DateTime(calendarYear, 6, 30);

  static NthuTerm current(DateTime date) {
    final fall = date.month >= 8;
    final academicYear = fall ? date.year - 1911 : date.year - 1912;
    return NthuTerm('$academicYear${fall ? '10' : '20'}');
  }

  static List<NthuTerm> supportedThrough(DateTime date) {
    final last = current(date);
    final result = <NthuTerm>[];
    for (var year = 113; year <= last.academicYear; year++) {
      result.add(NthuTerm('${year}10'));
      if (year < last.academicYear || !last.isFall) {
        result.add(NthuTerm('${year}20'));
      }
    }
    return result;
  }

  @override
  bool operator ==(Object other) => other is NthuTerm && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

NthuTerm? inferNthuTerm({
  String? explicitCode,
  required String academicYear,
  required String term,
  String? name,
}) {
  final explicit = explicitCode?.trim();
  if (NthuTerm.isValidCode(explicit)) return NthuTerm(explicit!);

  final combined = '$academicYear $term ${name ?? ''}'.toLowerCase();
  final isFall =
      combined.contains('fall') ||
      combined.contains('autumn') ||
      RegExp(r'(^|\D)10(\D|$)').hasMatch(combined);
  final isSpring =
      combined.contains('spring') ||
      RegExp(r'(^|\D)20(\D|$)').hasMatch(combined);
  if (!isFall && !isSpring) return null;

  int? year;
  for (final candidate in [academicYear, name ?? '']) {
    final match = RegExp(r'(?<!\d)(\d{3,4})(?!\d)').firstMatch(candidate);
    if (match != null) {
      year = int.tryParse(match.group(1)!);
      if (year != null) break;
    }
  }
  if (year == null) return null;

  final academic = year >= 1911 ? year - (isFall ? 1911 : 1912) : year;
  final code = '$academic${isFall ? '10' : '20'}';
  return NthuTerm.isValidCode(code) ? NthuTerm(code) : null;
}

enum NthuCatalogSourceType { currentJson, historicalArchive, manualArchive }

class NthuCatalogCourseModel {
  const NthuCatalogCourseModel({
    required this.id,
    required this.termCode,
    required this.officialCourseCode,
    required this.chineseName,
    required this.englishName,
    required this.credits,
    required this.teachingLanguage,
    required this.instructorNames,
    required this.meetings,
    this.notes = '',
    this.cancellationFlag = '',
    this.restrictions = '',
    this.requiredElectiveMetadata = '',
    this.department = '',
    this.subject = '',
    this.rawScheduleText = '',
    this.rawLocationText = '',
  });

  final String id;
  final String termCode;
  final String officialCourseCode;
  final String chineseName;
  final String englishName;
  final double credits;
  final String teachingLanguage;
  final List<String> instructorNames;
  final String notes;
  final String cancellationFlag;
  final String restrictions;
  final String requiredElectiveMetadata;
  final String department;
  final String subject;
  final String rawScheduleText;
  final String rawLocationText;
  final List<NthuCatalogMeetingModel> meetings;

  String get displayName =>
      englishName.trim().isNotEmpty ? englishName.trim() : chineseName.trim();

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return [
      officialCourseCode,
      chineseName,
      englishName,
      instructorNames.join(' '),
      department,
    ].any((value) => value.toLowerCase().contains(needle));
  }
}

String _minuteLabel(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

int overlapMinutes(NthuCatalogMeetingModel a, NthuCatalogMeetingModel b) {
  if (a.dayCode != b.dayCode) return 0;
  return math.max(
    0,
    math.min(a.endMinute, b.endMinute) - math.max(a.startMinute, b.startMinute),
  );
}
