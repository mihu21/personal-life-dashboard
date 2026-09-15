import 'package:flutter/material.dart';

import '../../../app/theme/app_density.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/academic_database.dart';
import '../data/academic_snapshot.dart';
import '../domain/academic_types.dart';
import '../domain/nthu_academic.dart';
import '../providers/academic_providers.dart';
import 'editor_support.dart';

class SemesterEditor extends ConsumerStatefulWidget {
  const SemesterEditor({this.semester, this.planned = false, super.key});
  final Semester? semester;
  final bool planned;
  @override
  ConsumerState<SemesterEditor> createState() => _SemesterEditorState();
}

class _SemesterEditorState extends ConsumerState<SemesterEditor>
    with EditorState {
  late final name = TextEditingController(text: widget.semester?.name);
  late final year = TextEditingController(
    text: widget.semester?.academicYear ?? '${DateTime.now().year}',
  );
  late final term = TextEditingController(
    text: widget.semester?.term ?? 'Fall',
  );
  late DateTime start = widget.semester?.startDate ?? dateOnly(DateTime.now());
  late DateTime end =
      widget.semester?.endDate ??
      DateTime(start.year, start.month + 5, start.day);
  late SemesterStatus status =
      widget.semester?.status ??
      (widget.planned ? SemesterStatus.planned : SemesterStatus.current);
  late NthuTerm? selectedNthuTerm =
      inferNthuTerm(
        explicitCode: widget.semester?.nthuTermCode,
        academicYear: widget.semester?.academicYear ?? '',
        term: widget.semester?.term ?? '',
        name: widget.semester?.name,
      ) ??
      (widget.semester == null ? NthuTerm.current(DateTime.now()) : null);

  List<NthuTerm> get availableTerms {
    final current = NthuTerm.current(DateTime.now());
    return [
      for (
        var academicYear = 113;
        academicYear <= current.academicYear + 2;
        academicYear++
      ) ...[NthuTerm('${academicYear}10'), NthuTerm('${academicYear}20')],
    ];
  }

  @override
  void initState() {
    super.initState();
    if (widget.semester == null && selectedNthuTerm != null) {
      _applyNthuTerm(selectedNthuTerm!);
    }
  }

  void _applyNthuTerm(NthuTerm value) {
    name.text = value.displayName;
    year.text = '${value.academicYear}';
    term.text = value.season;
    start = value.approximateStart;
    end = value.approximateEnd;
  }

  @override
  void dispose() {
    name.dispose();
    year.dispose();
    term.dispose();
    super.dispose();
  }

  Future<void> _deleteSemester() async {
    final semester = widget.semester;
    if (semester == null || saving) return;

    try {
      final repository = ref.read(academicRepositoryProvider);
      final data = await repository.snapshot();
      final courseCount = data.coursesIn(semester.id).length;
      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete semester?'),
          content: Text(
            courseCount == 0
                ? 'Delete “${semester.name}”? This cannot be undone.'
                : 'Delete “${semester.name}”? This semester contains '
                      '$courseCount course${courseCount == 1 ? '' : 's'}. '
                      'Deleting it will also permanently remove all of those '
                      'courses, their meetings, one-off schedule changes, and '
                      'course tag links.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                courseCount == 0 ? 'Delete semester' : 'Delete semester & courses',
              ),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      setState(() {
        saving = true;
        error = null;
      });
      await repository.removeSemester(
        semester.id,
        confirmed: courseCount > 0,
      );
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

  @override
  Widget build(BuildContext context) => EditorFrame(
    title: widget.semester == null ? 'Create semester' : 'Edit semester',
    formKey: formKey,
    saving: saving,
    error: error,
    onSave: () => submit(
      () => ref
          .read(academicRepositoryProvider)
          .saveSemester(
            id: widget.semester?.id,
            name: name.text,
            academicYear: year.text,
            term: term.text,
            start: start,
            end: end,
            status: status,
            nthuTermCode: selectedNthuTerm?.code,
          ),
    ),
    child: Column(
      spacing: AppDensity.formGap(context),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: selectedNthuTerm?.code,
          isExpanded: true,
          itemHeight: null,
          decoration: const InputDecoration(
            labelText: 'NTHU term',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            for (final value in availableTerms.reversed)
              DropdownMenuItem(
                value: value.code,
                child: Text('${value.displayName} · ${value.calendarLabel}'),
              ),
          ],
          validator: (value) =>
              value == null ? 'Select the official NTHU semester.' : null,
          onChanged: (code) {
            if (code == null) return;
            final value = NthuTerm(code);
            setState(() {
              selectedNthuTerm = value;
              _applyNthuTerm(value);
            });
          },
        ),
        editorField(name, 'Semester name', required: true),
        DateField(
          label: 'Start',
          date: start,
          onChanged: (value) => setState(() => start = value),
        ),
        DateField(
          label: 'End',
          date: end,
          onChanged: (value) => setState(() => end = value),
        ),
        enumField(
          'Semester status',
          status,
          SemesterStatus.values,
          (value) => setState(() => status = value),
        ),
        const Text(
          'Making a semester current closes the previous current semester. Course statuses and historical records stay unchanged.',
        ),
        if (widget.semester != null) ...[
          const Divider(),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: saving ? null : _deleteSemester,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete semester'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class CategoryEditor extends ConsumerStatefulWidget {
  const CategoryEditor({this.category, this.sortOrder = 0, super.key});
  final GraduationCategory? category;
  final int sortOrder;
  @override
  ConsumerState<CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends ConsumerState<CategoryEditor>
    with EditorState {
  late final name = TextEditingController(text: widget.category?.name);
  late final credits = TextEditingController(
    text: widget.category?.requiredCredits?.toString() ?? '',
  );
  late final description = TextEditingController(
    text: widget.category?.description,
  );
  late bool active = widget.category?.isActive ?? true;
  @override
  void dispose() {
    name.dispose();
    credits.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> _deleteCategory() async {
    final category = widget.category;
    if (category == null) return;
    final confirmed = await confirmAction(
      context,
      'Delete ${category.name}? This is only allowed when no courses are assigned to it.',
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(academicRepositoryProvider).removeCategory(category.id);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = errorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) => EditorFrame(
    title: widget.category == null ? 'Add category' : 'Edit category',
    formKey: formKey,
    saving: saving,
    error: error,
    onSave: () => submit(
      () => ref
          .read(academicRepositoryProvider)
          .saveCategory(
            id: widget.category?.id,
            name: name.text,
            requiredCredits: credits.text.trim().isEmpty
                ? null
                : double.parse(credits.text),
            description: description.text,
            sortOrder: widget.category?.sortOrder ?? widget.sortOrder,
            isActive: active,
          ),
    ),
    child: Column(
      spacing: AppDensity.formGap(context),
      children: [
        editorField(name, 'Category name', required: true),
        editorField(
          credits,
          'Required / max counted credits (optional)',
          numeric: true,
          validator: creditTargetValidator,
        ),
        editorField(description, 'Description', lines: 2),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Active category'),
          subtitle: const Text(
            'Hidden categories keep their existing courses and credits.',
          ),
          value: active,
          onChanged: (value) => setState(() => active = value),
        ),
        if (widget.category != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: saving ? null : _deleteCategory,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete category'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    ),
  );
}

String? creditTargetValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final credits = double.tryParse(value);
  return credits != null && credits.isFinite && credits >= 0
      ? null
      : 'Enter a non-negative credit target.';
}

class RequirementEditor extends ConsumerStatefulWidget {
  const RequirementEditor({this.requiredCredits, super.key});
  final double? requiredCredits;
  @override
  ConsumerState<RequirementEditor> createState() => _RequirementEditorState();
}

class _RequirementEditorState extends ConsumerState<RequirementEditor>
    with EditorState {
  late final credits = TextEditingController(
    text: widget.requiredCredits?.toString() ?? '',
  );
  @override
  void dispose() {
    credits.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => EditorFrame(
    title: 'Graduation requirement',
    formKey: formKey,
    saving: saving,
    error: error,
    onSave: () => submit(
      () => ref
          .read(academicRepositoryProvider)
          .saveSettings(
            requiredCredits: credits.text.trim().isEmpty
                ? null
                : double.parse(credits.text),
          ),
    ),
    child: editorField(
      credits,
      'Overall required credits (optional)',
      numeric: true,
      validator: creditTargetValidator,
    ),
  );
}

class GraduationRequirementsEditor extends ConsumerStatefulWidget {
  const GraduationRequirementsEditor({required this.data, super.key});

  final AcademicSnapshot data;

  @override
  ConsumerState<GraduationRequirementsEditor> createState() =>
      _GraduationRequirementsEditorState();
}

class _GraduationRequirementsEditorState
    extends ConsumerState<GraduationRequirementsEditor>
    with EditorState {
  late final overall = TextEditingController(
    text: widget.data.settings.requiredCredits?.toString() ?? '',
  );
  late List<GraduationCategory> categories = [...widget.data.categories];
  final Map<String, TextEditingController> categoryCredits = {};

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  void _syncControllers() {
    for (final category in categories) {
      categoryCredits.putIfAbsent(
        category.id,
        () => TextEditingController(
          text: category.requiredCredits?.toString() ?? '',
        ),
      );
    }
  }

  Future<void> _refreshCategories() async {
    final latest = await ref.read(academicRepositoryProvider).snapshot();
    if (!mounted) return;
    setState(() {
      categories = [...latest.categories];
      _syncControllers();
    });
  }

  @override
  void dispose() {
    overall.dispose();
    for (final controller in categoryCredits.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double? _value(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : double.parse(text);
  }

  Future<void> _deleteCategory(GraduationCategory category) async {
    final confirmed = await confirmAction(
      context,
      'Delete ${category.name}? This is only allowed when no courses are assigned to it.',
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(academicRepositoryProvider).removeCategory(category.id);
      await _refreshCategories();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => EditorFrame(
    title: 'Graduation requirements',
    formKey: formKey,
    saving: saving,
    error: error,
    onSave: () => submit(() async {
      final repository = ref.read(academicRepositoryProvider);
      await repository.saveSettings(requiredCredits: _value(overall));
      for (final category in categories) {
        await repository.saveCategory(
          id: category.id,
          name: category.name,
          requiredCredits: _value(categoryCredits[category.id]!),
          description: category.description,
          sortOrder: category.sortOrder,
          isActive: category.isActive,
        );
      }
      return null;
    }),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Set your overall requirement and each category target. A category target is also the maximum counted there; overflow credits roll into Free Elective.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        editorField(
          overall,
          'Overall credits required',
          numeric: true,
          validator: creditTargetValidator,
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              'Category requirements',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (_) => CategoryEditor(sortOrder: categories.length),
                );
                await _refreshCategories();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add category'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (final category in categories)
          Padding(
            padding: EdgeInsets.only(bottom: AppDensity.formGap(context)),
            child: FormFieldsRow(
              minFieldWidth: 240,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (!category.isActive)
                            Text(
                              'Archived',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: 'Edit ${category.name}',
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (_) => CategoryEditor(category: category),
                        );
                        await _refreshCategories();
                      },
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip:
                          category.name.trim().toLowerCase() == 'free elective'
                          ? 'Free Elective is required for overflow credits'
                          : 'Delete ${category.name}',
                      onPressed:
                          category.name.trim().toLowerCase() == 'free elective'
                          ? null
                          : () => _deleteCategory(category),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                editorField(
                  categoryCredits[category.id]!,
                  'Required / max',
                  numeric: true,
                  validator: creditTargetValidator,
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
