import 'package:flutter/material.dart';

import '../../../app/theme/app_density.dart';

import '../data/academic_snapshot.dart';
import '../domain/academic_types.dart';
import '../domain/credit_progress.dart';
import 'academic_data_view.dart';
import 'records_view.dart';
import 'schedule_view.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({required this.data, super.key});
  final AcademicSnapshot data;
  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.all(AppDensity.pagePadding(context)),
    children: [
      Text('Semester history', style: Theme.of(context).textTheme.titleLarge),
      SizedBox(height: AppDensity.sectionGap(context)),
      if (data.semesters.isEmpty)
        const Text('Your semesters will appear here.'),
      for (final semester in data.semesters)
        Card.outlined(
          child: ListTile(
            title: Text(semester.name),
            subtitle: Text(
              '${statusLabel(semester.status)} · ${data.coursesIn(semester.id).length} courses\n${creditLabel(creditTotals(data.coursesIn(semester.id)).completed)} completed credits',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: Text(semester.name)),
                  body: AcademicDataView(
                    builder: (latest) => SemesterHistoryDetails(
                      data: latest,
                      semesterId: semester.id,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}

class SemesterHistoryDetails extends StatelessWidget {
  const SemesterHistoryDetails({
    required this.data,
    required this.semesterId,
    super.key,
  });
  final AcademicSnapshot data;
  final String semesterId;
  @override
  Widget build(BuildContext context) {
    final semester = data.semesters
        .where((s) => s.id == semesterId)
        .firstOrNull;
    if (semester == null) {
      return const Center(child: Text('Semester no longer available.'));
    }
    final courses = data.coursesIn(semesterId);
    final totals = creditTotals(courses);
    return ListView(
      padding: EdgeInsets.all(AppDensity.pagePadding(context)),
      children: [
        Text(
          '${dateLabel(semester.startDate)} – ${dateLabel(semester.endDate)} · ${statusLabel(semester.status)}',
        ),
        Text(
          '${creditLabel(totals.completed)} completed · ${creditLabel(totals.inProgress)} in progress · ${creditLabel(totals.planned)} planned credits',
        ),
        SizedBox(height: AppDensity.sectionGap(context)),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.view_week_outlined),
            label: const Text('View schedule'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: Text('${semester.name} schedule')),
                  body: AcademicDataView(
                    builder: (latest) =>
                        ScheduleView(data: latest, semesterId: semesterId),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (courses.isEmpty)
          Padding(
            padding: EdgeInsets.all(AppDensity.cardPadding(context)),
            child: Text('No courses in this semester.'),
          ),
        for (final course in courses) CourseRecordTile(course: course),
      ],
    );
  }
}
