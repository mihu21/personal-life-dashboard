import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../class_schedule/providers/academic_providers.dart';
import '../data/spending_repository.dart';
import '../domain/spending_models.dart';

final spendingRepositoryProvider = Provider<SpendingRepository>((ref) {
  final repository = SpendingRepository(ref.watch(academicDatabaseProvider));
  ref.onDispose(repository.dispose);
  return repository;
});
final spendingProvider = StreamProvider<SpendingState>(
  (ref) => ref.watch(spendingRepositoryProvider).watch(),
);
