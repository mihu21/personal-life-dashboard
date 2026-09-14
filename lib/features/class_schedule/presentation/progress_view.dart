import 'package:flutter/material.dart';

import '../../../app/theme/app_density.dart';

import '../data/academic_snapshot.dart';
import '../domain/credit_progress.dart';
import 'record_editors.dart';

class ProgressView extends StatelessWidget {
  const ProgressView({required this.data, super.key});
  final AcademicSnapshot data;
  @override
  Widget build(BuildContext context) {
    final allocated = allocatedCategoryCredits(data.courses, data.categories);
    return ListView(
      padding: EdgeInsets.all(AppDensity.pagePadding(context)),
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppDensity.controlGap(context),
          runSpacing: AppDensity.sectionGap(context),
          children: [
            Text(
              'Academic progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            OutlinedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => GraduationRequirementsEditor(data: data),
              ),
              child: const Text('Edit requirements'),
            ),
          ],
        ),
        SizedBox(height: AppDensity.cardPadding(context)),
        CreditSummary(
          totals: creditTotals(data.courses),
          target: data.settings.requiredCredits,
          completedCourses: completedCourseCount(data.courses),
        ),
        SizedBox(height: AppDensity.sectionGap(context)),
        const Text(
          'Potential assumes all in-progress and planned courses are completed. It is not earned credit.',
        ),
        SizedBox(height: AppDensity.sectionGap(context)),
        const Text(
          'Category targets are caps for graduation accounting. Credits above a filled category automatically roll into Free Elective.',
        ),
        SizedBox(height: AppDensity.cardPadding(context)),
        for (final category in data.categories)
          CategoryProgressCard(
            name: '${category.name}${category.isActive ? '' : ' (hidden)'}',
            target: category.requiredCredits,
            totals: allocated[category.id] ?? const CreditTotals(),
            completedCourses: completedCourseCount(
              data.courses,
              categoryId: category.id,
            ),
            overflowCredits: isFreeElectiveCategory(category)
                ? 0
                : _overflowCredits(
                    creditTotals(data.courses, categoryId: category.id),
                    allocated[category.id] ?? const CreditTotals(),
                  ),
          ),
        if (data.courses.isEmpty)
          Padding(
            padding: EdgeInsets.all(AppDensity.cardPadding(context)),
            child: Text('Your completed courses will appear here.'),
          ),
      ],
    );
  }
}

double _overflowCredits(CreditTotals raw, CreditTotals allocated) {
  final value = raw.potential - allocated.potential;
  return value > 0 ? value : 0;
}

class CreditSummary extends StatelessWidget {
  const CreditSummary({
    required this.totals,
    required this.completedCourses,
    this.target,
    super.key,
  });
  final CreditTotals totals;
  final int completedCourses;
  final double? target;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          final gap = AppDensity.controlGap(context);
          final scale = MediaQuery.textScalerOf(context).scale(1);
          final available = constraints.maxWidth.clamp(0.0, 720.0);
          final columns =
              (available / ((AppDensity.isMobile(context) ? 82 : 152) * scale))
                  .floor()
                  .clamp(1, 4);
          final width = (available - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: AppDensity.controlGap(context),
            runSpacing: AppDensity.controlGap(context),
            children: [
              for (final item in [
                ('Completed', totals.completed),
                ('In progress', totals.inProgress),
                ('Planned', totals.planned),
                ('Potential', totals.potential),
              ])
                SizedBox(
                  width: width,
                  child: Card.outlined(
                    child: Padding(
                      padding: EdgeInsets.all(AppDensity.cardPadding(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$1),
                          Text(
                            creditLabel(item.$2),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      SizedBox(height: AppDensity.sectionGap(context)),
      Text(
        '$completedCourses ${completedCourses == 1 ? 'course' : 'courses'} completed',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      SizedBox(height: AppDensity.tinyGap(context)),
      Text(
        target == null
            ? 'Overall target not set'
            : 'Overall target: ${creditLabel(target!)} credits · ${creditLabel(totals.remaining(target)!)} remaining',
      ),
      if (target != null && target! > 0)
        Padding(
          padding: EdgeInsets.only(top: AppDensity.sectionGap(context)),
          child: LinearProgressIndicator(
            value: (totals.completed / target!).clamp(0, 1),
            semanticsLabel: 'Completed credits',
            semanticsValue:
                '${creditLabel(totals.completed)} of ${creditLabel(target!)}',
          ),
        ),
    ],
  );
}

class CategoryProgressCard extends StatelessWidget {
  const CategoryProgressCard({
    required this.name,
    required this.totals,
    required this.completedCourses,
    this.target,
    this.preview = false,
    this.overflowCredits = 0,
    super.key,
  });
  final String name;
  final CreditTotals totals;
  final int completedCourses;
  final double? target;
  final bool preview;
  final double overflowCredits;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: AppDensity.sectionGap(context)),
    child: Card.outlined(
      child: Padding(
        padding: EdgeInsets.all(AppDensity.cardPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppDensity.tinyGap(context),
          children: [
            Text(name, style: Theme.of(context).textTheme.titleMedium),
            Text(
              '${creditLabel(totals.completed)}${target == null ? '' : ' / ${creditLabel(target!)}'} credits completed',
            ),
            Text(
              '$completedCourses ${completedCourses == 1 ? 'course' : 'courses'} completed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '+${creditLabel(totals.inProgress)} in progress · +${creditLabel(totals.planned)} planned',
            ),
            Text(
              'Potential: ${creditLabel(totals.potential)}${target == null ? '' : ' · ${creditLabel(totals.remaining(target, includePotential: preview)!)} remaining${preview ? ' after completion' : ''}'}',
            ),
            if (overflowCredits > 0)
              Text(
                '${creditLabel(overflowCredits)} overflow credits count toward Free Elective.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            if (target != null && target! > 0)
              LinearProgressIndicator(
                value:
                    ((preview ? totals.potential : totals.completed) / target!)
                        .clamp(0, 1),
              ),
          ],
        ),
      ),
    ),
  );
}
