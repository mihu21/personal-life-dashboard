import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_density.dart';

import '../data/academic_snapshot.dart';
import '../providers/academic_providers.dart';

class AcademicDataView extends ConsumerWidget {
  const AcademicDataView({required this.builder, super.key});
  final Widget Function(AcademicSnapshot data) builder;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(academicSnapshotProvider)
      .when(
        data: builder,
        loading: () => const Center(child: Text('Opening academic records…')),
        error: (error, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(AppDensity.cardPadding(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Academic records could not be opened.'),
                Text('$error', maxLines: 3, overflow: TextOverflow.ellipsis),
                TextButton(
                  onPressed: () => ref.invalidate(academicSnapshotProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
}
