import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/one_time_event.dart';

class OneTimeEventRepository {
  OneTimeEventRepository({Future<File> Function()? fileFactory})
    : _fileFactory = fileFactory ?? _defaultFile;

  final Future<File> Function() _fileFactory;

  static Future<File> _defaultFile() async {
    final directory = await getApplicationSupportDirectory();
    return File(
      '${directory.path}${Platform.pathSeparator}one_time_events.json',
    );
  }

  Future<List<OneTimeEvent>> load() async {
    final file = await _fileFactory();
    if (!await file.exists()) return [];
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Invalid one-time event storage format.');
    }
    final events = decoded
        .map(
          (item) =>
              OneTimeEvent.fromJson(Map<String, Object?>.from(item as Map)),
        )
        .toList();
    events.sort((a, b) {
      final date = a.date.compareTo(b.date);
      if (date != 0) return date;
      final time = a.startMinute.compareTo(b.startMinute);
      return time != 0 ? time : a.title.compareTo(b.title);
    });
    return events;
  }

  Future<void> upsert(OneTimeEvent event) async {
    final events = await load();
    final index = events.indexWhere((item) => item.id == event.id);
    if (index < 0) {
      events.add(event);
    } else {
      events[index] = event;
    }
    await _write(events);
  }

  Future<void> delete(String id) async {
    final events = await load();
    events.removeWhere((event) => event.id == id);
    await _write(events);
  }

  Future<void> replaceAll(Iterable<OneTimeEvent> events) async {
    final replacement = events.toList()
      ..sort((a, b) {
        final date = a.date.compareTo(b.date);
        if (date != 0) return date;
        final time = a.startMinute.compareTo(b.startMinute);
        return time != 0 ? time : a.title.compareTo(b.title);
      });
    await _write(replacement);
  }

  Future<void> _write(List<OneTimeEvent> events) async {
    final file = await _fileFactory();
    await file.parent.create(recursive: true);
    final body = const JsonEncoder.withIndent(
      '  ',
    ).convert(events.map((event) => event.toJson()).toList());
    await file.writeAsString(body, flush: true);
  }
}
