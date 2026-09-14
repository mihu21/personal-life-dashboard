import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_density.dart';

import '../domain/academic_types.dart';

String errorMessage(Object error) => error is ArgumentError
    ? '${error.message}'
    : 'Unable to save. Please try again. ($error)';

Future<bool> confirmAction(
  BuildContext context,
  String message, {
  String action = 'Delete',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;

Future<void> runAction(
  BuildContext context,
  Future<Object?> Function() action,
) async {
  try {
    await action();
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage(error))));
    }
  }
}

mixin EditorState<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final formKey = GlobalKey<FormState>();
  bool saving = false;
  String? error;
  Future<void> submit(
    Future<Object?> Function() action, {
    Future<bool> Function()? beforeSave,
  }) async {
    if (saving || !formKey.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      if (beforeSave != null && !await beforeSave()) {
        if (mounted) setState(() => saving = false);
        return;
      }
      await action();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = errorMessage(e);
          saving = false;
        });
      }
    }
  }
}

class EditorFrame extends StatelessWidget {
  const EditorFrame({
    required this.title,
    required this.formKey,
    required this.child,
    required this.onSave,
    this.saving = false,
    this.error,
    super.key,
  });
  final String title;
  final GlobalKey<FormState> formKey;
  final Widget child;
  final VoidCallback onSave;
  final bool saving;
  final String? error;

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: EdgeInsets.symmetric(
      horizontal: AppDensity.dialogInset(context),
      vertical: 12,
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Padding(
        padding: EdgeInsets.all(AppDensity.compactMobile(context) ? 10 : 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: AppDensity.cardPadding(context)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 6, bottom: 2),
                child: Form(key: formKey, child: child),
              ),
            ),
            if (error != null)
              Padding(
                padding: EdgeInsets.only(top: AppDensity.sectionGap(context)),
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            SizedBox(height: AppDensity.cardPadding(context)),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppDensity.controlGap(context),
              children: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving ? null : onSave,
                  child: Text(saving ? 'Saving…' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget editorField(
  TextEditingController controller,
  String label, {
  bool required = false,
  bool numeric = false,
  int lines = 1,
  String? Function(String?)? validator,
}) => TextFormField(
  controller: controller,
  decoration: InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
  ),
  keyboardType: numeric
      ? const TextInputType.numberWithOptions(decimal: true)
      : TextInputType.text,
  maxLines: lines,
  validator:
      validator ??
      (value) => required && (value?.trim().isEmpty ?? true)
          ? '$label is required.'
          : null,
);

/// Form rows expand vertically at large text scales or narrow local widths.
/// Use in bounded dialog content, not intrinsic-sized AlertDialog content.
class FormFieldsRow extends StatelessWidget {
  const FormFieldsRow({
    required this.children,
    this.minFieldWidth = 170,
    super.key,
  });
  final List<Widget> children;
  final double minFieldWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final gap = AppDensity.formGap(context);
      final scale = MediaQuery.textScalerOf(context).scale(1);
      if (constraints.maxWidth <
          children.length * minFieldWidth * scale +
              gap * (children.length - 1)) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: children,
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: gap,
        children: [for (final child in children) Expanded(child: child)],
      );
    },
  );
}

Widget enumField<T extends Enum>(
  String label,
  T value,
  List<T> values,
  ValueChanged<T> onChanged,
) => DropdownButtonFormField<T>(
  initialValue: value,
  isExpanded: true,
  itemHeight: null,
  decoration: InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
  ),
  items: [
    for (final item in values)
      DropdownMenuItem(value: item, child: Text(statusLabel(item))),
  ],
  onChanged: (value) {
    if (value != null) onChanged(value);
  },
);

class DateField extends StatelessWidget {
  const DateField({
    required this.label,
    required this.date,
    required this.onChanged,
    super.key,
  });
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
    icon: const Icon(Icons.calendar_today_outlined, size: 17),
    label: Text('$label: ${dateLabel(date)}'),
    onPressed: () async {
      final value = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(1900),
        lastDate: DateTime(2200),
      );
      if (value != null) onChanged(value);
    },
  );
}
