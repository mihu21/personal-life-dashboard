import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/academic_types.dart';
import '../domain/nthu_academic.dart';
import '../domain/one_time_event.dart';
import '../providers/academic_providers.dart';
import 'one_time_event_editor.dart';

Future<void> showOneTimeEventDetails(
  BuildContext context, {
  required OneTimeEvent event,
}) => showDialog<void>(
  context: context,
  builder: (_) => OneTimeEventDetails(initialEvent: event),
);

class OneTimeEventDetails extends ConsumerWidget {
  const OneTimeEventDetails({required this.initialEvent, super.key});

  final OneTimeEvent initialEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(oneTimeEventsProvider).asData?.value;
    final event = loaded
            ?.where((item) => item.id == initialEvent.id)
            .firstOrNull ??
        initialEvent;
    final start = nthuPeriod(event.startPeriod);
    final end = nthuPeriod(event.endPeriod);
    final timetableTime = start != null && end != null
        ? '${start.startLabel}–${end.endLabel}'
        : 'Periods ${event.startPeriod}–${event.endPeriod}';
    final dayName = nthuDayNames[event.date.weekday - 1];

    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(event.title)),
          if (event.reminderMinutesBefore.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.notifications_active_outlined, size: 20),
            ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: '$dayName · ${dateLabel(event.date)}',
              ),
              _DetailRow(
                icon: Icons.schedule_outlined,
                label: event.specificTime.trim().isEmpty
                    ? timetableTime
                    : '${event.specificTime.trim()} · timetable $timetableTime',
              ),
              if (event.location.trim().isNotEmpty)
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: event.location.trim(),
                ),
              _DetailRow(
                icon: event.reminderMinutesBefore.isEmpty
                    ? Icons.notifications_none_outlined
                    : Icons.notifications_active_outlined,
                label: event.reminderMinutesBefore.isEmpty
                    ? 'No reminders'
                    : (event.reminderMinutesBefore.toList()..sort())
                        .map(reminderLabel)
                        .join(' · '),
              ),
              const SizedBox(height: 10),
              Text('Notes', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 72,
                  maxHeight: 220,
                ),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: event.notes.trim().isEmpty
                    ? Text(
                        'No notes.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Scrollbar(
                        child: SingleChildScrollView(
                          child: SelectableText(event.notes.trim()),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => _delete(context, ref, event),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete'),
        ),
        OutlinedButton.icon(
          onPressed: () => showOneTimeEventEditor(context, event: event),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    OneTimeEvent event,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text(
          'Delete “${event.title}”? Its scheduled reminders will also be cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete event'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final repository = ref.read(oneTimeEventRepositoryProvider);
    String? notificationWarning;
    try {
      await repository.delete(event.id);
      try {
        await ref.read(eventNotificationServiceProvider).cancelEvent(event);
      } catch (error) {
        notificationWarning =
            'Event deleted, but an old system reminder could not be cancelled: $error';
      }
      ref.invalidate(oneTimeEventsProvider);
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      if (notificationWarning != null) {
        messenger.showSnackBar(SnackBar(content: Text(notificationWarning)));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete event: $error')),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
      ],
    ),
  );
}
