import 'dart:convert';

enum NotePropertyType {
  text,
  longText,
  number,
  currency,
  checkbox,
  checklist,
  date,
  dateTime,
  select,
  multiSelect,
  status,
  rating,
  progress,
  url,
}

extension NotePropertyTypeUi on NotePropertyType {
  String get label => switch (this) {
        NotePropertyType.text => 'Text',
        NotePropertyType.longText => 'Long text',
        NotePropertyType.number => 'Number',
        NotePropertyType.currency => 'Currency',
        NotePropertyType.checkbox => 'Checkbox',
        NotePropertyType.checklist => 'Checklist',
        NotePropertyType.date => 'Date',
        NotePropertyType.dateTime => 'Date & time',
        NotePropertyType.select => 'Select',
        NotePropertyType.multiSelect => 'Multi-select',
        NotePropertyType.status => 'Status',
        NotePropertyType.rating => 'Rating',
        NotePropertyType.progress => 'Progress',
        NotePropertyType.url => 'URL',
      };

  bool get hasOptions => switch (this) {
        NotePropertyType.select ||
        NotePropertyType.multiSelect ||
        NotePropertyType.status => true,
        _ => false,
      };
}

NotePropertyType parseNotePropertyType(String raw) => NotePropertyType.values
    .firstWhere((type) => type.name == raw, orElse: () => NotePropertyType.text);

class NoteRecord {
  const NoteRecord({
    required this.id,
    required this.title,
    required this.body,
    required this.pinned,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String body;
  final bool pinned;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class NoteList {
  const NoteList({
    required this.id,
    required this.name,
    required this.icon,
    required this.pinned,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String icon;
  final bool pinned;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class NotePropertyRow {
  const NotePropertyRow({
    required this.id,
    required this.listId,
    required this.name,
    required this.propertyType,
    required this.position,
    required this.isPrimary,
    required this.configuration,
  });

  final String id;
  final String listId;
  final String name;
  final String propertyType;
  final int position;
  final bool isPrimary;
  final String configuration;
}

class NoteItemRow {
  const NoteItemRow({
    required this.id,
    required this.listId,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String listId;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class NotePlusProperty {
  const NotePlusProperty({
    required this.row,
    required this.type,
    required this.options,
  });

  final NotePropertyRow row;
  final NotePropertyType type;
  final List<String> options;

  String get id => row.id;
  String get name => row.name;
  bool get isPrimary => row.isPrimary;
  int get position => row.position;
}

class NotePlusItem {
  const NotePlusItem(this.row, this.values);
  final NoteItemRow row;
  final Map<String, Object?> values;
}

class NotePlusListBundle {
  const NotePlusListBundle({
    required this.list,
    required this.properties,
    required this.items,
  });

  final NoteList list;
  final List<NotePlusProperty> properties;
  final List<NotePlusItem> items;

  NotePlusProperty? get primaryProperty {
    for (final property in properties) {
      if (property.isPrimary) return property;
    }
    return properties.isEmpty ? null : properties.first;
  }
}

class NotePlusSnapshot {
  const NotePlusSnapshot({required this.notes, required this.lists});
  final List<NoteRecord> notes;
  final List<NotePlusListBundle> lists;
}

List<String> decodeOptions(String raw, NotePropertyType type) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map && decoded['options'] is List) {
      return (decoded['options'] as List)
          .whereType<Object>()
          .map((value) => value.toString())
          .where((value) => value.trim().isNotEmpty)
          .toList();
    }
  } catch (_) {}
  if (type == NotePropertyType.status) {
    return const ['Planned', 'Doing', 'Done'];
  }
  return const [];
}

String encodeOptions(List<String> options) => jsonEncode({'options': options});

Object? decodeNoteValue(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return jsonDecode(raw);
  } catch (_) {
    return raw;
  }
}

String? encodeNoteValue(Object? value) {
  if (value == null) return null;
  return jsonEncode(value);
}

double? noteNumericValue(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

String displayNoteValue(NotePlusProperty property, Object? value) {
  if (value == null) return '';
  switch (property.type) {
    case NotePropertyType.checkbox:
      return value == true ? 'Yes' : 'No';
    case NotePropertyType.checklist:
      if (value is List) {
        final total = value.length;
        final done = value.where((entry) {
          return entry is Map && entry['done'] == true;
        }).length;
        return total == 0 ? '' : '$done/$total done';
      }
      return '';
    case NotePropertyType.multiSelect:
      return value is List ? value.join(', ') : value.toString();
    case NotePropertyType.rating:
      final count = noteNumericValue(value)?.round().clamp(0, 5) ?? 0;
      return '${'★' * count}${'☆' * (5 - count)}';
    case NotePropertyType.progress:
      final number = noteNumericValue(value)?.clamp(0, 100) ?? 0;
      return '${number.round()}%';
    case NotePropertyType.currency:
      final number = noteNumericValue(value);
      return number == null ? value.toString() : number.toStringAsFixed(2);
    default:
      return value.toString();
  }
}
