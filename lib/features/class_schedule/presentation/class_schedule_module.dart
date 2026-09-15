import 'package:flutter/material.dart';
import 'academic_data_view.dart';
import 'history_view.dart';
import 'planning_view.dart';
import 'progress_view.dart';
import 'schedule_view.dart';

class ClassScheduleModule extends StatefulWidget {
  const ClassScheduleModule({super.key});

  @override
  State<ClassScheduleModule> createState() => _ClassScheduleModuleState();
}

class _ClassScheduleModuleState extends State<ClassScheduleModule> {
  int section = 0;

  static const _labels = ['Schedule', 'Graduation', 'History', 'Planning'];
  static const _icons = [
    Icons.calendar_view_week_outlined,
    Icons.school_outlined,
    Icons.history,
    Icons.event_available_outlined,
  ];

  Widget _content() => AcademicDataView(
    builder: (data) => switch (section) {
      1 => ProgressView(data: data),
      2 => HistoryView(data: data),
      3 => PlanningView(data: data),
      _ => ScheduleView(data: data),
    },
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final textScale = MediaQuery.textScalerOf(context).scale(1);
      final useDesktopRail =
          constraints.maxWidth >= 1000 &&
          constraints.maxHeight >= 560 &&
          textScale <= 1.4;

      if (useDesktopRail) {
        return Row(
          children: [
            Material(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: Container(
                width: 172,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ACADEMICS',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < _labels.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        child: ListTile(
                          dense: true,
                          selected: section == i,
                          selectedTileColor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          leading: Icon(_icons[i], size: 18),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          horizontalTitleGap: 8,
                          title: Text(_labels[i], softWrap: false),
                          onTap: () => setState(() => section = i),
                        ),
                      ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        leading: const Icon(Icons.folder_open_outlined, size: 18),
                        title: const Text('Records'),
                        onTap: () => openAcademicRecords(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
            Expanded(child: _content()),
          ],
        );
      }

      final denseMobile = constraints.maxWidth < 600 && textScale <= 1.4;
      final tabs = denseMobile
          ? Row(
              children: [
                for (var i = 0; i < _labels.length; i++) ...[
                  Expanded(
                    child: ChoiceChip(
                      showCheckmark: false,
                      label: Text(
                        _labels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      selected: section == i,
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                      onSelected: (_) => setState(() => section = i),
                    ),
                  ),
                  if (i != _labels.length - 1) const SizedBox(width: 2),
                ],
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _labels.length; i++) ...[
                  ChoiceChip(
                    showCheckmark: false,
                    avatar: Icon(_icons[i], size: 15),
                    label: Text(_labels[i]),
                    selected: section == i,
                    visualDensity: const VisualDensity(
                      horizontal: -1,
                      vertical: -2,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    onSelected: (_) => setState(() => section = i),
                  ),
                  if (i != _labels.length - 1) const SizedBox(width: 4),
                ],
              ],
            );
      return Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                denseMobile ? 3 : 6,
                denseMobile ? 1 : 3,
                denseMobile ? 3 : 4,
                denseMobile ? 1 : 2,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: denseMobile
                    ? tabs
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: tabs,
                      ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _content()),
        ],
      );
    },
  );
}

void openFullSchedule(BuildContext context) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Class Schedule')),
      body: const SafeArea(child: ClassScheduleModule()),
    ),
  ),
);
