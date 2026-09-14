import 'academic_types.dart';
import 'nthu_academic.dart';

class OneTimeEvent {
  const OneTimeEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.startPeriod,
    required this.endPeriod,
    required this.createdAt,
    required this.updatedAt,
    this.specificTime = '',
    this.location = '',
    this.notes = '',
  });

  final String id;
  final String title;
  final DateTime date;
  final String startPeriod;
  final String endPeriod;
  final String specificTime;
  final String location;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  NthuPeriodRange get periodRange => NthuPeriodRange(startPeriod, endPeriod);
  int get startMinute => periodRange.startMinute;
  int get endMinute => periodRange.endMinute;
  String get dayCode => nthuDayCode(date.weekday);
  String get scheduleCode => nthuScheduleCode(
    dayCode: dayCode,
    startPeriod: startPeriod,
    endPeriod: endPeriod,
  );

  OneTimeEvent copyWith({
    String? title,
    DateTime? date,
    String? startPeriod,
    String? endPeriod,
    String? specificTime,
    String? location,
    String? notes,
    DateTime? updatedAt,
  }) => OneTimeEvent(
    id: id,
    title: title ?? this.title,
    date: dateOnly(date ?? this.date),
    startPeriod: startPeriod ?? this.startPeriod,
    endPeriod: endPeriod ?? this.endPeriod,
    specificTime: specificTime ?? this.specificTime,
    location: location ?? this.location,
    notes: notes ?? this.notes,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'date': dateLabel(date),
    'startPeriod': startPeriod,
    'endPeriod': endPeriod,
    'specificTime': specificTime,
    'location': location,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory OneTimeEvent.fromJson(Map<String, Object?> json) {
    final date = DateTime.parse(json['date']! as String);
    return OneTimeEvent(
      id: json['id']! as String,
      title: json['title']! as String,
      date: dateOnly(date),
      startPeriod: json['startPeriod']! as String,
      endPeriod: json['endPeriod']! as String,
      specificTime: (json['specificTime'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
      notes: (json['notes'] as String?) ?? '',
      createdAt: DateTime.parse(json['createdAt']! as String),
      updatedAt: DateTime.parse(json['updatedAt']! as String),
    );
  }
}

List<OneTimeEvent> eventsForDay(Iterable<OneTimeEvent> events, DateTime date) {
  final day = dateOnly(date);
  return events.where((event) => dateOnly(event.date) == day).toList()
    ..sort((a, b) {
      final time = a.startMinute.compareTo(b.startMinute);
      return time != 0 ? time : a.title.compareTo(b.title);
    });
}
