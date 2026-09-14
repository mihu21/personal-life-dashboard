enum SemesterStatus { planned, current, completed, archived }

enum CourseStatus { planned, inProgress, completed, withdrawn, failed }

enum ExceptionType { cancelled, rescheduled, locationChanged, extraClass }

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String dateLabel(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String timeLabel(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

String statusLabel(Enum value) => switch (value.name) {
  'inProgress' => 'In progress',
  'locationChanged' => 'Location changed',
  'extraClass' => 'Extra class',
  final name => '${name[0].toUpperCase()}${name.substring(1)}',
};

const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
