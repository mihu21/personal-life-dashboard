import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/note_plus_repository.dart';
import '../domain/note_plus_types.dart';
import '../providers/note_plus_providers.dart';

const _noteAccent = Color(0xFF9A6930);

void openFullNotePlus(BuildContext context) => Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Note+')),
          body: const SafeArea(child: NotePlusModule(showTitle: false)),
        ),
      ),
    );

Future<void> openFullNoteList(BuildContext context, String listId) =>
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => NoteListPage(listId: listId)),
    );

enum _CreatedEntryKind { note, list }

class _CreatedEntry {
  const _CreatedEntry(this.kind, this.id);

  final _CreatedEntryKind kind;
  final String id;
}

Future<String?> _showNotePlusCreateMenu(BuildContext context) =>
    showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Create', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.note_alt_outlined),
                  title: const Text('Note'),
                  subtitle: const Text('A regular free-form note'),
                  onTap: () => Navigator.pop(context, 'note'),
                ),
                ListTile(
                  leading: const Icon(Icons.table_rows_outlined),
                  title: const Text('Blank list'),
                  subtitle: const Text(
                    'Start with a Name property and build your own structure',
                  ),
                  onTap: () => Navigator.pop(context, 'blank'),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Text(
                    'Templates',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                for (var i = 0; i < noteListTemplates.length; i++)
                  ListTile(
                    leading: Icon(_iconFor(noteListTemplates[i].icon)),
                    title: Text(noteListTemplates[i].name),
                    subtitle: Text(
                      noteListTemplates[i]
                          .properties
                          .map((property) => property.name)
                          .join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => Navigator.pop(context, 'template:$i'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

Future<String?> _askForNameDialog(
  BuildContext context,
  String title,
  String label, {
  String initial = '',
}) async {
  final controller = TextEditingController(text: initial);
  String? errorText;
  var submitting = false;

  final navigator = Navigator.of(context, rootNavigator: true);
  late final DialogRoute<String> route;
  route = DialogRoute<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setLocalState) {
        void submit() {
          if (submitting) return;
          final value = controller.text.trim();
          if (value.isEmpty) {
            setLocalState(() => errorText = 'Please enter a list name.');
            return;
          }
          submitting = true;
          FocusScope.of(dialogContext).unfocus();
          Navigator.of(dialogContext).pop(value);
        }

        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: label,
              errorText: errorText,
            ),
            onChanged: (_) {
              if (errorText != null) setLocalState(() => errorText = null);
            },
            onSubmitted: (_) => submit(),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: submitting ? null : submit,
              child: const Text('Continue'),
            ),
          ],
        );
      },
    ),
  );

  final result = await navigator.push<String>(route);
  // Wait until the dialog's reverse transition and overlay removal are fully
  // complete before the caller opens the next dialog. This keeps keyboard
  // submission (Enter) on the same safe path as clicking Continue.
  await route.completed;
  controller.dispose();
  return result;
}

Future<_CreatedEntry?> _createNotePlusEntry(
  BuildContext context,
  WidgetRef ref,
) async {
  final choice = await _showNotePlusCreateMenu(context);
  if (choice == null || !context.mounted) return null;
  final repo = ref.read(notePlusRepositoryProvider);

  if (choice == 'note') {
    final id = await showDialog<String>(
      context: context,
      builder: (_) => const _NoteEditor(),
    );
    if (id == null) return null;
    return _CreatedEntry(_CreatedEntryKind.note, id);
  }

  NoteListTemplate? template;
  if (choice.startsWith('template:')) {
    final index = int.parse(choice.split(':').last);
    template = noteListTemplates[index];
  }
  final name = await _askForNameDialog(
    context,
    'New list',
    'List name',
    initial: template?.name ?? '',
  );
  if (name == null || !context.mounted) return null;

  final id = await repo.createList(
    name: name,
    icon: template?.icon ?? 'list',
    properties: template?.properties,
  );
  final snapshot = await repo.load();
  if (!context.mounted) return _CreatedEntry(_CreatedEntryKind.list, id);
  final bundle = snapshot.lists.firstWhere((entry) => entry.list.id == id);
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PropertiesDialog(bundle: bundle),
  );
  return _CreatedEntry(_CreatedEntryKind.list, id);
}

class NotePlusModule extends ConsumerStatefulWidget {
  const NotePlusModule({this.showTitle = true, super.key});
  final bool showTitle;

  @override
  ConsumerState<NotePlusModule> createState() => _NotePlusModuleState();
}

class _NotePlusModuleState extends ConsumerState<NotePlusModule> {
  final _search = TextEditingController();
  bool _showArchived = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(notePlusProvider);
    final snapshot = data.asData?.value;
    final activeEntries = snapshot?.orderedEntries
            .where((entry) => !entry.archived)
            .toList() ??
        const <NotePlusEntry>[];
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showTitle) ...[
            Text('Note+', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final compactControls = constraints.maxWidth < 520 ||
                  MediaQuery.textScalerOf(context).scale(14) > 20;
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search notes & lists',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Arrange notes & lists',
                    onPressed: !_showArchived && activeEntries.length > 1
                        ? () => _arrangeEntries(activeEntries)
                        : null,
                    icon: const Icon(Icons.swap_vert_rounded),
                  ),
                  const SizedBox(width: 4),
                  IconButton.filledTonal(
                    tooltip: _showArchived ? 'Show active' : 'Show archive',
                    onPressed: () =>
                        setState(() => _showArchived = !_showArchived),
                    icon: Icon(
                      _showArchived
                          ? Icons.inventory_2
                          : Icons.archive_outlined,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (compactControls)
                    IconButton.filled(
                      tooltip: 'Create note or list',
                      onPressed: _createEntry,
                      icon: const Icon(Icons.add),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _createEntry,
                      icon: const Icon(Icons.add),
                      label: const Text('New'),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: data.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Could not load Note+: $error')),
              data: _buildContent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(NotePlusSnapshot snapshot) {
    final query = _search.text.trim().toLowerCase();
    final entries = snapshot.orderedEntries.where((entry) {
      if (entry.archived != _showArchived) return false;
      if (query.isEmpty) return true;
      if (entry.kind == NotePlusEntryKind.note) {
        final note = entry.note!;
        return note.title.toLowerCase().contains(query) ||
            note.body.toLowerCase().contains(query);
      }
      final bundle = entry.bundle!;
      if (bundle.list.name.toLowerCase().contains(query)) return true;
      return bundle.items.any(
        (item) => item.values.values.any(
          (value) => value?.toString().toLowerCase().contains(query) ?? false,
        ),
      );
    }).toList();

    if (entries.isEmpty) {
      return _EmptyState(
        archived: _showArchived,
        hasQuery: query.isNotEmpty,
        onCreate: _createEntry,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1050
            ? 4
            : constraints.maxWidth >= 700
                ? 3
                : constraints.maxWidth >= 430
                    ? 2
                    : 1;
        final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
        return SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in entries)
                SizedBox(
                  width: width,
                  child: entry.kind == NotePlusEntryKind.note
                      ? _NoteCard(
                          note: entry.note!,
                          onOpen: () => _editNote(entry.note!),
                          onPin: () => ref
                              .read(notePlusRepositoryProvider)
                              .saveNote(
                                entry.note!,
                                pinned: !entry.note!.pinned,
                              ),
                          onArchive: () => ref
                              .read(notePlusRepositoryProvider)
                              .saveNote(
                                entry.note!,
                                archived: !entry.note!.archived,
                              ),
                          onDelete: () => _deleteNote(entry.note!),
                        )
                      : _ListCard(
                          bundle: entry.bundle!,
                          onOpen: () => _openList(entry.bundle!.list.id),
                          onPin: () => ref
                              .read(notePlusRepositoryProvider)
                              .saveList(
                                entry.bundle!.list,
                                pinned: !entry.bundle!.list.pinned,
                              ),
                          onArchive: () => ref
                              .read(notePlusRepositoryProvider)
                              .saveList(
                                entry.bundle!.list,
                                archived: !entry.bundle!.list.archived,
                              ),
                          onDelete: () => _deleteList(entry.bundle!),
                        ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createEntry() async {
    final created = await _createNotePlusEntry(context, ref);
    if (!mounted || created == null) return;
    if (created.kind == _CreatedEntryKind.list) {
      _openList(created.id);
    }
  }

  Future<void> _arrangeEntries(List<NotePlusEntry> entries) => showDialog<void>(
        context: context,
        builder: (_) => _ArrangeEntriesDialog(entries: entries),
      );

  Future<void> _editNote(NoteRecord note) async {
    await showDialog<String>(
      context: context,
      builder: (_) => _NoteEditor(note: note),
    );
  }

  Future<void> _openList(String id) => openFullNoteList(context, id);

  Future<void> _deleteNote(NoteRecord note) async {
    if (!await _confirmDelete(note.title)) return;
    await ref.read(notePlusRepositoryProvider).deleteNote(note.id);
  }

  Future<void> _deleteList(NotePlusListBundle bundle) async {
    if (!await _confirmDelete(bundle.list.name)) return;
    await ref.read(notePlusRepositoryProvider).deleteList(bundle.list.id);
  }

  Future<bool> _confirmDelete(String name) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete permanently?'),
          content: Text('Delete “$name”? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;
}

class NotePlusDashboardCard extends ConsumerStatefulWidget {
  const NotePlusDashboardCard({super.key});

  @override
  ConsumerState<NotePlusDashboardCard> createState() =>
      _NotePlusDashboardCardState();
}

class _NotePlusDashboardCardState extends ConsumerState<NotePlusDashboardCard> {
  _MiniSelection? selection;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(notePlusProvider);
    final snapshot = data.asData?.value;
    final selectedNote = selection?.kind == NotePlusEntryKind.note
        ? snapshot?.notes
            .where((note) => note.id == selection!.id)
            .firstOrNull
        : null;
    final selectedList = selection?.kind == NotePlusEntryKind.list
        ? snapshot?.lists
            .where((bundle) => bundle.list.id == selection!.id)
            .firstOrNull
        : null;
    final hasValidSelection = selectedNote != null || selectedList != null;
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: (MediaQuery.textScalerOf(context).scale(20) + 20)
                .clamp(40, double.infinity),
            child: ColoredBox(
              color: theme.colorScheme.surfaceContainerLow.withValues(
                alpha: .5,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 2),
                child: Row(
                  children: [
                  const Icon(
                    Icons.note_alt_outlined,
                    size: 20,
                    color: _noteAccent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Note+',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Create note or list',
                    onPressed: _createEntry,
                    icon: const Icon(Icons.add, size: 20),
                  ),
                  IconButton(
                    tooltip: hasValidSelection
                        ? 'Open full view'
                        : 'Expand Note+',
                    onPressed: () async {
                      if (selectedList != null) {
                        await openFullNoteList(context, selectedList.list.id);
                        if (mounted) setState(() {});
                      } else {
                        openFullNotePlus(context);
                      }
                    },
                    icon: const Icon(Icons.open_in_full, size: 18),
                  ),
                  ],
                ),
              ),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          Expanded(
            child: data.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(child: Text('Could not load Note+')),
              data: (value) => _buildBody(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(NotePlusSnapshot snapshot) {
    if (selection?.kind == NotePlusEntryKind.note) {
      final note = snapshot.notes
          .where((entry) => entry.id == selection!.id)
          .firstOrNull;
      if (note != null) {
        return _MiniNoteEditor(
          key: ValueKey(note.id),
          note: note,
          onBack: () => setState(() => selection = null),
        );
      }
    }
    if (selection?.kind == NotePlusEntryKind.list) {
      final bundle = snapshot.lists
          .where((entry) => entry.list.id == selection!.id)
          .firstOrNull;
      if (bundle != null) {
        return _MiniListView(
          bundle: bundle,
          onBack: () => setState(() => selection = null),
          onAdd: () => _addListItem(bundle),
          onOpen: (item) => _showListItemDetails(bundle, item),
          onToggleCheckbox: (item, property, value) =>
              _toggleCheckbox(bundle, item, property, value),
        );
      }
    }
    return _MiniOverview(
      entries: snapshot.orderedEntries
          .where((entry) => !entry.archived)
          .toList(),
      onOpen: (entry) => setState(
        () => selection = _MiniSelection(entry.kind, entry.id),
      ),
    );
  }

  Future<void> _createEntry() async {
    final created = await _createNotePlusEntry(context, ref);
    if (!mounted || created == null) return;
    setState(
      () => selection = _MiniSelection(
        created.kind == _CreatedEntryKind.note
            ? NotePlusEntryKind.note
            : NotePlusEntryKind.list,
        created.id,
      ),
    );
  }

  Future<void> _addListItem(NotePlusListBundle bundle) async {
    await showDialog<String>(
      context: context,
      builder: (_) => _ItemEditor(bundle: bundle),
    );
  }

  Future<void> _showListItemDetails(
    NotePlusListBundle bundle,
    NotePlusItem item,
  ) async {
    final action = await showDialog<_ItemDetailsAction>(
      context: context,
      builder: (_) => _ItemDetailsDialog(bundle: bundle, item: item),
    );
    if (!mounted || action == null || action == _ItemDetailsAction.close) {
      return;
    }
    if (action == _ItemDetailsAction.delete) {
      await _deleteListItem(bundle, item);
      return;
    }
    final snapshot = await ref.read(notePlusRepositoryProvider).load();
    if (!mounted) return;
    final freshBundle = snapshot.lists
        .where((candidate) => candidate.list.id == bundle.list.id)
        .firstOrNull;
    final freshItem = freshBundle?.items
        .where((candidate) => candidate.row.id == item.row.id)
        .firstOrNull;
    if (freshBundle == null || freshItem == null) return;
    await showDialog<String>(
      context: context,
      builder: (_) => _ItemEditor(
        bundle: freshBundle,
        item: freshItem,
        onDelete: () => _deleteListItem(freshBundle, freshItem),
      ),
    );
  }

  Future<bool> _deleteListItem(
    NotePlusListBundle bundle,
    NotePlusItem item,
  ) async {
    final primary = bundle.primaryProperty;
    final rawTitle = primary == null
        ? ''
        : displayNoteValue(primary, item.values[primary.id]).trim();
    final title = rawTitle.isEmpty ? 'this item' : '“$rawTitle”';
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete item?'),
            content: Text('Delete $title? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return false;
    await ref
        .read(notePlusRepositoryProvider)
        .deleteItem(bundle.list.id, item.row.id);
    return true;
  }

  Future<void> _toggleCheckbox(
    NotePlusListBundle bundle,
    NotePlusItem item,
    NotePlusProperty property,
    bool value,
  ) async {
    if (value && !_allChecklistTasksComplete(bundle, item.values)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete all checklist tasks first.')),
      );
      return;
    }
    await ref
        .read(notePlusRepositoryProvider)
        .saveItemValues(bundle.list.id, item.row.id, {property.id: value});
  }
}

class _MiniSelection {
  const _MiniSelection(this.kind, this.id);

  final NotePlusEntryKind kind;
  final String id;
}

class _ListViewPreferences {
  String? sortPropertyId;
  bool sortAscending = true;
  final List<_ItemFilter> filters = [];
}

final Map<String, _ListViewPreferences> _listViewPreferences = {};

_ListViewPreferences _viewPreferencesFor(String listId) =>
    _listViewPreferences.putIfAbsent(listId, _ListViewPreferences.new);

class _MiniOverview extends StatelessWidget {
  const _MiniOverview({required this.entries, required this.onOpen});

  final List<NotePlusEntry> entries;
  final ValueChanged<NotePlusEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('Create notes and flexible lists'),
        ),
      );
    }
    return Scrollbar(
      child: ListView.separated(
        primary: false,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 1),
        itemBuilder: (context, index) {
          final entry = entries[index];
          if (entry.kind == NotePlusEntryKind.note) {
            final note = entry.note!;
            return _CompactRow(
              icon: Icons.notes_outlined,
              title: note.title,
              subtitle: note.body.trim().isEmpty
                  ? 'Note'
                  : note.body.trim().replaceAll('\n', ' '),
              pinned: note.pinned,
              onTap: () => onOpen(entry),
            );
          }
          final bundle = entry.bundle!;
          return _CompactRow(
            icon: _iconFor(bundle.list.icon),
            title: bundle.list.name,
            subtitle:
                '${bundle.items.length} items · ${bundle.properties.length} properties',
            pinned: bundle.list.pinned,
            onTap: () => onOpen(entry),
          );
        },
      ),
    );
  }
}

class _CompactRow extends StatelessWidget {
  const _CompactRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.pinned = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool pinned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        dense: true,
        minVerticalPadding: 3,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        leading: Icon(icon, size: 18),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: pinned
            ? const Icon(Icons.push_pin, size: 14)
            : const Icon(Icons.chevron_right, size: 18),
        onTap: onTap,
      );
}

class _MiniNoteEditor extends ConsumerStatefulWidget {
  const _MiniNoteEditor({
    required this.note,
    required this.onBack,
    super.key,
  });

  final NoteRecord note;
  final VoidCallback onBack;

  @override
  ConsumerState<_MiniNoteEditor> createState() => _MiniNoteEditorState();
}

class _MiniNoteEditorState extends ConsumerState<_MiniNoteEditor> {
  late final TextEditingController title =
      TextEditingController(text: widget.note.title);
  late final TextEditingController body =
      TextEditingController(text: widget.note.body);
  bool saving = false;

  @override
  void dispose() {
    title.dispose();
    body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: Padding(
            padding: const EdgeInsets.only(left: 2, right: 10),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back to Note+',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 34,
                    height: 34,
                  ),
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back, size: 19),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: TextField(
                      controller: title,
                      maxLines: 1,
                      textInputAction: TextInputAction.done,
                      textAlignVertical: TextAlignVertical.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Untitled note',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        Expanded(
          child: Scrollbar(
            child: ListView(
              primary: false,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              children: [
                TextField(
                  controller: body,
                  minLines: 8,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Write anything…',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 2, 8, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Edited ${_formatDate(widget.note.updatedAt, includeTime: true)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: saving ? null : _save,
                icon: saving
                    ? const SizedBox.square(
                        dimension: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined, size: 17),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => saving = true);
    final requestedTitle = title.text.trim();
    final resolvedTitle =
        requestedTitle.isEmpty ? 'Untitled note' : requestedTitle;
    await ref.read(notePlusRepositoryProvider).saveNote(
          widget.note,
          title: resolvedTitle,
          body: body.text,
        );
    if (mounted) {
      if (title.text != resolvedTitle) title.text = resolvedTitle;
      setState(() => saving = false);
    }
  }
}

class _MiniListView extends StatefulWidget {
  const _MiniListView({
    required this.bundle,
    required this.onBack,
    required this.onAdd,
    required this.onOpen,
    required this.onToggleCheckbox,
  });

  final NotePlusListBundle bundle;
  final VoidCallback onBack;
  final VoidCallback onAdd;
  final ValueChanged<NotePlusItem> onOpen;
  final void Function(
    NotePlusItem item,
    NotePlusProperty property,
    bool value,
  ) onToggleCheckbox;

  @override
  State<_MiniListView> createState() => _MiniListViewState();
}

class _MiniListViewState extends State<_MiniListView> {
  _ListViewPreferences get preferences =>
      _viewPreferencesFor(widget.bundle.list.id);

  List<NotePlusItem> _visibleItems() {
    final bundle = widget.bundle;
    var items = bundle.items.where((item) {
      return _itemMatchesFilters(bundle, item, preferences.filters);
    }).toList();
    final sortId = preferences.sortPropertyId;
    if (sortId != null) {
      final property = bundle.properties
          .where((candidate) => candidate.id == sortId)
          .firstOrNull;
      if (property != null) {
        items.sort((a, b) => _compareItemsByProperty(
              bundle,
              property,
              a,
              b,
              preferences.sortAscending,
            ));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final bundle = widget.bundle;
    final items = _visibleItems();
    final checkbox = _itemCheckboxProperty(bundle);
    final primary = bundle.primaryProperty;
    final selectedSortProperty = bundle.properties
        .where((property) => property.id == preferences.sortPropertyId)
        .firstOrNull;
    final filtered = preferences.filters.isNotEmpty;

    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.only(left: 2, right: 4),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back to Note+',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 34,
                    height: 34,
                  ),
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back, size: 19),
                ),
                const SizedBox(width: 2),
                Icon(_iconFor(bundle.list.icon), size: 18, color: _noteAccent),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    bundle.list.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Text(
                  filtered
                      ? '${items.length}/${bundle.items.length} items'
                      : '${bundle.items.length} ${bundle.items.length == 1 ? 'item' : 'items'}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(width: 2),
                MenuAnchor(
                  builder: (context, controller, child) => IconButton(
                    tooltip: preferences.sortPropertyId == null
                        ? 'Sort: Manual'
                        : 'Sort: ${selectedSortProperty == null ? '' : _propertyUiName(selectedSortProperty)}',
                    onPressed: () => controller.isOpen
                        ? controller.close()
                        : controller.open(),
                    icon: const Icon(Icons.sort, size: 19),
                  ),
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () => setState(() {
                        preferences.sortPropertyId = null;
                      }),
                      child: const Text('Manual'),
                    ),
                    for (final property in bundle.properties)
                      MenuItemButton(
                        onPressed: () => setState(() {
                          preferences.sortPropertyId = property.id;
                        }),
                        child: Text(_propertyUiName(property)),
                      ),
                    const Divider(),
                    MenuItemButton(
                      onPressed: () => setState(() {
                        preferences.sortAscending = !preferences.sortAscending;
                      }),
                      child: Text(
                        preferences.sortAscending
                            ? 'Ascending ↑'
                            : 'Descending ↓',
                      ),
                    ),
                  ],
                ),
                IconButton(
                  tooltip: filtered
                      ? 'Filter (${preferences.filters.length})'
                      : 'Filter',
                  onPressed: bundle.properties.isEmpty ? null : _manageFilters,
                  color: filtered ? Theme.of(context).colorScheme.primary : null,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.filter_alt_outlined, size: 19),
                      if (filtered)
                        Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '${preferences.filters.length}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary,
                                    fontSize: 9,
                                  ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: widget.onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add item'),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    bundle.items.isEmpty
                        ? 'No items yet'
                        : 'No items match the current filters.',
                  ),
                )
              : Scrollbar(
                  child: ListView.separated(
                    primary: false,
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final rawTitle = primary == null
                          ? ''
                          : displayNoteValue(primary, item.values[primary.id]);
                      final details = bundle.properties.where((property) {
                        if (property.id == primary?.id ||
                            property.type == NotePropertyType.checkbox) {
                          return false;
                        }
                        return _hasVisibleValue(
                          property,
                          item.values[property.id],
                        );
                      }).toList();

                      return InkWell(
                        onTap: () => widget.onOpen(item),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (checkbox != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Checkbox(
                                    visualDensity: VisualDensity.compact,
                                    value: item.values[checkbox.id] == true,
                                    onChanged: (value) => widget.onToggleCheckbox(
                                      item,
                                      checkbox,
                                      value == true,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rawTitle.trim().isEmpty
                                          ? 'Untitled item'
                                          : rawTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    if (details.isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      for (final property in details)
                                        _MiniPropertyValue(
                                          key: ValueKey(
                                            '${item.row.id}:${property.id}',
                                          ),
                                          bundle: bundle,
                                          item: item,
                                          property: property,
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Icon(Icons.chevron_right, size: 18),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _manageFilters() async {
    final next = await showDialog<List<_ItemFilter>>(
      context: context,
      builder: (_) => _MiniFiltersDialog(
        properties: widget.bundle.properties,
        initial: preferences.filters,
      ),
    );
    if (next == null || !mounted) return;
    setState(() {
      preferences.filters
        ..clear()
        ..addAll(next);
    });
  }
}

class _MiniPropertyValue extends ConsumerStatefulWidget {
  const _MiniPropertyValue({
    required this.bundle,
    required this.item,
    required this.property,
    super.key,
  });

  final NotePlusListBundle bundle;
  final NotePlusItem item;
  final NotePlusProperty property;

  @override
  ConsumerState<_MiniPropertyValue> createState() =>
      _MiniPropertyValueState();
}

class _MiniPropertyValueState extends ConsumerState<_MiniPropertyValue> {
  bool checklistExpanded = false;

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final value = widget.item.values[property.id];
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    if (property.type == NotePropertyType.progress) {
      final progress = _progressValueFor(
        widget.bundle,
        property,
        widget.item.values,
      );
      return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(
          children: [
            SizedBox(width: 70, child: Text('${property.name}:', style: style)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text('${progress.round()}%', style: style),
          ],
        ),
      );
    }

    if (property.type == NotePropertyType.checklist) {
      final entries = _checklistEntriesForUi(value)
          .where((entry) => entry['text'].toString().trim().isNotEmpty)
          .toList();
      final done = entries.where((entry) => entry['done'] == true).length;
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: entries.isEmpty
                  ? null
                  : () => setState(
                        () => checklistExpanded = !checklistExpanded,
                      ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${property.name}: $done/${entries.length} done',
                        style: style,
                      ),
                    ),
                    if (entries.isNotEmpty)
                      Icon(
                        checklistExpanded
                            ? Icons.expand_more
                            : Icons.chevron_right,
                        size: 15,
                      ),
                  ],
                ),
              ),
            ),
            if (checklistExpanded)
              for (var index = 0; index < entries.length; index++)
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          visualDensity: VisualDensity.compact,
                          value: entries[index]['done'] == true,
                          onChanged: (checked) =>
                              _toggleChecklist(index, checked == true),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          entries[index]['text'].toString(),
                          style: style,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      );
    }

    final display = displayNoteValue(property, value).trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text('${property.name}: $display', style: style),
    );
  }

  Future<void> _toggleChecklist(int index, bool checked) async {
    final entries = _checklistEntriesForUi(widget.item.values[widget.property.id]);
    if (index < 0 || index >= entries.length) return;
    entries[index]['done'] = checked;
    final updates = _checklistUpdateWithCompletionSync(
      widget.bundle,
      widget.item.values,
      widget.property.id,
      entries,
    );
    await ref.read(notePlusRepositoryProvider).saveItemValues(
          widget.bundle.list.id,
          widget.item.row.id,
          updates,
        );
  }
}

class _ArrangeEntriesDialog extends ConsumerStatefulWidget {
  const _ArrangeEntriesDialog({required this.entries});

  final List<NotePlusEntry> entries;

  @override
  ConsumerState<_ArrangeEntriesDialog> createState() =>
      _ArrangeEntriesDialogState();
}

class _ArrangeEntriesDialogState
    extends ConsumerState<_ArrangeEntriesDialog> {
  late List<NotePlusEntry> pinned = widget.entries
      .where((entry) => entry.pinned)
      .toList();
  late List<NotePlusEntry> others = widget.entries
      .where((entry) => !entry.pinned)
      .toList();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Arrange notes & lists'),
        content: SizedBox(
          width: 520,
          height: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (pinned.isNotEmpty) ...[
                  _sectionTitle(context, 'Pinned'),
                  _reorderableSection(pinned),
                  const SizedBox(height: 12),
                ],
                _sectionTitle(
                  context,
                  pinned.isEmpty ? 'Order' : 'Other notes & lists',
                ),
                _reorderableSection(others),
                if (pinned.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Pinned entries stay above the rest. Drag within each section to choose their order.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
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

  Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      );

  Widget _reorderableSection(List<NotePlusEntry> entries) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Text('Nothing here yet.'),
      );
    }
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: entries.length,
      onReorderItem: (oldIndex, newIndex) async {
        setState(() {
          final moved = entries.removeAt(oldIndex);
          entries.insert(newIndex, moved);
        });
        await ref
            .read(notePlusRepositoryProvider)
            .reorderEntries([...pinned, ...others]);
      },
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          key: ValueKey('${entry.kind.name}:${entry.id}'),
          leading: Icon(
            entry.kind == NotePlusEntryKind.note
                ? Icons.notes_outlined
                : _iconFor(entry.bundle!.list.icon),
            size: 20,
          ),
          title: Text(entry.title),
          subtitle: Text(
            entry.kind == NotePlusEntryKind.note ? 'Note' : 'List',
          ),
          trailing: ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.drag_handle),
            ),
          ),
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onOpen,
    required this.onPin,
    required this.onArchive,
    required this.onDelete,
  });

  final NoteRecord note;
  final VoidCallback onOpen;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.note_alt_outlined,
                      color: _noteAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        note.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.pinned) const Icon(Icons.push_pin, size: 16),
                    _EntryMenu(
                      pinned: note.pinned,
                      archived: note.archived,
                      onPin: onPin,
                      onArchive: onArchive,
                      onDelete: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note.body.trim().isEmpty ? 'Empty note' : note.body.trim(),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.bundle,
    required this.onOpen,
    required this.onPin,
    required this.onArchive,
    required this.onDelete,
  });

  final NotePlusListBundle bundle;
  final VoidCallback onOpen;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _iconFor(bundle.list.icon),
                      color: _noteAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        bundle.list.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (bundle.list.pinned)
                      const Icon(Icons.push_pin, size: 16),
                    _EntryMenu(
                      pinned: bundle.list.pinned,
                      archived: bundle.list.archived,
                      onPin: onPin,
                      onArchive: onArchive,
                      onDelete: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${bundle.items.length} items · ${bundle.properties.length} properties',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  bundle.properties
                      .map((property) => property.name)
                      .take(4)
                      .join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
}

class _EntryMenu extends StatelessWidget {
  const _EntryMenu({
    required this.pinned,
    required this.archived,
    required this.onPin,
    required this.onArchive,
    required this.onDelete,
  });

  final bool pinned;
  final bool archived;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
        tooltip: 'More',
        onSelected: (value) {
          if (value == 'pin') onPin();
          if (value == 'archive') onArchive();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'pin',
            child: Text(pinned ? 'Unpin' : 'Pin'),
          ),
          PopupMenuItem(
            value: 'archive',
            child: Text(archived ? 'Restore' : 'Archive'),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      );
}

class _NoteEditor extends ConsumerStatefulWidget {
  const _NoteEditor({this.note});
  final NoteRecord? note;

  @override
  ConsumerState<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<_NoteEditor> {
  late final TextEditingController title =
      TextEditingController(text: widget.note?.title ?? '');
  late final TextEditingController body =
      TextEditingController(text: widget.note?.body ?? '');
  bool saving = false;

  @override
  void dispose() {
    title.dispose();
    body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 700),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  const Icon(Icons.note_alt_outlined, color: _noteAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.note == null ? 'New note' : 'Edit note',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ]),
                const SizedBox(height: 8),
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Untitled note',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TextField(
                    controller: body,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: 'Write anything…',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 6),
                  FilledButton(
                    onPressed: saving ? null : _save,
                    child: saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ]),
              ],
            ),
          ),
        ),
      );

  Future<void> _save() async {
    setState(() => saving = true);
    final repo = ref.read(notePlusRepositoryProvider);
    final requestedTitle = title.text.trim();
    final resolvedTitle =
        requestedTitle.isEmpty ? 'Untitled note' : requestedTitle;
    final String id;
    if (widget.note == null) {
      id = await repo.createNote(title: resolvedTitle, body: body.text);
    } else {
      await repo.saveNote(
        widget.note!,
        title: resolvedTitle,
        body: body.text,
      );
      id = widget.note!.id;
    }
    if (mounted) Navigator.pop(context, id);
  }
}

enum _FilterOperator {
  contains,
  equals,
  startsWith,
  isEmpty,
  checked,
  unchecked,
  greaterThan,
  greaterOrEqual,
  lessThan,
  lessOrEqual,
  isOption,
  isNotOption,
  before,
  after,
  onDate,
  allDone,
  hasIncomplete,
  containsTask,
  multiContains,
  multiNotContains,
}

String _filterOperatorLabel(_FilterOperator value) => switch (value) {
      _FilterOperator.contains => 'Contains',
      _FilterOperator.equals => 'Equals',
      _FilterOperator.startsWith => 'Starts with',
      _FilterOperator.isEmpty => 'Is empty',
      _FilterOperator.checked => 'Checked',
      _FilterOperator.unchecked => 'Unchecked',
      _FilterOperator.greaterThan => '>',
      _FilterOperator.greaterOrEqual => '≥',
      _FilterOperator.lessThan => '<',
      _FilterOperator.lessOrEqual => '≤',
      _FilterOperator.isOption => 'Is',
      _FilterOperator.isNotOption => 'Is not',
      _FilterOperator.before => 'Before',
      _FilterOperator.after => 'After',
      _FilterOperator.onDate => 'On',
      _FilterOperator.allDone => 'All done',
      _FilterOperator.hasIncomplete => 'Has incomplete',
      _FilterOperator.containsTask => 'Contains task',
      _FilterOperator.multiContains => 'Contains',
      _FilterOperator.multiNotContains => 'Does not contain',
    };

List<_FilterOperator> _operatorsFor(NotePropertyType type) => switch (type) {
      NotePropertyType.checkbox => const [
          _FilterOperator.checked,
          _FilterOperator.unchecked,
        ],
      NotePropertyType.checklist => const [
          _FilterOperator.allDone,
          _FilterOperator.hasIncomplete,
          _FilterOperator.containsTask,
        ],
      NotePropertyType.number ||
      NotePropertyType.currency ||
      NotePropertyType.rating ||
      NotePropertyType.progress => const [
          _FilterOperator.equals,
          _FilterOperator.greaterThan,
          _FilterOperator.greaterOrEqual,
          _FilterOperator.lessThan,
          _FilterOperator.lessOrEqual,
        ],
      NotePropertyType.select || NotePropertyType.status => const [
          _FilterOperator.isOption,
          _FilterOperator.isNotOption,
        ],
      NotePropertyType.multiSelect => const [
          _FilterOperator.multiContains,
          _FilterOperator.multiNotContains,
        ],
      NotePropertyType.date || NotePropertyType.dateTime => const [
          _FilterOperator.onDate,
          _FilterOperator.before,
          _FilterOperator.after,
        ],
      _ => const [
          _FilterOperator.contains,
          _FilterOperator.equals,
          _FilterOperator.startsWith,
          _FilterOperator.isEmpty,
        ],
    };

bool _filterNeedsValue(_FilterOperator operator) => !const {
      _FilterOperator.isEmpty,
      _FilterOperator.checked,
      _FilterOperator.unchecked,
      _FilterOperator.allDone,
      _FilterOperator.hasIncomplete,
    }.contains(operator);

class _ItemFilter {
  const _ItemFilter({
    required this.propertyId,
    required this.operator,
    this.value = '',
  });

  final String propertyId;
  final _FilterOperator operator;
  final String value;

  bool matches(NotePlusProperty property, Object? rawValue) {
    final text = rawValue?.toString().trim() ?? '';
    final query = value.trim();
    switch (operator) {
      case _FilterOperator.contains:
        return text.toLowerCase().contains(query.toLowerCase());
      case _FilterOperator.equals:
        final leftNumber = noteNumericValue(rawValue) ??
            (property.type == NotePropertyType.progress ? 0 : null);
        final rightNumber = double.tryParse(query);
        if (leftNumber != null && rightNumber != null) {
          return leftNumber == rightNumber;
        }
        return text.toLowerCase() == query.toLowerCase();
      case _FilterOperator.startsWith:
        return text.toLowerCase().startsWith(query.toLowerCase());
      case _FilterOperator.isEmpty:
        return rawValue == null || text.isEmpty;
      case _FilterOperator.checked:
        return rawValue == true;
      case _FilterOperator.unchecked:
        return rawValue != true;
      case _FilterOperator.greaterThan:
      case _FilterOperator.greaterOrEqual:
      case _FilterOperator.lessThan:
      case _FilterOperator.lessOrEqual:
        final left = noteNumericValue(rawValue) ??
            (property.type == NotePropertyType.progress ? 0 : null);
        final right = double.tryParse(query);
        if (left == null || right == null) return false;
        return switch (operator) {
          _FilterOperator.greaterThan => left > right,
          _FilterOperator.greaterOrEqual => left >= right,
          _FilterOperator.lessThan => left < right,
          _ => left <= right,
        };
      case _FilterOperator.isOption:
        return text == query;
      case _FilterOperator.isNotOption:
        return text != query;
      case _FilterOperator.multiContains:
      case _FilterOperator.multiNotContains:
        final selected = rawValue is List
            ? rawValue.map((entry) => entry.toString()).toSet()
            : <String>{};
        final contains = selected.contains(query);
        return operator == _FilterOperator.multiContains ? contains : !contains;
      case _FilterOperator.before:
      case _FilterOperator.after:
      case _FilterOperator.onDate:
        final itemDate = DateTime.tryParse(text);
        final filterDate = DateTime.tryParse(query);
        if (itemDate == null || filterDate == null) return false;
        final itemOnly = DateTime(itemDate.year, itemDate.month, itemDate.day);
        final filterOnly =
            DateTime(filterDate.year, filterDate.month, filterDate.day);
        return switch (operator) {
          _FilterOperator.before => itemOnly.isBefore(filterOnly),
          _FilterOperator.after => itemOnly.isAfter(filterOnly),
          _ => itemOnly == filterOnly,
        };
      case _FilterOperator.allDone:
        final entries = _checklistEntriesForUi(rawValue);
        return entries.isNotEmpty &&
            entries.every((entry) => entry['done'] == true);
      case _FilterOperator.hasIncomplete:
        return _checklistEntriesForUi(rawValue)
            .any((entry) => entry['done'] != true);
      case _FilterOperator.containsTask:
        return _checklistEntriesForUi(rawValue).any(
          (entry) => entry['text']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()),
        );
    }
  }

  String describe(NotePlusProperty property) {
    final name = _propertyUiName(property);
    final label = _filterOperatorLabel(operator);
    if (!_filterNeedsValue(operator)) return '$name: $label';
    final parsedDate = (operator == _FilterOperator.before ||
            operator == _FilterOperator.after ||
            operator == _FilterOperator.onDate)
        ? DateTime.tryParse(value)
        : null;
    final displayValue = parsedDate == null ? value : _formatDate(parsedDate);
    return '$name $label $displayValue';
  }
}

class _FilterBuilderDialog extends StatefulWidget {
  const _FilterBuilderDialog({required this.properties});
  final List<NotePlusProperty> properties;

  @override
  State<_FilterBuilderDialog> createState() => _FilterBuilderDialogState();
}

class _FilterBuilderDialogState extends State<_FilterBuilderDialog> {
  late NotePlusProperty property = widget.properties.first;
  late _FilterOperator operator = _operatorsFor(property.type).first;
  final value = TextEditingController();
  DateTime? dateValue;
  String? errorText;

  @override
  void dispose() {
    value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final operators = _operatorsFor(property.type);
    return AlertDialog(
      title: const Text('Add filter'),
      content: SizedBox(
        width: 430,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: property.id,
              decoration: const InputDecoration(
                labelText: 'Property',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final candidate in widget.properties)
                  DropdownMenuItem(
                    value: candidate.id,
                    child: Text(_propertyUiName(candidate)),
                  ),
              ],
              onChanged: (id) {
                final next = widget.properties
                    .firstWhere((candidate) => candidate.id == id);
                setState(() {
                  property = next;
                  operator = _operatorsFor(next.type).first;
                  value.clear();
                  dateValue = null;
                  errorText = null;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<_FilterOperator>(
              key: ValueKey('filter-operator-${property.id}'),
              initialValue: operator,
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final candidate in operators)
                  DropdownMenuItem(
                    value: candidate,
                    child: Text(_filterOperatorLabel(candidate)),
                  ),
              ],
              onChanged: (next) => setState(() {
                operator = next ?? operators.first;
                value.clear();
                dateValue = null;
                errorText = null;
              }),
            ),
            if (_filterNeedsValue(operator)) ...[
              const SizedBox(height: 10),
              _valueEditor(),
              if (errorText != null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    errorText!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _apply, child: const Text('Apply')),
      ],
    );
  }

  Widget _valueEditor() {
    if (property.type == NotePropertyType.select ||
        property.type == NotePropertyType.status ||
        property.type == NotePropertyType.multiSelect) {
      final options = property.options;
      if (options.isNotEmpty) {
        return DropdownButtonFormField<String>(
          key: ValueKey('filter-value-${property.id}'),
          initialValue: options.contains(value.text) ? value.text : null,
          decoration: const InputDecoration(
            labelText: 'Value',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final option in options)
              DropdownMenuItem(value: option, child: Text(option)),
          ],
          onChanged: (next) => setState(() {
            value.text = next ?? '';
            errorText = null;
          }),
        );
      }
    }
    if (property.type == NotePropertyType.date ||
        property.type == NotePropertyType.dateTime) {
      return OutlinedButton.icon(
        onPressed: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(now.year - 20),
            lastDate: DateTime(now.year + 30),
            initialDate: dateValue ?? now,
          );
          if (picked == null) return;
          setState(() {
            dateValue = picked;
            value.text = picked.toIso8601String();
            errorText = null;
          });
        },
        icon: const Icon(Icons.calendar_today_outlined),
        label: Text(
          dateValue == null ? 'Choose date' : _formatDate(dateValue!),
        ),
      );
    }
    final numeric = property.type == NotePropertyType.number ||
        property.type == NotePropertyType.currency ||
        property.type == NotePropertyType.rating ||
        property.type == NotePropertyType.progress;
    return TextField(
      controller: value,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: operator == _FilterOperator.containsTask ? 'Task text' : 'Value',
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) {
        if (errorText != null) setState(() => errorText = null);
      },
    );
  }

  void _apply() {
    if (_filterNeedsValue(operator) && value.text.trim().isEmpty) {
      setState(() => errorText = 'Choose or enter a value.');
      return;
    }
    Navigator.pop(
      context,
      _ItemFilter(
        propertyId: property.id,
        operator: operator,
        value: value.text.trim(),
      ),
    );
  }
}

class _MiniFiltersDialog extends StatefulWidget {
  const _MiniFiltersDialog({required this.properties, required this.initial});

  final List<NotePlusProperty> properties;
  final List<_ItemFilter> initial;

  @override
  State<_MiniFiltersDialog> createState() => _MiniFiltersDialogState();
}

class _MiniFiltersDialogState extends State<_MiniFiltersDialog> {
  late final List<_ItemFilter> filters = [...widget.initial];

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Filters'),
        content: SizedBox(
          width: 440,
          child: filters.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No filters applied.')),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: filters.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final filter = filters[index];
                    final property = widget.properties
                        .where((candidate) => candidate.id == filter.propertyId)
                        .firstOrNull;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        property == null
                            ? 'Unavailable property'
                            : filter.describe(property),
                      ),
                      trailing: IconButton(
                        tooltip: 'Remove filter',
                        onPressed: () => setState(() => filters.removeAt(index)),
                        icon: const Icon(Icons.close),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          if (filters.isNotEmpty)
            TextButton(
              onPressed: () => setState(filters.clear),
              child: const Text('Clear all'),
            ),
          TextButton.icon(
            onPressed: _addFilter,
            icon: const Icon(Icons.add),
            label: const Text('Add filter'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, [...filters]),
            child: const Text('Done'),
          ),
        ],
      );

  Future<void> _addFilter() async {
    final filter = await showDialog<_ItemFilter>(
      context: context,
      builder: (_) => _FilterBuilderDialog(properties: widget.properties),
    );
    if (filter != null && mounted) setState(() => filters.add(filter));
  }
}

bool _itemMatchesFilters(
  NotePlusListBundle bundle,
  NotePlusItem item,
  List<_ItemFilter> filters,
) {
  for (final filter in filters) {
    final property = bundle.properties
        .where((candidate) => candidate.id == filter.propertyId)
        .firstOrNull;
    if (property == null) return false;
    final value = property.type == NotePropertyType.progress
        ? _progressValueFor(bundle, property, item.values)
        : item.values[property.id];
    if (!filter.matches(property, value)) return false;
  }
  return true;
}

int _compareItemsByProperty(
  NotePlusListBundle bundle,
  NotePlusProperty property,
  NotePlusItem a,
  NotePlusItem b,
  bool ascending,
) {
  final av = property.type == NotePropertyType.progress
      ? _progressValueFor(bundle, property, a.values)
      : a.values[property.id];
  final bv = property.type == NotePropertyType.progress
      ? _progressValueFor(bundle, property, b.values)
      : b.values[property.id];
  final an = noteNumericValue(av) ??
      (property.type == NotePropertyType.progress ? 0 : null);
  final bn = noteNumericValue(bv) ??
      (property.type == NotePropertyType.progress ? 0 : null);
  final result = an != null && bn != null
      ? an.compareTo(bn)
      : (av?.toString() ?? '')
          .toLowerCase()
          .compareTo((bv?.toString() ?? '').toLowerCase());
  return ascending ? result : -result;
}

class NoteListPage extends ConsumerStatefulWidget {
  const NoteListPage({required this.listId, super.key});
  final String listId;
  @override
  ConsumerState<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends ConsumerState<NoteListPage> {
  final search = TextEditingController();

  _ListViewPreferences get preferences => _viewPreferencesFor(widget.listId);
  String? get sortPropertyId => preferences.sortPropertyId;
  set sortPropertyId(String? value) => preferences.sortPropertyId = value;
  bool get sortAscending => preferences.sortAscending;
  set sortAscending(bool value) => preferences.sortAscending = value;
  List<_ItemFilter> get filters => preferences.filters;

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(notePlusProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Note+')),
      body: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load list: $e')),
        data: (data) {
          final bundle = data.lists.where((b) => b.list.id == widget.listId).firstOrNull;
          if (bundle == null) return const Center(child: Text('This list no longer exists.'));
          return _buildList(bundle);
        },
      ),
    );
  }

  Widget _buildList(NotePlusListBundle bundle) {
    var items = [...bundle.items];
    items = items.where((item) {
      final q = search.text.trim().toLowerCase();
      if (q.isNotEmpty &&
          !item.values.values.any(
            (v) => v?.toString().toLowerCase().contains(q) ?? false,
          )) {
        return false;
      }
      return _itemMatchesFilters(bundle, item, filters);
    }).toList();

    if (sortPropertyId != null) {
      final property = bundle.properties
          .where((candidate) => candidate.id == sortPropertyId)
          .firstOrNull;
      if (property != null) {
        items.sort((a, b) => _compareItemsByProperty(
              bundle,
              property,
              a,
              b,
              sortAscending,
            ));
      }
    }

    final selectedSortProperty = bundle.properties
        .where((property) => property.id == sortPropertyId)
        .firstOrNull;
    final canReorder = sortPropertyId == null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Icon(_iconFor(bundle.list.icon), color: _noteAccent, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                bundle.list.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _manageProperties(bundle),
              icon: const Icon(Icons.tune),
              label: const Text('List settings'),
            ),
            const SizedBox(width: 6),
            FilledButton.icon(
              onPressed: () => _addItem(bundle),
              icon: const Icon(Icons.add),
              label: const Text('Add item'),
            ),
          ]),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 260,
                child: TextField(
                  controller: search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search items',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              MenuAnchor(
                builder: (context, controller, child) => OutlinedButton.icon(
                  onPressed: () =>
                      controller.isOpen ? controller.close() : controller.open(),
                  icon: const Icon(Icons.sort),
                  label: Text(
                    sortPropertyId == null
                        ? 'Sort: Manual'
                        : 'Sort: ${selectedSortProperty == null ? '' : _propertyUiName(selectedSortProperty)}',
                  ),
                ),
                menuChildren: [
                  MenuItemButton(
                    onPressed: () => setState(() => sortPropertyId = null),
                    child: const Text('Manual'),
                  ),
                  for (final property in bundle.properties)
                    MenuItemButton(
                      onPressed: () =>
                          setState(() => sortPropertyId = property.id),
                      child: Text(_propertyUiName(property)),
                    ),
                  const Divider(),
                  MenuItemButton(
                    onPressed: () =>
                        setState(() => sortAscending = !sortAscending),
                    child: Text(
                      sortAscending ? 'Ascending ↑' : 'Descending ↓',
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: bundle.properties.isEmpty
                    ? null
                    : () => _addFilter(bundle),
                icon: const Icon(Icons.filter_alt_outlined),
                label: Text(
                  filters.isEmpty ? 'Filter' : 'Filter (${filters.length})',
                ),
              ),
              if (MediaQuery.sizeOf(context).width < 700 &&
                  bundle.items.length > 1)
                OutlinedButton.icon(
                  onPressed: canReorder ? () => _rearrangeItems(bundle) : null,
                  icon: const Icon(Icons.swap_vert_rounded),
                  label: const Text('Rearrange'),
                ),
              for (var index = 0; index < filters.length; index++)
                InputChip(
                  label: Text(
                    filters[index].describe(
                      bundle.properties.firstWhere(
                        (property) => property.id == filters[index].propertyId,
                      ),
                    ),
                  ),
                  onDeleted: () => setState(() => filters.removeAt(index)),
                ),
              if (filters.length > 1)
                TextButton(
                  onPressed: () => setState(filters.clear),
                  child: const Text('Clear filters'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      bundle.items.isEmpty
                          ? 'No items yet. Add your first item.'
                          : 'No items match the current search or filters.',
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 700) {
                        return _DesktopListTable(
                          bundle: bundle,
                          items: items,
                          onRearrange: canReorder && bundle.items.length > 1
                              ? () => _rearrangeItems(bundle)
                              : null,
                          onOpen: (item) => _showItemDetails(bundle, item),
                        );
                      }
                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (_, index) => _MobileItemCard(
                          bundle: bundle,
                          item: items[index],
                          onOpen: () =>
                              _showItemDetails(bundle, items[index]),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _addFilter(NotePlusListBundle bundle) async {
    final filter = await showDialog<_ItemFilter>(
      context: context,
      builder: (_) => _FilterBuilderDialog(properties: bundle.properties),
    );
    if (filter != null && mounted) setState(() => filters.add(filter));
  }

  Future<void> _rearrangeItems(NotePlusListBundle bundle) async {
    final reordered = await showDialog<List<NotePlusItem>>(
      context: context,
      builder: (_) => _RearrangeItemsDialog(bundle: bundle),
    );
    if (reordered == null || !mounted) return;
    await ref
        .read(notePlusRepositoryProvider)
        .reorderItems(bundle.list.id, reordered);
  }

  Future<void> _manageProperties(NotePlusListBundle bundle) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _PropertiesDialog(bundle: bundle),
    );
    if (mounted) {
      setState(() {
        filters.clear();
        sortPropertyId = null;
      });
    }
  }

  Future<void> _addItem(NotePlusListBundle bundle) async {
    await showDialog<String>(
      context: context,
      builder: (_) => _ItemEditor(bundle: bundle),
    );
  }

  Future<void> _editItem(NotePlusListBundle bundle, NotePlusItem item) async {
    await showDialog<String>(
      context: context,
      builder: (_) => _ItemEditor(bundle: bundle, item: item),
    );
  }

  Future<void> _showItemDetails(
    NotePlusListBundle bundle,
    NotePlusItem item,
  ) async {
    final action = await showDialog<_ItemDetailsAction>(
      context: context,
      builder: (_) => _ItemDetailsDialog(bundle: bundle, item: item),
    );
    if (!mounted || action == null || action == _ItemDetailsAction.close) {
      return;
    }
    if (action == _ItemDetailsAction.delete) {
      await _deleteItem(bundle, item);
      return;
    }
    final snapshot = await ref.read(notePlusRepositoryProvider).load();
    if (!mounted) return;
    final freshBundle = snapshot.lists
        .where((candidate) => candidate.list.id == bundle.list.id)
        .firstOrNull;
    final freshItem = freshBundle?.items
        .where((candidate) => candidate.row.id == item.row.id)
        .firstOrNull;
    if (freshBundle != null && freshItem != null) {
      await _editItem(freshBundle, freshItem);
    }
  }

  Future<void> _deleteItem(NotePlusListBundle bundle, NotePlusItem item) async {
    final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Delete item?'),
      content: const Text('This item will be permanently deleted.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))],
    )) ?? false;
    if (ok) await ref.read(notePlusRepositoryProvider).deleteItem(bundle.list.id, item.row.id);
  }
}

List<Map<String, Object>> _checklistEntriesForUi(Object? value) {
  if (value is! List) return <Map<String, Object>>[];
  return value.whereType<Map>().map((entry) {
    return <String, Object>{
      'text': entry['text']?.toString() ?? '',
      'done': entry['done'] == true,
    };
  }).toList();
}

NotePlusProperty? _itemCheckboxProperty(NotePlusListBundle bundle) => bundle
    .properties
    .where((property) => property.type == NotePropertyType.checkbox)
    .firstOrNull;

bool _allChecklistTasksComplete(
  NotePlusListBundle bundle,
  Map<String, Object?> values,
) {
  final checklists = bundle.properties
      .where((property) => property.type == NotePropertyType.checklist)
      .toList();
  if (checklists.isEmpty) return true;
  for (final property in checklists) {
    final entries = _checklistEntriesForUi(values[property.id])
        .where((entry) => entry['text'].toString().trim().isNotEmpty);
    if (entries.any((entry) => entry['done'] != true)) return false;
  }
  return true;
}

Map<String, Object?> _checklistUpdateWithCompletionSync(
  NotePlusListBundle bundle,
  Map<String, Object?> currentValues,
  String checklistPropertyId,
  List<Map<String, Object>> checklistValue,
) {
  final updates = <String, Object?>{checklistPropertyId: checklistValue};
  final merged = <String, Object?>{
    ...currentValues,
    checklistPropertyId: checklistValue,
  };
  final checkbox = _itemCheckboxProperty(bundle);
  if (checkbox != null &&
      merged[checkbox.id] == true &&
      !_allChecklistTasksComplete(bundle, merged)) {
    updates[checkbox.id] = false;
  }
  return updates;
}

double _checklistProgressForUi(Object? value) {
  final entries = _checklistEntriesForUi(value)
      .where((entry) => entry['text'].toString().trim().isNotEmpty)
      .toList();
  if (entries.isEmpty) return 0;
  final done = entries.where((entry) => entry['done'] == true).length;
  return done / entries.length * 100;
}

NotePlusProperty? _linkedChecklistProperty(
  NotePlusListBundle bundle,
  NotePlusProperty progress,
) {
  final linkedId = progress.linkedChecklistId;
  if (linkedId == null) return null;
  return bundle.properties
      .where(
        (property) =>
            property.id == linkedId &&
            property.type == NotePropertyType.checklist,
      )
      .firstOrNull;
}

double _progressValueFor(
  NotePlusListBundle bundle,
  NotePlusProperty progress,
  Map<String, Object?> values,
) {
  final checklist = _linkedChecklistProperty(bundle, progress);
  if (checklist != null) {
    return _checklistProgressForUi(values[checklist.id]);
  }
  return noteNumericValue(values[progress.id])?.clamp(0, 100).toDouble() ?? 0;
}

bool _hasVisibleValue(NotePlusProperty property, Object? value) {
  if (property.type == NotePropertyType.progress) return true;
  if (value == null) return false;
  if (property.type == NotePropertyType.checklist) {
    return _checklistEntriesForUi(value).any(
      (entry) => entry['text'].toString().trim().isNotEmpty,
    );
  }
  if (property.type == NotePropertyType.multiSelect) {
    return value is List && value.isNotEmpty;
  }
  return displayNoteValue(property, value).trim().isNotEmpty;
}

String _propertyUiName(NotePlusProperty property) =>
    property.type == NotePropertyType.checkbox ? 'Checked' : property.name;

class _DesktopListTable extends ConsumerStatefulWidget {
  const _DesktopListTable({
    required this.bundle,
    required this.items,
    required this.onOpen,
    required this.onRearrange,
  });

  final NotePlusListBundle bundle;
  final List<NotePlusItem> items;
  final ValueChanged<NotePlusItem> onOpen;
  final VoidCallback? onRearrange;

  @override
  ConsumerState<_DesktopListTable> createState() => _DesktopListTableState();
}

class _DesktopListTableState extends ConsumerState<_DesktopListTable> {
  final Set<String> expandedChecklists = {};

  double _columnWidth(NotePlusProperty property) {
    if (property.isPrimary) return 230;
    return switch (property.type) {
      NotePropertyType.checklist => 250,
      NotePropertyType.longText => 220,
      NotePropertyType.multiSelect => 190,
      NotePropertyType.progress => 190,
      _ => 160,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bundle = widget.bundle;
    final checkbox = _itemCheckboxProperty(bundle);
    final properties = bundle.properties
        .where((property) => property.type != NotePropertyType.checkbox)
        .toList();
    final requestedWidth = properties.fold<double>(56, (width, property) {
      return width + _columnWidth(property);
    });
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tableWidth = requestedWidth > constraints.maxWidth
              ? requestedWidth
              : constraints.maxWidth;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: SingleChildScrollView(
                child: Table(
                  columnWidths: {
                    for (var i = 0; i < properties.length; i++)
                      i: FixedColumnWidth(_columnWidth(properties[i])),
                    properties.length: const FixedColumnWidth(56),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder(
                    horizontalInside: BorderSide(color: outline),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLow,
                      ),
                      children: [
                        for (final property in properties)
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              property.name,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        Center(
                          child: IconButton(
                            tooltip: widget.onRearrange == null
                                ? 'Switch Sort to Manual to rearrange items'
                                : 'Rearrange items',
                            onPressed: widget.onRearrange,
                            icon: const Icon(Icons.swap_vert_rounded),
                          ),
                        ),
                      ],
                    ),
                    for (final item in widget.items)
                      TableRow(
                        children: [
                          for (final property in properties)
                            property.isPrimary
                                ? _primaryCell(
                                    context,
                                    item,
                                    property,
                                    checkbox,
                                  )
                                : _propertyCell(
                                    context,
                                    item,
                                    property,
                                  ),
                          IconButton(
                            tooltip: 'View item details',
                            onPressed: () => widget.onOpen(item),
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _primaryCell(
    BuildContext context,
    NotePlusItem item,
    NotePlusProperty primary,
    NotePlusProperty? checkbox,
  ) {
    final display = displayNoteValue(primary, item.values[primary.id]);
    return Row(
      children: [
        if (checkbox != null)
          Checkbox(
            value: item.values[checkbox.id] == true,
            onChanged: (checked) async {
              if (checked == null) return;
              if (checked &&
                  !_allChecklistTasksComplete(widget.bundle, item.values)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complete all checklist tasks first.'),
                  ),
                );
                return;
              }
              await ref.read(notePlusRepositoryProvider).saveItemValues(
                widget.bundle.list.id,
                item.row.id,
                {checkbox.id: checked},
              );
            },
          ),
        Expanded(
          child: InkWell(
            onTap: () => widget.onOpen(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Text(
                display.trim().isEmpty ? 'Untitled item' : display,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _propertyCell(
    BuildContext context,
    NotePlusItem item,
    NotePlusProperty property,
  ) {
    final value = item.values[property.id];
    if (property.type == NotePropertyType.checklist) {
      final entries = _checklistEntriesForUi(value)
          .where((entry) => entry['text'].toString().trim().isNotEmpty)
          .toList();
      if (entries.isEmpty) {
        return InkWell(
          onTap: () => widget.onOpen(item),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Text('—'),
          ),
        );
      }
      final key = '${item.row.id}:${property.id}';
      final expanded = expandedChecklists.contains(key);
      final done = entries.where((entry) => entry['done'] == true).length;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() {
                expanded
                    ? expandedChecklists.remove(key)
                    : expandedChecklists.add(key);
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text('$done/${entries.length} done')),
                    Icon(
                      expanded ? Icons.expand_more : Icons.chevron_right,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              for (var index = 0; index < entries.length; index++)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      visualDensity: VisualDensity.compact,
                      value: entries[index]['done'] == true,
                      onChanged: (checked) async {
                        if (checked == null) return;
                        final updated = [
                          for (final entry in entries)
                            Map<String, Object>.from(entry),
                        ];
                        updated[index]['done'] = checked;
                        final updates = _checklistUpdateWithCompletionSync(
                          widget.bundle,
                          item.values,
                          property.id,
                          updated,
                        );
                        await ref
                            .read(notePlusRepositoryProvider)
                            .saveItemValues(
                              widget.bundle.list.id,
                              item.row.id,
                              updates,
                            );
                      },
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => widget.onOpen(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            entries[index]['text'].toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          ],
        ),
      );
    }

    if (property.type == NotePropertyType.progress) {
      final progress = _progressValueFor(widget.bundle, property, item.values);
      return InkWell(
        onTap: () => widget.onOpen(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${progress.round()}%'),
            ],
          ),
        ),
      );
    }

    final display = displayNoteValue(property, value);
    return InkWell(
      onTap: () => widget.onOpen(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
          display.isEmpty ? '—' : display,
          maxLines: property.type == NotePropertyType.longText ? 3 : 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _MobileItemCard extends ConsumerWidget {
  const _MobileItemCard({
    required this.bundle,
    required this.item,
    required this.onOpen,
  });

  final NotePlusListBundle bundle;
  final NotePlusItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = bundle.primaryProperty;
    final checkbox = _itemCheckboxProperty(bundle);
    final title = primary == null
        ? 'Item'
        : displayNoteValue(primary, item.values[primary.id]);
    final details = bundle.properties.where((property) {
      if (property.id == primary?.id ||
          property.type == NotePropertyType.checkbox) {
        return false;
      }
      return _hasVisibleValue(property, item.values[property.id]);
    }).toList();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (checkbox != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Checkbox(
                    visualDensity: VisualDensity.compact,
                    value: item.values[checkbox.id] == true,
                    onChanged: (checked) async {
                      if (checked == null) return;
                      if (checked &&
                          !_allChecklistTasksComplete(bundle, item.values)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Complete all checklist tasks first.',
                            ),
                          ),
                        );
                        return;
                      }
                      await ref
                          .read(notePlusRepositoryProvider)
                          .saveItemValues(
                            bundle.list.id,
                            item.row.id,
                            {checkbox.id: checked},
                          );
                    },
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.trim().isEmpty ? 'Untitled item' : title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      for (final property in details)
                        _MiniPropertyValue(
                          key: ValueKey('${item.row.id}:${property.id}:mobile'),
                          bundle: bundle,
                          item: item,
                          property: property,
                        ),
                    ],
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RearrangeItemsDialog extends StatefulWidget {
  const _RearrangeItemsDialog({required this.bundle});

  final NotePlusListBundle bundle;

  @override
  State<_RearrangeItemsDialog> createState() => _RearrangeItemsDialogState();
}

class _RearrangeItemsDialogState extends State<_RearrangeItemsDialog> {
  late final List<NotePlusItem> items = [...widget.bundle.items];

  String _title(NotePlusItem item) {
    final primary = widget.bundle.primaryProperty;
    if (primary == null) return 'Untitled item';
    final value = displayNoteValue(primary, item.values[primary.id]).trim();
    return value.isEmpty ? 'Untitled item' : value;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Rearrange items'),
        content: SizedBox(
          width: 440,
          height: 420,
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            itemCount: items.length,
            onReorderItem: (oldIndex, newIndex) {
              setState(() {
                final moved = items.removeAt(oldIndex);
                items.insert(newIndex, moved);
              });
            },
            itemBuilder: (context, index) => ListTile(
              key: ValueKey(items[index].row.id),
              leading: ReorderableDragStartListener(
                index: index,
                child: const MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: Icon(Icons.drag_handle),
                ),
              ),
              title: Text(
                _title(items[index]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, [...items]),
            child: const Text('Done'),
          ),
        ],
      );
}

class _PropertiesDialog extends ConsumerStatefulWidget {
  const _PropertiesDialog({required this.bundle});
  final NotePlusListBundle bundle;
  @override
  ConsumerState<_PropertiesDialog> createState() => _PropertiesDialogState();
}

class _PropertiesDialogState extends ConsumerState<_PropertiesDialog> {
  late List<NotePlusProperty> properties = [...widget.bundle.properties];
  late final TextEditingController listName =
      TextEditingController(text: widget.bundle.list.name);
  late String icon = widget.bundle.list.icon;
  bool savingList = false;

  @override
  void dispose() {
    listName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('List settings'),
        content: SizedBox(
          width: 580,
          height: 540,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: listName,
                decoration: const InputDecoration(
                  labelText: 'List name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickIcon,
                icon: Icon(_iconFor(icon), color: _noteAccent),
                label: Text('Change icon · ${_iconLabel(icon)}'),
              ),
              const SizedBox(height: 14),
              Text(
                'Properties',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: properties.length,
                  onReorderItem: (oldIndex, newIndex) async {
                    if (oldIndex == 0) return;
                    if (newIndex == 0) newIndex = 1;
                    setState(() {
                      final moved = properties.removeAt(oldIndex);
                      properties.insert(newIndex, moved);
                    });
                    await ref
                        .read(notePlusRepositoryProvider)
                        .reorderProperties(widget.bundle.list.id, properties);
                  },
                  itemBuilder: (context, index) {
                    final property = properties[index];
                    final checkbox =
                        property.type == NotePropertyType.checkbox;
                    final linkedChecklist = property.type == NotePropertyType.progress
                        ? properties
                            .where((candidate) =>
                                candidate.id == property.linkedChecklistId &&
                                candidate.type == NotePropertyType.checklist)
                            .firstOrNull
                        : null;
                    return ListTile(
                      key: ValueKey(property.id),
                      leading: property.isPrimary
                          ? const SizedBox(
                              width: 40,
                              height: 48,
                              child: Center(child: Icon(Icons.key_outlined)),
                            )
                          : ReorderableDragStartListener(
                              index: index,
                              child: const SizedBox(
                                width: 40,
                                height: 48,
                                child: Center(child: Icon(Icons.drag_handle)),
                              ),
                            ),
                      title: Text(checkbox ? 'Checkbox' : property.name),
                      subtitle: Text(
                        checkbox
                            ? 'Item checkbox'
                            : property.type == NotePropertyType.progress
                                ? linkedChecklist == null
                                    ? 'Progress · Manual'
                                    : 'Progress · Linked to ${linkedChecklist.name}'
                                : '${property.type.label}${property.isPrimary ? ' · Primary title' : ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit property',
                            onPressed: () => _edit(property),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            tooltip: 'Delete property',
                            onPressed: property.isPrimary
                                ? null
                                : () => _delete(property),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                  label: const Text('Add property'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: savingList ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: savingList ? null : _saveAndClose,
            child: savingList
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Done'),
          ),
        ],
      );

  Future<void> _pickIcon() async {
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose list icon'),
        content: SizedBox(
          width: 420,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final code in _listIconCodes)
                Tooltip(
                  message: _iconLabel(code),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.pop(context, code),
                    child: Container(
                      width: 72,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _iconFor(code),
                            color: code == icon ? _noteAccent : null,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _iconLabel(code),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) setState(() => icon = picked);
  }

  Future<void> _saveAndClose() async {
    final name = listName.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('List name is required.')),
      );
      return;
    }
    setState(() => savingList = true);
    await ref.read(notePlusRepositoryProvider).saveList(
          widget.bundle.list,
          name: name,
          icon: icon,
        );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _add() async {
    final hasCheckbox = properties.any(
      (property) => property.type == NotePropertyType.checkbox,
    );
    final draft = await showDialog<NotePropertyDraft>(
      context: context,
      builder: (_) => _PropertyEditor(
        hasCheckbox: hasCheckbox,
        checklistProperties: properties
            .where((property) => property.type == NotePropertyType.checklist)
            .toList(),
      ),
    );
    if (draft == null || !mounted) return;
    await ref
        .read(notePlusRepositoryProvider)
        .addProperty(widget.bundle.list.id, draft);
    await _reloadProperties();
  }

  Future<void> _edit(NotePlusProperty property) async {
    final hasOtherCheckbox = properties.any(
      (candidate) =>
          candidate.id != property.id &&
          candidate.type == NotePropertyType.checkbox,
    );
    final draft = await showDialog<NotePropertyDraft>(
      context: context,
      builder: (_) => _PropertyEditor(
        property: property,
        hasCheckbox: hasOtherCheckbox,
        checklistProperties: properties
            .where((candidate) =>
                candidate.type == NotePropertyType.checklist &&
                candidate.id != property.id)
            .toList(),
      ),
    );
    if (draft == null || !mounted) return;
    await ref
        .read(notePlusRepositoryProvider)
        .updateProperty(property, draft);
    await _reloadProperties();
  }

  Future<void> _reloadProperties() async {
    final snapshot = await ref.read(notePlusRepositoryProvider).load();
    if (!mounted) return;
    setState(() {
      properties = [
        ...snapshot.lists
            .firstWhere((b) => b.list.id == widget.bundle.list.id)
            .properties,
      ];
    });
  }

  Future<void> _delete(NotePlusProperty property) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete property?'),
            content: Text(
              'Delete “${property.type == NotePropertyType.checkbox ? 'Checkbox' : property.name}” and all values stored in it?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    await ref.read(notePlusRepositoryProvider).deleteProperty(property);
    if (mounted) {
      setState(() => properties.removeWhere((p) => p.id == property.id));
    }
  }
}

class _PropertyEditor extends StatefulWidget {
  const _PropertyEditor({
    this.property,
    this.hasCheckbox = false,
    this.checklistProperties = const [],
  });

  final NotePlusProperty? property;
  final bool hasCheckbox;
  final List<NotePlusProperty> checklistProperties;

  @override
  State<_PropertyEditor> createState() => _PropertyEditorState();
}

class _PropertyEditorState extends State<_PropertyEditor> {
  late final TextEditingController name =
      TextEditingController(text: widget.property?.name ?? '');
  late final TextEditingController options = TextEditingController(
    text: widget.property?.options.join(', ') ?? '',
  );
  late NotePropertyType type = widget.property?.isPrimary == true
      ? NotePropertyType.text
      : widget.property?.type == NotePropertyType.status
          ? NotePropertyType.select
          : widget.property?.type ?? NotePropertyType.text;
  late String? linkedChecklistId = widget.property?.linkedChecklistId;

  @override
  void dispose() {
    name.dispose();
    options.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCheckbox = type == NotePropertyType.checkbox;
    final validLinkedChecklist = widget.checklistProperties
        .where((property) => property.id == linkedChecklistId)
        .firstOrNull;
    if (type == NotePropertyType.progress &&
        linkedChecklistId != null &&
        validLinkedChecklist == null) {
      linkedChecklistId = null;
    }

    return AlertDialog(
      title: Text(widget.property == null ? 'Add property' : 'Edit property'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCheckbox)
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: 'Property name',
                    hintText: 'Defaults to ${type.label}',
                    border: const OutlineInputBorder(),
                  ),
                )
              else
                const Row(
                  children: [
                    Icon(Icons.check_box_outlined),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This is the list item checkbox. It does not need a name.',
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              DropdownButtonFormField<NotePropertyType>(
                initialValue: type,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: const OutlineInputBorder(),
                  helperText: widget.property?.isPrimary == true
                      ? 'The primary title must stay a Text property.'
                      : null,
                ),
                items: [
                  for (final value in NotePropertyType.values)
                    if (value != NotePropertyType.status &&
                        !(value == NotePropertyType.checkbox &&
                            widget.hasCheckbox &&
                            widget.property?.type != NotePropertyType.checkbox))
                      DropdownMenuItem(value: value, child: Text(value.label)),
                ],
                onChanged: widget.property?.isPrimary == true
                    ? null
                    : (value) => setState(() {
                          type = value ?? type;
                          if (type != NotePropertyType.progress) {
                            linkedChecklistId = null;
                          }
                        }),
              ),
              if (type.hasOptions) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: options,
                  decoration: const InputDecoration(
                    labelText: 'Options',
                    hintText: 'Option 1, Option 2, Option 3',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              if (type == NotePropertyType.progress) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: linkedChecklistId ?? '',
                  decoration: InputDecoration(
                    labelText: 'Progress source',
                    border: const OutlineInputBorder(),
                    helperText: widget.checklistProperties.isEmpty
                        ? 'Add a Checklist property first to enable linking.'
                        : 'Manual progress can be adjusted in 5% steps.',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Manual'),
                    ),
                    for (final checklist in widget.checklistProperties)
                      DropdownMenuItem(
                        value: checklist.id,
                        child: Text('Linked to ${checklist.name}'),
                      ),
                  ],
                  onChanged: (value) => setState(() {
                    linkedChecklistId =
                        value == null || value.isEmpty ? null : value;
                  }),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final resolvedName = type == NotePropertyType.checkbox
                ? 'Checkbox'
                : name.text.trim().isEmpty
                    ? type.label
                    : name.text.trim();
            final values = type.hasOptions
                ? options.text
                    .split(',')
                    .map((v) => v.trim())
                    .where((v) => v.isNotEmpty)
                    .toSet()
                    .toList()
                : <String>[];
            Navigator.pop(
              context,
              NotePropertyDraft(
                name: resolvedName,
                type: type,
                options: values,
                linkedChecklistId: type == NotePropertyType.progress
                    ? linkedChecklistId
                    : null,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

enum _ItemDetailsAction { close, edit, delete }

class _ItemDetailsDialog extends ConsumerStatefulWidget {
  const _ItemDetailsDialog({required this.bundle, required this.item});

  final NotePlusListBundle bundle;
  final NotePlusItem item;

  @override
  ConsumerState<_ItemDetailsDialog> createState() => _ItemDetailsDialogState();
}

class _ItemDetailsDialogState extends ConsumerState<_ItemDetailsDialog> {
  late final Map<String, Object?> values = {...widget.item.values};
  final Set<String> collapsedChecklistIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = widget.bundle.primaryProperty;
    final checkbox = _itemCheckboxProperty(widget.bundle);
    final primaryText = primary == null
        ? 'Untitled item'
        : displayNoteValue(primary, values[primary.id]).trim();
    final details = widget.bundle.properties
        .where(
          (property) =>
              property.id != primary?.id &&
              property.type != NotePropertyType.checkbox,
        )
        .toList();

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Item details',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(
                      context,
                      _ItemDetailsAction.close,
                    ),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (checkbox != null)
                    Checkbox(
                      value: values[checkbox.id] == true,
                      onChanged: (checked) {
                        if (checked == null) return;
                        _setParentCheckbox(checkbox, checked);
                      },
                    ),
                  Expanded(
                    child: Text(
                      primaryText.isEmpty ? 'Untitled item' : primaryText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: details.isEmpty
                    ? const Center(child: Text('No additional properties.'))
                    : ListView.separated(
                        itemCount: details.length,
                        separatorBuilder: (_, _) => const Divider(height: 20),
                        itemBuilder: (context, index) {
                          final property = details[index];
                          if (property.type == NotePropertyType.checklist) {
                            return _checklistDetailSection(context, property);
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.name,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _detailValue(context, property),
                            ],
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(
                      context,
                      _ItemDetailsAction.delete,
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(
                      context,
                      _ItemDetailsAction.edit,
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      _ItemDetailsAction.close,
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checklistDetailSection(
    BuildContext context,
    NotePlusProperty property,
  ) {
    final theme = Theme.of(context);
    final entries = _checklistEntriesForUi(values[property.id])
        .where((entry) => entry['text'].toString().trim().isNotEmpty)
        .toList();
    final done = entries.where((entry) => entry['done'] == true).length;
    final expanded = !collapsedChecklistIds.contains(property.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: entries.isEmpty
              ? null
              : () => setState(() {
                    expanded
                        ? collapsedChecklistIds.add(property.id)
                        : collapsedChecklistIds.remove(property.id);
                  }),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    property.name,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  '${done}/${entries.length} done',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                if (entries.isNotEmpty)
                  Icon(
                    expanded ? Icons.expand_more : Icons.chevron_right,
                    size: 19,
                  ),
              ],
            ),
          ),
        ),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('—', style: theme.textTheme.bodyLarge),
          )
        else if (expanded) ...[
          const SizedBox(height: 4),
          for (var index = 0; index < entries.length; index++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: entries[index]['done'] == true,
                  visualDensity: VisualDensity.compact,
                  onChanged: (checked) {
                    if (checked == null) return;
                    final updated = [
                      for (final entry in entries)
                        Map<String, Object>.from(entry),
                    ];
                    updated[index]['done'] = checked;
                    _saveQuickValue(property.id, updated);
                  },
                ),
                Expanded(
                  child: Text(
                    entries[index]['text'].toString(),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }

  Widget _detailValue(
    BuildContext context,
    NotePlusProperty property,
  ) {
    final theme = Theme.of(context);
    final value = values[property.id];

    if (property.type == NotePropertyType.progress) {
      final progress = _progressValueFor(widget.bundle, property, values);
      final linkedChecklist =
          _linkedChecklistProperty(widget.bundle, property);
      if (linkedChecklist != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 9,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${progress.round()}%',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Linked to ${linkedChecklist.name}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }
      return Row(
        children: [
          Expanded(
            child: Slider(
              value: progress,
              min: 0,
              max: 100,
              divisions: 20,
              label: '${progress.round()}%',
              onChanged: (next) =>
                  setState(() => values[property.id] = next.round()),
              onChangeEnd: (next) =>
                  _saveQuickValue(property.id, next.round()),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              '${progress.round()}%',
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      );
    }

    final display = displayNoteValue(property, value).trim();
    return Text(
      display.isEmpty ? '—' : display,
      style: theme.textTheme.bodyLarge,
    );
  }

  Future<void> _setParentCheckbox(
    NotePlusProperty checkbox,
    bool checked,
  ) async {
    if (checked && !_allChecklistTasksComplete(widget.bundle, values)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete all checklist tasks first.')),
      );
      return;
    }
    await _saveQuickValue(checkbox.id, checked);
  }

  Future<void> _saveQuickValue(String propertyId, Object? value) async {
    final updates = <String, Object?>{propertyId: value};
    final property = widget.bundle.properties
        .where((candidate) => candidate.id == propertyId)
        .firstOrNull;
    if (property?.type == NotePropertyType.checklist && value is List) {
      final checklistValue = value
          .whereType<Map>()
          .map((entry) => <String, Object>{
                'text': entry['text']?.toString() ?? '',
                'done': entry['done'] == true,
              })
          .toList();
      updates
        ..clear()
        ..addAll(
          _checklistUpdateWithCompletionSync(
            widget.bundle,
            values,
            propertyId,
            checklistValue,
          ),
        );
    }
    setState(() => values.addAll(updates));
    final repo = ref.read(notePlusRepositoryProvider);
    await repo.saveItemValues(
      widget.bundle.list.id,
      widget.item.row.id,
      updates,
    );
    final snapshot = await repo.load();
    if (!mounted) return;
    final freshBundle = snapshot.lists
        .where((bundle) => bundle.list.id == widget.bundle.list.id)
        .firstOrNull;
    final freshItem = freshBundle?.items
        .where((item) => item.row.id == widget.item.row.id)
        .firstOrNull;
    if (freshItem != null) {
      setState(() {
        values
          ..clear()
          ..addAll(freshItem.values);
      });
    }
  }
}

class _ItemEditor extends ConsumerStatefulWidget {
  const _ItemEditor({
    required this.bundle,
    this.item,
    this.onDelete,
  });

  final NotePlusListBundle bundle;
  final NotePlusItem? item;
  final Future<bool> Function()? onDelete;

  @override
  ConsumerState<_ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends ConsumerState<_ItemEditor> {
  late final Map<String, Object?> values = {...?widget.item?.values};
  bool saving = false;

  @override
  Widget build(BuildContext context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 720),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      widget.item == null ? 'Add item' : 'Edit item',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ]),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: widget.bundle.properties.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _field(widget.bundle.properties[i]),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (widget.item != null && widget.onDelete != null)
                      TextButton.icon(
                        onPressed: _delete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: saving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 6),
                    FilledButton(
                      onPressed: saving ? null : _save,
                      child: saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget _field(NotePlusProperty property) {
    final value = values[property.id];
    switch (property.type) {
      case NotePropertyType.checkbox:
        return CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Item checkbox'),
          subtitle: !_allChecklistTasksComplete(widget.bundle, values)
              ? const Text('Complete all checklist tasks first.')
              : null,
          value: value == true,
          onChanged: (checked) {
            final next = checked == true;
            if (next && !_allChecklistTasksComplete(widget.bundle, values)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Complete all checklist tasks first.'),
                ),
              );
              return;
            }
            setState(() => values[property.id] = next);
          },
        );
      case NotePropertyType.select:
      case NotePropertyType.status:
        final current = value?.toString();
        return DropdownButtonFormField<String>(
          initialValue: property.options.contains(current) ? current : null,
          decoration: InputDecoration(
            labelText: property.name,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final option in property.options)
              DropdownMenuItem(value: option, child: Text(option)),
          ],
          onChanged: (v) => setState(() => values[property.id] = v),
        );
      case NotePropertyType.multiSelect:
        final selected = value is List
            ? value.map((v) => v.toString()).toSet()
            : <String>{};
        return InputDecorator(
          decoration: InputDecoration(
            labelText: property.name,
            border: const OutlineInputBorder(),
          ),
          child: Wrap(
            spacing: 5,
            runSpacing: 4,
            children: [
              for (final option in property.options)
                FilterChip(
                  label: Text(option),
                  selected: selected.contains(option),
                  onSelected: (on) => setState(() {
                    on ? selected.add(option) : selected.remove(option);
                    values[property.id] = selected.toList();
                  }),
                ),
            ],
          ),
        );
      case NotePropertyType.rating:
        final rating = noteNumericValue(value)?.round() ?? 0;
        return InputDecorator(
          decoration: InputDecoration(
            labelText: property.name,
            border: const OutlineInputBorder(),
          ),
          child: Row(
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => values[property.id] = i),
                  icon: Icon(i <= rating ? Icons.star : Icons.star_border),
                ),
            ],
          ),
        );
      case NotePropertyType.progress:
        final progress = _progressValueFor(widget.bundle, property, values);
        final linkedChecklist =
            _linkedChecklistProperty(widget.bundle, property);
        return InputDecorator(
          decoration: InputDecoration(
            labelText: '${property.name} · ${progress.round()}%',
            border: const OutlineInputBorder(),
            helperText: linkedChecklist == null
                ? 'Manual · 5% steps'
                : 'Linked to ${linkedChecklist.name}',
          ),
          child: linkedChecklist == null
              ? Slider(
                  value: progress,
                  max: 100,
                  divisions: 20,
                  onChanged: (v) =>
                      setState(() => values[property.id] = v.round()),
                )
              : Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          minHeight: 9,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${progress.round()}%'),
                  ],
                ),
        );
      case NotePropertyType.date:
      case NotePropertyType.dateTime:
        return _DateValueField(
          label: property.name,
          includeTime: property.type == NotePropertyType.dateTime,
          value: value?.toString(),
          onChanged: (v) => setState(() => values[property.id] = v),
        );
      case NotePropertyType.checklist:
        return _ChecklistField(
          label: property.name,
          value: value,
          onChanged: (v) => setState(() {
            values[property.id] = v;
            final checkbox = _itemCheckboxProperty(widget.bundle);
            if (checkbox != null &&
                values[checkbox.id] == true &&
                !_allChecklistTasksComplete(widget.bundle, values)) {
              values[checkbox.id] = false;
            }
          }),
        );
      case NotePropertyType.longText:
        return _TextValueField(
          label: property.name,
          initial: value?.toString() ?? '',
          maxLines: 4,
          onChanged: (v) => values[property.id] = v,
        );
      case NotePropertyType.number:
      case NotePropertyType.currency:
        return _TextValueField(
          label: property.name,
          initial: value?.toString() ?? '',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) => values[property.id] = double.tryParse(v) ?? v,
        );
      case NotePropertyType.url:
        return _TextValueField(
          label: property.name,
          initial: value?.toString() ?? '',
          keyboardType: TextInputType.url,
          onChanged: (v) => values[property.id] = v,
        );
      case NotePropertyType.text:
        return _TextValueField(
          label: property.name,
          initial: value?.toString() ?? '',
          onChanged: (v) => values[property.id] = v,
        );
    }
  }

  Future<void> _delete() async {
    final deleted = await widget.onDelete?.call() ?? false;
    if (deleted && mounted) Navigator.pop(context);
  }

  Future<void> _save() async {
    final primary = widget.bundle.primaryProperty;
    if (primary != null &&
        (values[primary.id]?.toString().trim().isEmpty ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${primary.name} is required.')),
      );
      return;
    }
    setState(() => saving = true);
    final repo = ref.read(notePlusRepositoryProvider);
    if (widget.item == null) {
      final id = await repo.createItem(widget.bundle.list.id, values: values);
      if (mounted) Navigator.pop(context, id);
      return;
    }
    await repo.saveItemValues(
      widget.bundle.list.id,
      widget.item!.row.id,
      values,
    );
    if (mounted) Navigator.pop(context, widget.item!.row.id);
  }
}

class _TextValueField extends StatefulWidget {
  const _TextValueField({required this.label, required this.initial, required this.onChanged, this.maxLines = 1, this.keyboardType});
  final String label, initial;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final TextInputType? keyboardType;
  @override
  State<_TextValueField> createState() => _TextValueFieldState();
}

class _TextValueFieldState extends State<_TextValueField> {
  late final controller = TextEditingController(text: widget.initial);
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => TextField(controller: controller, maxLines: widget.maxLines, keyboardType: widget.keyboardType, onChanged: widget.onChanged, decoration: InputDecoration(labelText: widget.label, border: const OutlineInputBorder()));
}

class _DateValueField extends StatelessWidget {
  const _DateValueField({required this.label, required this.includeTime, required this.value, required this.onChanged});
  final String label;
  final bool includeTime;
  final String? value;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) {
    final parsed = value == null ? null : DateTime.tryParse(value!);
    final display = parsed == null ? 'Not set' : _formatDate(parsed, includeTime: includeTime);
    return InputDecorator(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      child: Row(children: [
        Expanded(child: Text(display)),
        if (parsed != null) IconButton(onPressed: () => onChanged(null), icon: const Icon(Icons.clear)),
        IconButton(onPressed: () async {
          final now = DateTime.now();
          final date = await showDatePicker(context: context, firstDate: DateTime(now.year - 20), lastDate: DateTime(now.year + 30), initialDate: parsed ?? now);
          if (date == null || !context.mounted) return;
          var result = DateTime(date.year, date.month, date.day);
          if (includeTime) {
            final time = await showTimePicker(context: context, initialTime: parsed == null ? TimeOfDay.now() : TimeOfDay.fromDateTime(parsed));
            if (time == null) return;
            result = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          }
          onChanged(result.toIso8601String());
        }, icon: const Icon(Icons.calendar_today_outlined)),
      ]),
    );
  }
}

class _ChecklistField extends StatefulWidget {
  const _ChecklistField({required this.label, required this.value, required this.onChanged});
  final String label;
  final Object? value;
  final ValueChanged<List<Map<String, Object>>> onChanged;
  @override
  State<_ChecklistField> createState() => _ChecklistFieldState();
}

class _ChecklistFieldState extends State<_ChecklistField> {
  late final List<Map<String, Object>> entries;
  late final List<Key> entryKeys;
  final add = TextEditingController();

  @override
  void initState() {
    super.initState();
    entries = widget.value is List
        ? (widget.value as List)
            .whereType<Map>()
            .map(
              (entry) => <String, Object>{
                'text': entry['text']?.toString() ?? '',
                'done': entry['done'] == true,
              },
            )
            .toList()
        : <Map<String, Object>>[];
    entryKeys = [for (var i = 0; i < entries.length; i++) UniqueKey()];
  }

  @override
  void dispose() {
    add.dispose();
    super.dispose();
  }

  void changed() => widget.onChanged(
        entries.map((entry) => Map<String, Object>.from(entry)).toList(),
      );

  @override
  Widget build(BuildContext context) => InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
        ),
        child: Column(
          children: [
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: entries.length,
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  final entry = entries.removeAt(oldIndex);
                  final key = entryKeys.removeAt(oldIndex);
                  entries.insert(newIndex, entry);
                  entryKeys.insert(newIndex, key);
                });
                changed();
              },
              itemBuilder: (context, index) => Row(
                key: entryKeys[index],
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(Icons.drag_handle, size: 20),
                    ),
                  ),
                  Checkbox(
                    value: entries[index]['done'] == true,
                    onChanged: (next) {
                      setState(() => entries[index]['done'] = next == true);
                      changed();
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue: entries[index]['text'].toString(),
                      decoration: const InputDecoration(
                        hintText: 'Mini-task',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (text) {
                        entries[index]['text'] = text;
                        changed();
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete mini-task',
                    onPressed: () {
                      setState(() {
                        entries.removeAt(index);
                        entryKeys.removeAt(index);
                      });
                      changed();
                    },
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: add,
                    decoration: const InputDecoration(
                      hintText: 'Add mini-task',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                IconButton(onPressed: _add, icon: const Icon(Icons.add)),
              ],
            ),
          ],
        ),
      );

  void _add() {
    final text = add.text.trim();
    if (text.isEmpty) return;
    setState(() {
      entries.add({'text': text, 'done': false});
      entryKeys.add(UniqueKey());
      add.clear();
    });
    changed();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.archived, required this.hasQuery, required this.onCreate});
  final bool archived, hasQuery;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          primary: false,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight.isFinite ? constraints.maxHeight - 16 : 0,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      archived ? Icons.inventory_2_outlined : Icons.note_alt_outlined,
                      size: 44,
                      color: _noteAccent,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      hasQuery
                          ? 'Nothing matched your search.'
                          : archived
                              ? 'Your archive is empty.'
                              : 'Create your first note or list.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (!archived && !hasQuery) ...[
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: onCreate,
                        icon: const Icon(Icons.add),
                        label: const Text('Create'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

const _listIconCodes = <String>[
  'list',
  'shopping',
  'movie',
  'project',
  'book',
  'travel',
  'checklist',
  'folder',
  'star',
  'food',
  'money',
  'school',
  'fitness',
];

String _iconLabel(String icon) => switch (icon) {
      'shopping' => 'Shopping',
      'movie' => 'Movie',
      'project' => 'Project',
      'book' => 'Book',
      'travel' => 'Travel',
      'checklist' => 'Checklist',
      'folder' => 'Folder',
      'star' => 'Star',
      'food' => 'Food',
      'money' => 'Money',
      'school' => 'School',
      'fitness' => 'Fitness',
      _ => 'List',
    };

IconData _iconFor(String icon) => switch (icon) {
      'shopping' => Icons.shopping_cart_outlined,
      'movie' => Icons.movie_outlined,
      'project' => Icons.account_tree_outlined,
      'book' => Icons.menu_book_outlined,
      'travel' => Icons.flight_takeoff_outlined,
      'checklist' => Icons.checklist_rounded,
      'folder' => Icons.folder_outlined,
      'star' => Icons.star_outline_rounded,
      'food' => Icons.restaurant_outlined,
      'money' => Icons.payments_outlined,
      'school' => Icons.school_outlined,
      'fitness' => Icons.fitness_center_outlined,
      _ => Icons.table_rows_outlined,
    };


String _formatDate(DateTime value, {bool includeTime = false}) {
  final date = '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  if (!includeTime) return date;
  return '$date ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
