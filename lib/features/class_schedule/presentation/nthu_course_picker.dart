import 'dart:async';

import '../../../app/theme/app_density.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/academic_database.dart';
import '../data/academic_snapshot.dart';
import '../data/nthu_catalog_repository.dart';
import '../domain/academic_types.dart';
import '../domain/course_draft.dart';
import '../domain/credit_progress.dart';
import '../domain/nthu_academic.dart';
import '../providers/academic_providers.dart';
import 'academic_data_view.dart';
import 'course_editor.dart';
import 'editor_support.dart';
import 'record_editors.dart';

Future<bool?> showNthuCoursePicker(
  BuildContext context, {
  required AcademicSnapshot data,
  required Semester semester,
}) => showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (_) => NthuCoursePickerDialog(data: data, semester: semester),
);

class NthuCoursePickerDialog extends ConsumerStatefulWidget {
  const NthuCoursePickerDialog({
    required this.data,
    required this.semester,
    super.key,
  });

  final AcademicSnapshot data;
  final Semester semester;

  @override
  ConsumerState<NthuCoursePickerDialog> createState() =>
      _NthuCoursePickerDialogState();
}

class _NthuCoursePickerDialogState
    extends ConsumerState<NthuCoursePickerDialog> {
  final searchController = TextEditingController();
  Timer? debounce;
  NthuCatalogSearchField searchField = NthuCatalogSearchField.all;
  String? selectedDepartment;
  String? selectedLanguage;
  List<String> availableDepartments = const [];
  List<String> availableLanguages = const [];
  List<NthuCatalogCourseModel> results = const [];
  List<GraduationCategory> categories = const [];
  NthuCatalogCourseModel? selected;
  NthuCatalogTerm? cachedTerm;
  String? selectedCategoryId;
  String? error;
  bool loading = true;
  bool importing = false;
  bool importedAny = false;
  bool showFilters = false;
  final Set<String> importedCourseIds = <String>{};

  NthuTerm? get term => inferNthuTerm(
    explicitCode: widget.semester.nthuTermCode,
    academicYear: widget.semester.academicYear,
    term: widget.semester.term,
    name: widget.semester.name,
  );

  CourseStatus get defaultStatus => switch (widget.semester.status) {
    SemesterStatus.planned => CourseStatus.planned,
    SemesterStatus.completed ||
    SemesterStatus.archived => CourseStatus.completed,
    SemesterStatus.current => CourseStatus.inProgress,
  };

  @override
  void initState() {
    super.initState();
    categories = widget.data.categories.where((item) => item.isActive).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openCatalog());
  }

  @override
  void dispose() {
    debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _openCatalog({bool forceRefresh = false}) async {
    final selectedTerm = term;
    if (selectedTerm == null) {
      setState(() {
        loading = false;
        error =
            'This semester is not linked to an NTHU term. Edit the semester and choose its NTHU term first.';
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    final repository = ref.read(nthuCatalogRepositoryProvider);
    try {
      var cache = await repository.cachedTerm(selectedTerm.code);
      final cacheNeedsParserRefresh =
          cache?.sourceType.startsWith('stale:') ?? false;
      if (forceRefresh || cache == null || cacheNeedsParserRefresh) {
        await repository.refresh(selectedTerm);
        cache = await repository.cachedTerm(selectedTerm.code);
      }
      await _loadCachedCatalog(repository, selectedTerm.code, cache: cache);
    } catch (e) {
      await _loadCachedCatalog(
        repository,
        selectedTerm.code,
        cache: await repository.cachedTerm(selectedTerm.code),
        fallbackError: '$e',
      );
    }
  }

  Future<void> _loadCachedCatalog(
    NthuCatalogRepository repository,
    String termCode, {
    NthuCatalogTerm? cache,
    String? fallbackError,
  }) async {
    final allCourses = await repository.search(termCode);
    final departments = _distinctCatalogValues(
      allCourses.map((course) => course.department),
    );
    final languages = _distinctCatalogValues(
      allCourses.map((course) => course.teachingLanguage),
    );
    final department = departments.contains(selectedDepartment)
        ? selectedDepartment
        : null;
    final language = languages.contains(selectedLanguage)
        ? selectedLanguage
        : null;
    final found = await repository.search(
      termCode,
      query: searchController.text,
      field: searchField,
      department: department,
      language: language,
    );
    if (!mounted) return;
    setState(() {
      cachedTerm = cache;
      availableDepartments = departments;
      availableLanguages = languages;
      selectedDepartment = department;
      selectedLanguage = language;
      results = found;
      loading = false;
      selected =
          selected != null && found.any((course) => course.id == selected!.id)
          ? selected
          : null;
      if (selected == null) selectedCategoryId = null;
      error = fallbackError == null
          ? null
          : found.isEmpty
          ? fallbackError
          : 'Refresh failed. Showing cached courses.';
    });
  }

  List<String> _distinctCatalogValues(Iterable<String> values) {
    final items =
        values
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return items;
  }

  void _queueSearch(String _) {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 180), _searchCached);
    setState(() {});
  }

  Future<void> _searchCached() async {
    final selectedTerm = term;
    if (selectedTerm == null) return;
    final found = await ref
        .read(nthuCatalogRepositoryProvider)
        .search(
          selectedTerm.code,
          query: searchController.text,
          field: searchField,
          department: selectedDepartment,
          language: selectedLanguage,
        );
    if (!mounted) return;
    setState(() {
      results = found;
      if (selected != null &&
          !found.any((course) => course.id == selected!.id)) {
        selected = null;
        selectedCategoryId = null;
      }
    });
  }

  void _changeSearchField(NthuCatalogSearchField? value) {
    if (value == null || value == searchField) return;
    setState(() => searchField = value);
    _searchCached();
  }

  void _changeDepartment(String? value) {
    final next = value == null || value.isEmpty ? null : value;
    if (next == selectedDepartment) return;
    setState(() => selectedDepartment = next);
    _searchCached();
  }

  void _changeLanguage(String? value) {
    final next = value == null || value.isEmpty ? null : value;
    if (next == selectedLanguage) return;
    setState(() => selectedLanguage = next);
    _searchCached();
  }

  void _clearSearchFilters() {
    debounce?.cancel();
    searchController.clear();
    setState(() {
      searchField = NthuCatalogSearchField.all;
      selectedDepartment = null;
      selectedLanguage = null;
    });
    _searchCached();
  }

  String _searchFieldLabel(NthuCatalogSearchField field) => switch (field) {
    NthuCatalogSearchField.all => 'All fields',
    NthuCatalogSearchField.name => 'Course name',
    NthuCatalogSearchField.code => 'Course code',
    NthuCatalogSearchField.professor => 'Professor',
    NthuCatalogSearchField.department => 'Department',
  };

  Future<void> _createManualCourse() async {
    final latest = await ref.read(academicRepositoryProvider).snapshot();
    if (!mounted) return;

    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          CourseEditor(data: latest, semesterId: widget.semester.id),
    );
    if (created != true || !mounted) return;

    setState(() => importedAny = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Custom course added to ${widget.semester.name}.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _manageCategories() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _CategoryManagerDialog(),
    );
    final latest = await ref.read(academicRepositoryProvider).snapshot();
    if (!mounted) return;
    final active = latest.categories.where((item) => item.isActive).toList();
    setState(() {
      categories = active;
      if (selectedCategoryId != null &&
          !active.any((item) => item.id == selectedCategoryId)) {
        selectedCategoryId = null;
      }
    });
  }

  Future<void> _importSelected() async {
    final course = selected;
    final categoryId = selectedCategoryId;
    if (course == null || categoryId == null || importing) return;

    final duplicate =
        importedCourseIds.contains(course.id) ||
        widget.data.courses.any(
          (existing) =>
              existing.semesterId == widget.semester.id &&
              existing.catalogCourseId == course.id,
        );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This NTHU course is already in the semester.'),
        ),
      );
      return;
    }

    setState(() => importing = true);
    try {
      await ref
          .read(academicRepositoryProvider)
          .saveCourse(
            CourseDraft(
              name: course.displayName,
              code: course.officialCourseCode,
              credits: course.credits,
              semesterId: widget.semester.id,
              categoryId: categoryId,
              status: defaultStatus,
              location: course.rawLocationText.trim().isEmpty
                  ? null
                  : course.rawLocationText.trim(),
              professor: course.instructorNames.isEmpty
                  ? null
                  : course.instructorNames.join(', '),
              catalogCourseId: course.id,
              englishName: course.englishName.trim().isEmpty
                  ? null
                  : course.englishName.trim(),
              teachingLanguage: course.teachingLanguage.trim().isEmpty
                  ? null
                  : course.teachingLanguage.trim(),
              meetings: [
                for (final meeting in course.meetings)
                  MeetingDraft.nthu(
                    dayCode: meeting.dayCode,
                    startPeriod: meeting.startPeriod,
                    endPeriod: meeting.endPeriod,
                    location: meeting.location,
                  ),
              ],
            ),
          );
      if (!mounted) return;
      setState(() {
        importedAny = true;
        importedCourseIds.add(course.id);
        importing = false;
        selected = null;
        selectedCategoryId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${course.displayName} added to ${widget.semester.name}.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        importing = false;
        error = errorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTerm = term;
    final theme = Theme.of(context);
    final visibleResults = results.take(120).toList();
    final hasActiveFilters =
        searchController.text.trim().isNotEmpty ||
        selectedDepartment != null ||
        selectedLanguage != null;

    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980, maxHeight: 760),
        child: LayoutBuilder(
          builder: (context, dialogBounds) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.school_outlined,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add NTHU course',
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            selectedTerm == null
                                ? widget.semester.name
                                : '${widget.semester.name} · ${selectedTerm.code} · ${selectedTerm.calendarLabel}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (importedAny)
                      TextButton(
                        onPressed: importing
                            ? null
                            : () => Navigator.pop(context, true),
                        child: const Text('Done'),
                      )
                    else
                      IconButton(
                        tooltip: 'Close',
                        onPressed: importing
                            ? null
                            : () => Navigator.pop(context, false),
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final compact =
                              constraints.maxWidth < 720 ||
                              MediaQuery.textScalerOf(context).scale(1) > 1.4;
                          final searchBox = TextField(
                            controller: searchController,
                            autofocus: false,
                            onChanged: _queueSearch,
                            decoration: InputDecoration(
                              hintText: 'Search NTHU courses',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Clear search text',
                                      onPressed: () {
                                        searchController.clear();
                                        setState(() {});
                                        _searchCached();
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          );
                          final fieldSelector =
                              DropdownButtonFormField<NthuCatalogSearchField>(
                                key: ValueKey(
                                  'catalog-search-field-${searchField.name}',
                                ),
                                initialValue: searchField,
                                isExpanded: true,
                                itemHeight: null,
                                decoration: const InputDecoration(
                                  labelText: 'Search by',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: [
                                  for (final field
                                      in NthuCatalogSearchField.values)
                                    DropdownMenuItem(
                                      value: field,
                                      child: Text(_searchFieldLabel(field)),
                                    ),
                                ],
                                onChanged: loading ? null : _changeSearchField,
                              );
                          final filterButton = IconButton(
                            tooltip: showFilters
                                ? 'Hide filters'
                                : 'Show filters',
                            isSelected:
                                showFilters ||
                                selectedDepartment != null ||
                                selectedLanguage != null,
                            onPressed: () =>
                                setState(() => showFilters = !showFilters),
                            icon: const Icon(Icons.filter_alt_outlined),
                          );
                          final refreshButton = IconButton.outlined(
                            tooltip: 'Refresh official NTHU catalog',
                            onPressed: loading
                                ? null
                                : () => _openCatalog(forceRefresh: true),
                            icon: const Icon(Icons.refresh),
                          );

                          final primaryControls = compact
                              ? Column(
                                  children: [
                                    searchBox,
                                    SizedBox(
                                      height: AppDensity.formGap(context),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(child: fieldSelector),
                                        const SizedBox(width: 6),
                                        filterButton,
                                        refreshButton,
                                      ],
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(child: searchBox),
                                    const SizedBox(width: 6),
                                    SizedBox(width: 160, child: fieldSelector),
                                    const SizedBox(width: 6),
                                    refreshButton,
                                  ],
                                );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              primaryControls,
                              if ((!compact || showFilters) &&
                                  (availableDepartments.isNotEmpty ||
                                      availableLanguages.isNotEmpty)) ...[
                                SizedBox(height: AppDensity.formGap(context)),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    if (availableDepartments.isNotEmpty)
                                      SizedBox(
                                        width: compact
                                            ? constraints.maxWidth
                                            : 260,
                                        child: DropdownButtonFormField<String>(
                                          key: ValueKey(
                                            'catalog-department-${selectedDepartment ?? 'all'}-${availableDepartments.length}',
                                          ),
                                          initialValue:
                                              selectedDepartment ?? '',
                                          isExpanded: true,
                                          itemHeight: null,
                                          decoration: const InputDecoration(
                                            labelText: 'Department',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          items: [
                                            const DropdownMenuItem(
                                              value: '',
                                              child: Text('All departments'),
                                            ),
                                            for (final department
                                                in availableDepartments)
                                              DropdownMenuItem(
                                                value: department,
                                                child: Text(
                                                  department,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                          ],
                                          onChanged: loading
                                              ? null
                                              : _changeDepartment,
                                        ),
                                      ),
                                    if (availableLanguages.isNotEmpty)
                                      SizedBox(
                                        width: compact
                                            ? constraints.maxWidth
                                            : 190,
                                        child: DropdownButtonFormField<String>(
                                          key: ValueKey(
                                            'catalog-language-${selectedLanguage ?? 'all'}-${availableLanguages.length}',
                                          ),
                                          initialValue: selectedLanguage ?? '',
                                          isExpanded: true,
                                          itemHeight: null,
                                          decoration: const InputDecoration(
                                            labelText: 'Teaching language',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          items: [
                                            const DropdownMenuItem(
                                              value: '',
                                              child: Text('All languages'),
                                            ),
                                            for (final language
                                                in availableLanguages)
                                              DropdownMenuItem(
                                                value: language,
                                                child: Text(
                                                  language,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                          ],
                                          onChanged: loading
                                              ? null
                                              : _changeLanguage,
                                        ),
                                      ),
                                    if (hasActiveFilters)
                                      TextButton.icon(
                                        onPressed: loading
                                            ? null
                                            : _clearSearchFilters,
                                        icon: const Icon(
                                          Icons.filter_alt_off_outlined,
                                        ),
                                        label: const Text('Clear filters'),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Text(
                              "Can't find your class in the official list?",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: importing ? null : _createManualCourse,
                              icon: const Icon(
                                Icons.edit_note_outlined,
                                size: 18,
                              ),
                              label: const Text('Create class manually'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (cachedTerm != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 5),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'NTHU official catalog · cached ${dateLabel(cachedTerm!.fetchedAt)}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  error!,
                                  style: TextStyle(
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (loading)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (visibleResults.isEmpty)
                      _EmptyCatalog(
                        hasQuery: hasActiveFilters,
                        onRetry: () => _openCatalog(forceRefresh: true),
                        onCreateManual: _createManualCourse,
                      )
                    else
                      for (final course in visibleResults)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: _CourseResultTile(
                            course: course,
                            selected: selected?.id == course.id,
                            alreadyAdded:
                                importedCourseIds.contains(course.id) ||
                                widget.data.courses.any(
                                  (existing) =>
                                      existing.semesterId ==
                                          widget.semester.id &&
                                      existing.catalogCourseId == course.id,
                                ),
                            onTap: () => setState(() {
                              selected = course;
                              selectedCategoryId = null;
                            }),
                          ),
                        ),
                  ],
                ),
              ),
              if (selected != null) ...[
                const Divider(height: 1),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: dialogBounds.maxHeight * .42,
                  ),
                  child: SingleChildScrollView(
                    child: _ImportBar(
                      course: selected!,
                      categories: categories,
                      selectedCategoryId: selectedCategoryId,
                      status: defaultStatus,
                      importing: importing,
                      onCategoryChanged: (value) =>
                          setState(() => selectedCategoryId = value),
                      onManageCategories: _manageCategories,
                      onImport: selectedCategoryId == null
                          ? null
                          : _importSelected,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseResultTile extends StatelessWidget {
  const _CourseResultTile({
    required this.course,
    required this.selected,
    required this.alreadyAdded,
    required this.onTap,
  });

  final NthuCatalogCourseModel course;
  final bool selected;
  final bool alreadyAdded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schedule = course.meetings.isEmpty
        ? 'Schedule not listed'
        : course.meetings.map((item) => item.scheduleCode).join(' · ');
    final location = course.rawLocationText.trim();
    return Material(
      color: selected
          ? theme.colorScheme.secondaryContainer
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: alreadyAdded ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            course.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${creditLabel(course.credits)} cr',
                          style: theme.textTheme.labelLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.officialCourseCode} · $schedule',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (course.department.trim().isNotEmpty ||
                        course.instructorNames.isNotEmpty ||
                        course.teachingLanguage.trim().isNotEmpty ||
                        location.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          [
                            if (course.department.trim().isNotEmpty)
                              course.department.trim(),
                            if (course.instructorNames.isNotEmpty)
                              course.instructorNames.join(', '),
                            if (course.teachingLanguage.trim().isNotEmpty)
                              course.teachingLanguage.trim(),
                            if (location.isNotEmpty) location,
                          ].join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (alreadyAdded)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Chip(label: Text('Added')),
                )
              else
                Icon(
                  selected ? Icons.check_circle : Icons.chevron_right,
                  color: selected ? theme.colorScheme.primary : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportBar extends StatelessWidget {
  const _ImportBar({
    required this.course,
    required this.categories,
    required this.selectedCategoryId,
    required this.status,
    required this.importing,
    required this.onCategoryChanged,
    required this.onManageCategories,
    required this.onImport,
  });

  final NthuCatalogCourseModel course;
  final List<GraduationCategory> categories;
  final String? selectedCategoryId;
  final CourseStatus status;
  final bool importing;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onManageCategories;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 9),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 700 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.4;
          final categoryField = DropdownButtonFormField<String>(
            key: ValueKey(
              'nthu-import-category-${selectedCategoryId ?? 'none'}-${categories.length}',
            ),
            initialValue: selectedCategoryId,
            isExpanded: true,
            itemHeight:
                48 *
                MediaQuery.textScalerOf(
                  context,
                ).scale(1).clamp(1, double.infinity),
            decoration: const InputDecoration(
              labelText: 'Graduation category *',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              for (final category in categories)
                DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
            ],
            onChanged: importing ? null : onCategoryChanged,
          );
          final manageButton = TextButton(
            onPressed: importing ? null : onManageCategories,
            child: const Text('Manage', softWrap: false),
          );
          final categoryControl =
              MediaQuery.textScalerOf(context).scale(1) > 1.4
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    categoryField,
                    Align(
                      alignment: Alignment.centerRight,
                      child: manageButton,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: categoryField),
                    const SizedBox(width: 6),
                    manageButton,
                  ],
                );

          final summary = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(course.displayName, style: theme.textTheme.titleSmall),
              Text(
                '${course.officialCourseCode} · ${creditLabel(course.credits)} credits · ${statusLabel(status)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );

          final addButton = FilledButton.icon(
            onPressed: importing ? null : onImport,
            icon: importing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
            label: Text(importing ? 'Adding…' : 'Add course'),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                summary,
                const SizedBox(height: 6),
                categoryControl,
                const SizedBox(height: 6),
                addButton,
              ],
            );
          }
          return Row(
            children: [
              SizedBox(width: 210, child: summary),
              const SizedBox(width: 10),
              Expanded(child: categoryControl),
              const SizedBox(width: 6),
              addButton,
            ],
          );
        },
      ),
    );
  }
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog({
    required this.hasQuery,
    required this.onRetry,
    required this.onCreateManual,
  });

  final bool hasQuery;
  final VoidCallback onRetry;
  final VoidCallback onCreateManual;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasQuery ? Icons.search_off : Icons.cloud_off_outlined,
            size: 36,
          ),
          const SizedBox(height: 6),
          Text(
            hasQuery
                ? 'No NTHU courses match this search.'
                : 'No official courses are cached for this semester.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            runSpacing: 5,
            children: [
              if (!hasQuery)
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry official catalog'),
                ),
              FilledButton.tonalIcon(
                onPressed: onCreateManual,
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Create class manually'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _CategoryManagerDialog extends StatelessWidget {
  const _CategoryManagerDialog();

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 6, 5),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Graduation categories',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: AcademicDataView(
              builder: (data) => ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) =>
                          CategoryEditor(sortOrder: data.categories.length),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add category'),
                  ),
                  const SizedBox(height: 5),
                  for (final category in data.categories)
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: Icon(
                        category.isActive
                            ? Icons.label_outline
                            : Icons.visibility_off_outlined,
                      ),
                      title: Text(category.name),
                      subtitle: Text(
                        category.requiredCredits == null
                            ? 'No credit requirement set'
                            : '${creditLabel(category.requiredCredits!)} credits required',
                      ),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => CategoryEditor(category: category),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
