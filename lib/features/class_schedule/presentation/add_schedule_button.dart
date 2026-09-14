import 'dart:async';

import 'package:flutter/material.dart';

import '../data/academic_database.dart';
import '../data/academic_snapshot.dart';
import 'nthu_course_picker.dart';
import 'one_time_event_editor.dart';

enum AddScheduleAction { catalogCourse, event }

typedef AddScheduleLauncher = Future<void> Function(BuildContext context);

class AddScheduleButton extends StatefulWidget {
  const AddScheduleButton({
    required this.data,
    required this.semester,
    required this.initialDate,
    this.iconOnly = false,
    this.onAddCourse,
    this.onAddEvent,
    super.key,
  });

  final AcademicSnapshot data;
  final Semester semester;
  final DateTime initialDate;
  final bool iconOnly;

  /// Optional launch hooks are useful for embedding the button in another
  /// surface and for testing the menu-to-overlay transition without touching
  /// the persistent repositories.
  final AddScheduleLauncher? onAddCourse;
  final AddScheduleLauncher? onAddEvent;

  @override
  State<AddScheduleButton> createState() => _AddScheduleButtonState();
}

class _AddScheduleButtonState extends State<AddScheduleButton> {
  final MenuController _menuController = MenuController();
  bool _launchScheduled = false;
  bool _openingEditor = false;

  void _queueSelection(MenuController controller, AddScheduleAction action) {
    if (_launchScheduled || _openingEditor) return;
    _launchScheduled = true;

    // Close the anchored menu first. Opening another overlay from the same
    // pointer-update callback can trip Flutter's MouseTracker assertion on
    // desktop. The editor is launched only after this frame is fully done.
    controller.close();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _launchScheduled = false;
      unawaited(_openSelection(action));
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  Future<void> _openSelection(AddScheduleAction action) async {
    if (_openingEditor || !mounted) return;
    setState(() => _openingEditor = true);

    try {
      switch (action) {
        case AddScheduleAction.catalogCourse:
          final launcher = widget.onAddCourse;
          if (launcher != null) {
            await launcher(context);
          } else {
            await showNthuCoursePicker(
              context,
              data: widget.data,
              semester: widget.semester,
            );
          }
          return;
        case AddScheduleAction.event:
          final launcher = widget.onAddEvent;
          if (launcher != null) {
            await launcher(context);
          } else {
            await showOneTimeEventEditor(
              context,
              initialDate: widget.initialDate,
            );
          }
          return;
      }
    } finally {
      if (mounted) setState(() => _openingEditor = false);
    }
  }

  List<Widget> _menuChildren(MenuController controller) => [
    MenuItemButton(
      leadingIcon: const Icon(Icons.school_outlined),
      onPressed: _openingEditor
          ? null
          : () => _queueSelection(controller, AddScheduleAction.catalogCourse),
      child: const _AddMenuLabel(
        title: 'Add course',
        subtitle: 'From the NTHU catalog',
      ),
    ),
    MenuItemButton(
      leadingIcon: const Icon(Icons.event_outlined),
      onPressed: _openingEditor
          ? null
          : () => _queueSelection(controller, AddScheduleAction.event),
      child: const _AddMenuLabel(
        title: 'Add event',
        subtitle: 'Use NTHU periods on a specific date',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    void toggleMenu() {
      if (_openingEditor) return;
      if (_menuController.isOpen) {
        _menuController.close();
      } else {
        _menuController.open();
      }
    }

    return MenuAnchor(
      controller: _menuController,
      menuChildren: _menuChildren(_menuController),
      builder: (context, controller, child) {
        if (widget.iconOnly) {
          return IconButton(
            tooltip: 'Add',
            onPressed: toggleMenu,
            icon: const Icon(Icons.add),
          );
        }

        final scheme = Theme.of(context).colorScheme;
        return FilledButton(
          onPressed: toggleMenu,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: const StadiumBorder(),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 18),
              const SizedBox(width: 7),
              Text(
                'Add',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: scheme.onPrimary),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.arrow_drop_down, size: 18),
            ],
          ),
        );
      },
    );
  }
}

class _AddMenuLabel extends StatelessWidget {
  const _AddMenuLabel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: (MediaQuery.sizeOf(context).width - 100).clamp(160, 300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
