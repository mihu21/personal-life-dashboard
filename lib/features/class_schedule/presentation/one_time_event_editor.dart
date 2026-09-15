import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_density.dart';
import '../domain/academic_types.dart';
import '../domain/nthu_academic.dart';
import '../domain/one_time_event.dart';
import '../providers/academic_providers.dart';

Future<bool?> showOneTimeEventEditor(
  BuildContext context, {
  OneTimeEvent? event,
  DateTime? initialDate,
}) => showDialog<bool>(
  context: context,
  builder: (_) => OneTimeEventEditor(event: event, initialDate: initialDate),
);

class OneTimeEventEditor extends ConsumerStatefulWidget {
  const OneTimeEventEditor({this.event, this.initialDate, super.key});

  final OneTimeEvent? event;
  final DateTime? initialDate;

  @override
  ConsumerState<OneTimeEventEditor> createState() => _OneTimeEventEditorState();
}

class _OneTimeEventEditorState extends ConsumerState<OneTimeEventEditor> {
  static const _uuid = Uuid();

  late final TextEditingController titleController;
  late final TextEditingController specificTimeController;
  late final TextEditingController locationController;
  late final TextEditingController notesController;
  late DateTime date;
  late String startPeriod;
  late String endPeriod;
  late List<int> reminders;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    titleController = TextEditingController(text: event?.title ?? '');
    specificTimeController = TextEditingController(
      text: event?.specificTime ?? '',
    );
    locationController = TextEditingController(text: event?.location ?? '');
    notesController = TextEditingController(text: event?.notes ?? '');
    date = dateOnly(event?.date ?? widget.initialDate ?? DateTime.now());
    startPeriod = event?.startPeriod ?? '1';
    endPeriod = event?.endPeriod ?? event?.startPeriod ?? '1';
    reminders = [...?event?.reminderMinutesBefore]..sort();
  }

  @override
  void dispose() {
    titleController.dispose();
    specificTimeController.dispose();
    locationController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2200),
    );
    if (value != null && mounted) {
      setState(() => date = dateOnly(value));
    }
  }

  Future<void> save() async {
    final title = titleController.text.trim();
    final startIndex = nthuPeriodIndex(startPeriod);
    final endIndex = nthuPeriodIndex(endPeriod);
    if (title.isEmpty) {
      _message('Event title is required.');
      return;
    }
    if (startIndex < 0 || endIndex < startIndex) {
      _message('End period must be the same as or later than start period.');
      return;
    }

    setState(() => saving = true);
    final now = DateTime.now();
    final existing = widget.event;
    final event = OneTimeEvent(
      id: existing?.id ?? _uuid.v4(),
      title: title,
      date: date,
      startPeriod: startPeriod,
      endPeriod: endPeriod,
      specificTime: specificTimeController.text.trim(),
      location: locationController.text.trim(),
      notes: notesController.text.trim(),
      reminderMinutesBefore: reminders.toSet().toList()..sort(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      final notifications = ref.read(eventNotificationServiceProvider);
      var remindersEnabled = true;
      if (event.reminderMinutesBefore.isNotEmpty) {
        remindersEnabled = await notifications.ensurePermission();
      }

      final repository = ref.read(oneTimeEventRepositoryProvider);
      await repository.upsert(event);
      String? reminderWarning;
      try {
        await notifications.replaceEvent(
          previous: existing,
          event: event,
          scheduleReminders: remindersEnabled,
        );
        if (!remindersEnabled && event.reminderMinutesBefore.isNotEmpty) {
          reminderWarning =
              'Event saved, but notifications are disabled. Enable notifications in system settings for reminders to appear.';
        }
      } catch (error) {
        reminderWarning =
            'Event saved, but its reminder could not be scheduled: $error';
      }
      ref.invalidate(oneTimeEventsProvider);
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop(true);
        if (reminderWarning != null) {
          messenger.showSnackBar(SnackBar(content: Text(reminderWarning)));
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => saving = false);
        _message('Could not save event: $error');
      }
    }
  }

  Future<void> _addReminder() async {
    final choice = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Add reminder'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, -1),
            child: const Text('None'),
          ),
          for (final value in const [0, 5, 10, 30, 60, 1440])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, value),
              child: Text(reminderLabel(value)),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, -2),
            child: const Text('Custom…'),
          ),
        ],
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == -1) {
      setState(reminders.clear);
      return;
    }

    var minutes = choice;
    if (choice == -2) {
      final custom = await _customReminder();
      if (!mounted || custom == null) return;
      minutes = custom;
    }
    if (!reminders.contains(minutes)) {
      setState(() {
        reminders.add(minutes);
        reminders.sort();
      });
    }
  }

  Future<int?> _customReminder() async {
    final controller = TextEditingController();
    var unit = 'minutes';
    String? error;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Custom reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  errorText: error,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: unit,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'minutes', child: Text('Minutes')),
                  DropdownMenuItem(value: 'hours', child: Text('Hours')),
                  DropdownMenuItem(value: 'days', child: Text('Days')),
                ],
                onChanged: (value) {
                  if (value != null) setDialogState(() => unit = value);
                },
              ),
              const SizedBox(height: 8),
              const Text('The reminder must be before the event starts.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final amount = int.tryParse(controller.text.trim());
                if (amount == null || amount <= 0) {
                  setDialogState(() => error = 'Enter a number greater than 0.');
                  return;
                }
                final multiplier = switch (unit) {
                  'hours' => 60,
                  'days' => 24 * 60,
                  _ => 1,
                };
                Navigator.pop(context, amount * multiplier);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  Widget _reminderSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Icon(
            reminders.isEmpty
                ? Icons.notifications_none_outlined
                : Icons.notifications_active_outlined,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text('Reminders', style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
      SizedBox(height: AppDensity.tinyGap(context)),
      if (reminders.isEmpty)
        Text(
          'None',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        )
      else
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final value in reminders)
              InputChip(
                label: Text(reminderLabel(value)),
                onDeleted: saving
                    ? null
                    : () => setState(() => reminders.remove(value)),
              ),
          ],
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: saving ? null : _addReminder,
          icon: const Icon(Icons.add_alert_outlined, size: 18),
          label: const Text('Add reminder'),
        ),
      ),
    ],
  );

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _startPeriodField() => DropdownButtonFormField<String>(
    initialValue: startPeriod,
    isExpanded: true,
    itemHeight: null,
    decoration: const InputDecoration(
      labelText: 'Start period',
      border: OutlineInputBorder(),
      isDense: true,
    ),
    items: [
      for (final period in nthuPeriods)
        DropdownMenuItem(
          value: period.code,
          child: Text('${period.code} · ${period.startLabel}'),
        ),
    ],
    onChanged: saving
        ? null
        : (value) {
            if (value == null) return;
            setState(() {
              startPeriod = value;
              if (nthuPeriodIndex(endPeriod) < nthuPeriodIndex(startPeriod)) {
                endPeriod = startPeriod;
              }
            });
          },
  );

  Widget _endPeriodField() {
    final index = nthuPeriodIndex(startPeriod);
    final startIndex = index < 0 ? 0 : index;
    return DropdownButtonFormField<String>(
      key: ValueKey('event-end-$startPeriod-$endPeriod'),
      initialValue: endPeriod,
      isExpanded: true,
      itemHeight: null,
      decoration: const InputDecoration(
        labelText: 'End period',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        for (var i = startIndex; i < nthuPeriods.length; i++)
          DropdownMenuItem(
            value: nthuPeriods[i].code,
            child: Text('${nthuPeriods[i].code} · ${nthuPeriods[i].endLabel}'),
          ),
      ],
      onChanged: saving
          ? null
          : (value) {
              if (value != null) setState(() => endPeriod = value);
            },
    );
  }

  Widget _periodFields({required bool stacked, required bool dense}) {
    if (stacked) {
      return Column(
        children: [
          _startPeriodField(),
          SizedBox(height: AppDensity.formGap(context)),
          _endPeriodField(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _startPeriodField()),
        SizedBox(width: dense ? 5 : 7),
        Expanded(child: _endPeriodField()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayName = nthuDayNames[date.weekday - 1];
    final dayCode = nthuDayCode(date.weekday);
    final dense = AppDensity.compactMobile(context);
    final mediaSize = MediaQuery.sizeOf(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    final horizontalInset = AppDensity.dialogInset(context);
    final verticalInset = dense ? 8.0 : 16.0;
    final titleHorizontal = dense ? 12.0 : 18.0;
    final contentHorizontal = dense ? 12.0 : 18.0;
    final dialogWidth = math.min(
      440.0,
      math.max(0.0, mediaSize.width - (horizontalInset * 2)),
    );
    final dialogMaxHeight = math.max(
      0.0,
      mediaSize.height - (verticalInset * 2),
    );
    final contentWidth = math.max(0.0, dialogWidth - (contentHorizontal * 2));
    final stackPeriods = contentWidth < 300 || textScale > 1.4;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: horizontalInset,
        vertical: verticalInset,
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: dialogWidth,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: dialogMaxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  titleHorizontal,
                  dense ? 10 : 14,
                  titleHorizontal,
                  dense ? 6 : 10,
                ),
                child: Text(
                  widget.event == null ? 'Add event' : 'Edit event',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    contentHorizontal,
                    dense ? 4 : 6,
                    contentHorizontal,
                    dense ? 8 : 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: titleController,
                        autofocus: widget.event == null,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Event title',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      SizedBox(height: AppDensity.formGap(context)),
                      OutlinedButton.icon(
                        onPressed: saving ? null : pickDate,
                        icon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                        ),
                        label: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${dateLabel(date)} · $dayName ($dayCode)',
                          ),
                        ),
                      ),
                      SizedBox(height: AppDensity.formGap(context)),
                      _periodFields(stacked: stackPeriods, dense: dense),
                      SizedBox(height: dense ? 4 : 6),
                      Text(
                        'Timetable: ${nthuScheduleCode(dayCode: dayCode, startPeriod: startPeriod, endPeriod: endPeriod)}. Specific time is a note; periods set the block position.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: AppDensity.formGap(context)),
                      TextField(
                        controller: specificTimeController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Specific time (optional)',
                          hintText: 'e.g. 14:35–15:00',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      SizedBox(height: AppDensity.formGap(context)),
                      TextField(
                        controller: locationController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Location (optional)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      SizedBox(height: AppDensity.formGap(context)),
                      _reminderSection(),
                      SizedBox(height: AppDensity.formGap(context)),
                      TextField(
                        controller: notesController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  dense ? 8 : 12,
                  dense ? 6 : 8,
                  dense ? 8 : 12,
                  dense ? 6 : 10,
                ),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: dense ? 4 : 6,
                  runSpacing: dense ? 2 : 4,
                  children: [
                    TextButton(
                      onPressed: saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: saving ? null : save,
                      child: Text(saving ? 'Saving…' : 'Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
