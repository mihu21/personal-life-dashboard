import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../class_schedule/data/academic_database.dart';
import '../domain/task_types.dart';
import '../providers/task_providers.dart';

Future<void> showTaskCategories(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) => const TaskCategoriesDialog(),
);

class TaskCategoriesDialog extends ConsumerWidget {
  const TaskCategoriesDialog({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(taskCategoriesProvider);
    return AlertDialog(
      title: const Text('Task categories'),
      scrollable: true,
      content: SizedBox(
        width: 480,
        child: categories.when(
          loading: () => const Text('Loading categories…'),
          error: (e, _) => Text('$e'),
          data: (items) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final c in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 10,
                    backgroundColor: Color(c.color),
                  ),
                  title: Text(c.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit ${c.name}',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => edit(context, c),
                      ),
                      IconButton(
                        tooltip: 'Remove ${c.name}',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: items.length < 2
                            ? null
                            : () => remove(context, ref, c, items),
                      ),
                    ],
                  ),
                ),
              TextButton.icon(
                onPressed: () => edit(context, null),
                icon: const Icon(Icons.add),
                label: const Text('Add category'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Future<void> edit(BuildContext context, TaskCategoryRecord? category) =>
      showDialog<void>(
        context: context,
        builder: (_) => _CategoryEditor(category),
      );
  Future<void> remove(
    BuildContext context,
    WidgetRef ref,
    TaskCategoryRecord category,
    List<TaskCategoryRecord> items,
  ) async {
    var replacement = items.firstWhere((c) => c.name != category.name).name;
    String? error;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Remove ${category.name}?'),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Keep all tasks and move them to another category.'),
              DropdownButtonFormField<String>(
                initialValue: replacement,
                isExpanded: true,
                itemHeight: null,
                decoration: const InputDecoration(labelText: 'Move tasks to'),
                items: [
                  for (final c in items.where((c) => c.name != category.name))
                    DropdownMenuItem(value: c.name, child: Text(c.name)),
                ],
                onChanged: (v) => replacement = v!,
              ),
              if (error != null) Text(error!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await ref
                      .read(taskRepositoryProvider)
                      .removeCategory(category.name, replacement);
                  ref.invalidate(taskFilterProvider);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) setState(() => error = '$e');
                }
              },
              child: const Text('Remove category'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryEditor extends ConsumerStatefulWidget {
  const _CategoryEditor(this.category);
  final TaskCategoryRecord? category;
  @override
  ConsumerState<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends ConsumerState<_CategoryEditor> {
  late final name = TextEditingController(text: widget.category?.name);
  late final hex = TextEditingController(
    text: (widget.category?.color ?? 0xFF68BAA9)
        .toRadixString(16)
        .substring(2)
        .toUpperCase(),
  );
  String? error;
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    hex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.category == null ? 'Add category' : 'Edit category'),
    scrollable: true,
    content: SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: name,
            maxLength: 50,
            decoration: const InputDecoration(labelText: 'Category name'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final color in {
                ...defaultTaskCategoryColors.values,
                0xFFEC87C0,
                0xFF85B56B,
                0xFFE87C59,
                0xFF85C9CF,
              })
                IconButton(
                  tooltip:
                      '#${color.toRadixString(16).substring(2).toUpperCase()}',
                  onPressed: () => setState(
                    () => hex.text = color
                        .toRadixString(16)
                        .substring(2)
                        .toUpperCase(),
                  ),
                  icon: Icon(
                    hex.text.toLowerCase() ==
                            color.toRadixString(16).substring(2)
                        ? Icons.check_circle
                        : Icons.circle,
                    color: Color(color),
                    size: 30,
                  ),
                ),
            ],
          ),
          TextField(
            controller: hex,
            decoration: const InputDecoration(
              labelText: 'Color (six-digit hex)',
              prefixText: '#',
            ),
          ),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: saving
            ? null
            : () async {
                if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex.text.trim())) {
                  setState(
                    () => error = 'Enter six hex digits, such as 68BAA9.',
                  );
                  return;
                }
                setState(() => saving = true);
                try {
                  await ref
                      .read(taskRepositoryProvider)
                      .saveCategory(
                        name.text,
                        0xFF000000 | int.parse(hex.text.trim(), radix: 16),
                        previousName: widget.category?.name,
                      );
                  ref.invalidate(taskFilterProvider);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      error = '$e';
                      saving = false;
                    });
                  }
                }
              },
        child: const Text('Save category'),
      ),
    ],
  );
}
