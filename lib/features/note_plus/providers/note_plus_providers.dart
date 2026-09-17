import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../class_schedule/providers/academic_providers.dart';
import '../data/note_plus_repository.dart';
import '../domain/note_plus_types.dart';

final notePlusRepositoryProvider = Provider<NotePlusRepository>((ref) {
  final repository = NotePlusRepository(ref.watch(academicDatabaseProvider));
  ref.onDispose(repository.dispose);
  return repository;
});

final notePlusProvider = StreamProvider<NotePlusSnapshot>(
  (ref) => ref.watch(notePlusRepositoryProvider).watch(),
);
