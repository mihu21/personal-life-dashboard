import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/note_plus_repository.dart';
import '../domain/note_plus_types.dart';
import '../providers/note_plus_providers.dart';

const _noteAccent = Color(0xFF6F63A9);

void openFullNotePlus(BuildContext context) => Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Note+')),
          body: const SafeArea(child: NotePlusModule(showTitle: false)),
        ),
      ),
    );

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showTitle) ...[
            Text('Note+', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
          ],
          Row(
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
                tooltip: _showArchived ? 'Show active' : 'Show archive',
                onPressed: () => setState(() => _showArchived = !_showArchived),
                icon: Icon(_showArchived ? Icons.inventory_2 : Icons.archive_outlined),
              ),
              const SizedBox(width: 6),
              FilledButton.icon(
                onPressed: () => _showCreateMenu(context),
                icon: const Icon(Icons.add),
                label: const Text('New'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: data.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Could not load Note+: $error')),
              data: _buildContent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(NotePlusSnapshot snapshot) {
    final query = _search.text.trim().toLowerCase();
    final notes = snapshot.notes.where((note) {
      if (note.archived != _showArchived) return false;
      return query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          note.body.toLowerCase().contains(query);
    }).toList();
    final lists = snapshot.lists.where((bundle) {
      if (bundle.list.archived != _showArchived) return false;
      if (query.isEmpty) return true;
      if (bundle.list.name.toLowerCase().contains(query)) return true;
      return bundle.items.any((item) => item.values.values.any(
            (value) => value?.toString().toLowerCase().contains(query) ?? false,
          ));
    }).toList();

    if (notes.isEmpty && lists.isEmpty) {
      return _EmptyState(
        archived: _showArchived,
        hasQuery: query.isNotEmpty,
        onCreate: () => _showCreateMenu(context),
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
              for (final note in notes)
                SizedBox(
                  width: width,
                  child: _NoteCard(
                    note: note,
                    onOpen: () => _editNote(note),
                    onPin: () => ref.read(notePlusRepositoryProvider).saveNote(note, pinned: !note.pinned),
                    onArchive: () => ref.read(notePlusRepositoryProvider).saveNote(note, archived: !note.archived),
                    onDelete: () => _deleteNote(note),
                  ),
                ),
              for (final bundle in lists)
                SizedBox(
                  width: width,
                  child: _ListCard(
                    bundle: bundle,
                    onOpen: () => _openList(bundle.list.id),
                    onPin: () => ref.read(notePlusRepositoryProvider).saveList(bundle.list, pinned: !bundle.list.pinned),
                    onArchive: () => ref.read(notePlusRepositoryProvider).saveList(bundle.list, archived: !bundle.list.archived),
                    onDelete: () => _deleteList(bundle),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCreateMenu(BuildContext context) async {
    final choice = await showModalBottomSheet<String>(
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
                  subtitle: const Text('Start with a Name property and build your own structure'),
                  onTap: () => Navigator.pop(context, 'blank'),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text('Templates', style: Theme.of(context).textTheme.labelLarge),
                ),
                for (var i = 0; i < noteListTemplates.length; i++)
                  ListTile(
                    leading: Icon(_iconFor(noteListTemplates[i].icon)),
                    title: Text(noteListTemplates[i].name),
                    subtitle: Text(noteListTemplates[i].properties.map((p) => p.name).join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => Navigator.pop(context, 'template:$i'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || choice == null) return;
    final repo = ref.read(notePlusRepositoryProvider);
    if (choice == 'note') {
      final id = await repo.createNote();
      final snapshot = await repo.load();
      if (!mounted) return;
      final note = snapshot.notes.firstWhere((note) => note.id == id);
      await _editNote(note);
    } else if (choice == 'blank') {
      final name = await _askForName('New list', 'List name');
      if (name == null || !mounted) return;
      final id = await repo.createList(name: name);
      if (mounted) _openList(id);
    } else if (choice.startsWith('template:')) {
      final index = int.parse(choice.split(':').last);
      final template = noteListTemplates[index];
      final id = await repo.createList(name: template.name, icon: template.icon, properties: template.properties);
      if (mounted) _openList(id);
    }
  }

  Future<String?> _askForName(String title, String label, {String initial = ''}) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true, decoration: InputDecoration(labelText: label)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    return result?.trim().isEmpty == true ? null : result;
  }

  Future<void> _editNote(NoteRecord note) async {
    await showDialog<void>(context: context, builder: (_) => _NoteEditor(note: note));
  }

  void _openList(String id) {
    Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => NoteListPage(listId: id)));
  }

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
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
          ],
        ),
      ) ?? false;
}

class NotePlusDashboardCard extends ConsumerWidget {
  const NotePlusDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(notePlusProvider);
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openFullNotePlus(context),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.note_alt_outlined, color: _noteAccent),
                  const SizedBox(width: 7),
                  Expanded(child: Text('Note+', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
                  const Icon(Icons.open_in_full, size: 17),
                ],
              ),
              const Divider(),
              Expanded(
                child: data.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const Center(child: Text('Could not load Note+')),
                  data: (snapshot) {
                    final activeNotes = snapshot.notes.where((n) => !n.archived).toList();
                    final activeLists = snapshot.lists.where((l) => !l.list.archived).toList();
                    if (activeNotes.isEmpty && activeLists.isEmpty) {
                      return const Center(child: Text('Create notes and flexible lists'));
                    }
                    final entries = <Widget>[
                      for (final note in activeNotes.take(2))
                        _CompactRow(icon: Icons.notes, title: note.title, subtitle: note.body.trim().isEmpty ? 'Note' : note.body.trim()),
                      for (final list in activeLists.take(3))
                        _CompactRow(icon: _iconFor(list.list.icon), title: list.list.name, subtitle: '${list.items.length} items · ${list.properties.length} properties'),
                    ];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final count = (constraints.maxHeight / 44)
                            .floor()
                            .clamp(1, 4);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: entries.take(count).toList(),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactRow extends StatelessWidget {
  const _CompactRow({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => ListTile(
        dense: true,
        leading: Icon(icon, size: 18),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      );
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onOpen, required this.onPin, required this.onArchive, required this.onDelete});
  final NoteRecord note;
  final VoidCallback onOpen, onPin, onArchive, onDelete;

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
                Row(children: [
                  const Icon(Icons.note_alt_outlined, color: _noteAccent, size: 20),
                  const SizedBox(width: 7),
                  Expanded(child: Text(note.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (note.pinned) const Icon(Icons.push_pin, size: 16),
                  _EntryMenu(pinned: note.pinned, archived: note.archived, onPin: onPin, onArchive: onArchive, onDelete: onDelete),
                ]),
                const SizedBox(height: 8),
                Text(note.body.trim().isEmpty ? 'Empty note' : note.body.trim(), maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      );
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.bundle, required this.onOpen, required this.onPin, required this.onArchive, required this.onDelete});
  final NotePlusListBundle bundle;
  final VoidCallback onOpen, onPin, onArchive, onDelete;

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
                Row(children: [
                  Icon(_iconFor(bundle.list.icon), color: _noteAccent, size: 20),
                  const SizedBox(width: 7),
                  Expanded(child: Text(bundle.list.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (bundle.list.pinned) const Icon(Icons.push_pin, size: 16),
                  _EntryMenu(pinned: bundle.list.pinned, archived: bundle.list.archived, onPin: onPin, onArchive: onArchive, onDelete: onDelete),
                ]),
                const SizedBox(height: 8),
                Text('${bundle.items.length} items · ${bundle.properties.length} properties', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 6),
                Text(bundle.properties.map((p) => p.name).take(4).join(' · '), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      );
}

class _EntryMenu extends StatelessWidget {
  const _EntryMenu({required this.pinned, required this.archived, required this.onPin, required this.onArchive, required this.onDelete});
  final bool pinned, archived;
  final VoidCallback onPin, onArchive, onDelete;
  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
        tooltip: 'More',
        onSelected: (value) {
          if (value == 'pin') onPin();
          if (value == 'archive') onArchive();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'pin', child: Text(pinned ? 'Unpin' : 'Pin')),
          PopupMenuItem(value: 'archive', child: Text(archived ? 'Restore' : 'Archive')),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      );
}

class _NoteEditor extends ConsumerStatefulWidget {
  const _NoteEditor({required this.note});
  final NoteRecord note;
  @override
  ConsumerState<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<_NoteEditor> {
  late final TextEditingController title = TextEditingController(text: widget.note.title);
  late final TextEditingController body = TextEditingController(text: widget.note.body);
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
                  Expanded(child: Text('Edit note', style: Theme.of(context).textTheme.titleLarge)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ]),
                const SizedBox(height: 8),
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                Expanded(
                  child: TextField(
                    controller: body,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(hintText: 'Write anything…', border: OutlineInputBorder(), alignLabelWithHint: true),
                  ),
                ),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  const SizedBox(width: 6),
                  FilledButton(
                    onPressed: saving ? null : _save,
                    child: saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
                  ),
                ]),
              ],
            ),
          ),
        ),
      );

  Future<void> _save() async {
    if (title.text.trim().isEmpty) return;
    setState(() => saving = true);
    await ref.read(notePlusRepositoryProvider).saveNote(widget.note, title: title.text, body: body.text);
    if (mounted) Navigator.pop(context);
  }
}

class NoteListPage extends ConsumerStatefulWidget {
  const NoteListPage({required this.listId, super.key});
  final String listId;
  @override
  ConsumerState<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends ConsumerState<NoteListPage> {
  final search = TextEditingController();
  String? sortPropertyId;
  bool sortAscending = true;
  String? filterPropertyId;
  String filterText = '';

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
    var items = bundle.items.where((item) {
      final q = search.text.trim().toLowerCase();
      if (q.isNotEmpty && !item.values.values.any((v) => v?.toString().toLowerCase().contains(q) ?? false)) return false;
      if (filterPropertyId != null && filterText.trim().isNotEmpty) {
        final value = item.values[filterPropertyId];
        if (!value.toString().toLowerCase().contains(filterText.trim().toLowerCase())) return false;
      }
      return true;
    }).toList();
    if (sortPropertyId != null) {
      items.sort((a, b) {
        final av = a.values[sortPropertyId];
        final bv = b.values[sortPropertyId];
        int result;
        final an = noteNumericValue(av), bn = noteNumericValue(bv);
        if (an != null && bn != null) {
          result = an.compareTo(bn);
        } else {
          result = (av?.toString() ?? '').toLowerCase().compareTo((bv?.toString() ?? '').toLowerCase());
        }
        return sortAscending ? result : -result;
      });
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Icon(_iconFor(bundle.list.icon), color: _noteAccent, size: 28),
            const SizedBox(width: 8),
            Expanded(child: Text(bundle.list.name, style: Theme.of(context).textTheme.headlineSmall)),
            IconButton(tooltip: 'Rename', onPressed: () => _renameList(bundle), icon: const Icon(Icons.edit_outlined)),
            OutlinedButton.icon(onPressed: () => _manageProperties(bundle), icon: const Icon(Icons.tune), label: const Text('Properties')),
            const SizedBox(width: 6),
            FilledButton.icon(onPressed: () => _addItem(bundle), icon: const Icon(Icons.add), label: const Text('Add item')),
          ]),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(width: 260, child: TextField(controller: search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search items', border: OutlineInputBorder()))),
              MenuAnchor(
                builder: (context, controller, child) => OutlinedButton.icon(
                  onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                  icon: const Icon(Icons.sort),
                  label: Text(sortPropertyId == null ? 'Sort' : 'Sort: ${bundle.properties.where((p) => p.id == sortPropertyId).firstOrNull?.name ?? ''}'),
                ),
                menuChildren: [
                  MenuItemButton(onPressed: () => setState(() => sortPropertyId = null), child: const Text('None')),
                  for (final property in bundle.properties)
                    MenuItemButton(onPressed: () => setState(() => sortPropertyId = property.id), child: Text(property.name)),
                  const Divider(),
                  MenuItemButton(onPressed: () => setState(() => sortAscending = !sortAscending), child: Text(sortAscending ? 'Ascending ↑' : 'Descending ↓')),
                ],
              ),
              MenuAnchor(
                builder: (context, controller, child) => OutlinedButton.icon(
                  onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                  icon: const Icon(Icons.filter_alt_outlined),
                  label: Text(filterPropertyId == null ? 'Filter' : 'Filter: ${bundle.properties.where((p) => p.id == filterPropertyId).firstOrNull?.name ?? ''}'),
                ),
                menuChildren: [
                  MenuItemButton(onPressed: () => setState(() { filterPropertyId = null; filterText = ''; }), child: const Text('Clear filter')),
                  for (final property in bundle.properties)
                    MenuItemButton(onPressed: () async {
                      final text = await _askText('Filter ${property.name}', 'Contains', initial: filterPropertyId == property.id ? filterText : '');
                      if (text != null && mounted) setState(() { filterPropertyId = property.id; filterText = text; });
                    }, child: Text(property.name)),
                ],
              ),
              if (filterPropertyId != null && filterText.isNotEmpty)
                InputChip(label: Text('Contains “$filterText”'), onDeleted: () => setState(() { filterPropertyId = null; filterText = ''; })),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? Center(child: Text(bundle.items.isEmpty ? 'No items yet. Add your first item.' : 'No items match the current search or filter.'))
                : LayoutBuilder(builder: (context, constraints) {
                    if (constraints.maxWidth >= 700) return _DesktopListTable(bundle: bundle, items: items, onEdit: (item) => _editItem(bundle, item), onDelete: (item) => _deleteItem(bundle, item));
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (_, index) => _MobileItemCard(bundle: bundle, item: items[index], onEdit: () => _editItem(bundle, items[index]), onDelete: () => _deleteItem(bundle, items[index])),
                    );
                  }),
          ),
        ],
      ),
    );
  }

  Future<String?> _askText(String title, String label, {String initial = ''}) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(context: context, builder: (context) => AlertDialog(
      title: Text(title), content: TextField(controller: controller, autofocus: true, decoration: InputDecoration(labelText: label)),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Apply'))],
    ));
    controller.dispose();
    return result;
  }

  Future<void> _renameList(NotePlusListBundle bundle) async {
    final name = await _askText('Rename list', 'Name', initial: bundle.list.name);
    if (name == null || name.trim().isEmpty) return;
    await ref.read(notePlusRepositoryProvider).saveList(bundle.list, name: name);
  }

  Future<void> _manageProperties(NotePlusListBundle bundle) => showDialog<void>(context: context, builder: (_) => _PropertiesDialog(bundle: bundle));

  Future<void> _addItem(NotePlusListBundle bundle) async {
    final id = await ref.read(notePlusRepositoryProvider).createItem(bundle.list.id);
    if (!mounted) return;
    final snapshot = await ref.read(notePlusRepositoryProvider).load();
    final fresh = snapshot.lists.firstWhere((b) => b.list.id == bundle.list.id);
    final item = fresh.items.firstWhere((i) => i.row.id == id);
    if (mounted) await _editItem(fresh, item);
  }

  Future<void> _editItem(NotePlusListBundle bundle, NotePlusItem item) => showDialog<void>(context: context, builder: (_) => _ItemEditor(bundle: bundle, item: item));

  Future<void> _deleteItem(NotePlusListBundle bundle, NotePlusItem item) async {
    final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Delete item?'),
      content: const Text('This item will be permanently deleted.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))],
    )) ?? false;
    if (ok) await ref.read(notePlusRepositoryProvider).deleteItem(bundle.list.id, item.row.id);
  }
}

class _DesktopListTable extends StatelessWidget {
  const _DesktopListTable({required this.bundle, required this.items, required this.onEdit, required this.onDelete});
  final NotePlusListBundle bundle;
  final List<NotePlusItem> items;
  final ValueChanged<NotePlusItem> onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    final visible = bundle.properties.take(6).toList();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Table(
          columnWidths: {for (var i = 0; i < visible.length; i++) i: const FlexColumnWidth(), visible.length: const FixedColumnWidth(86)},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(horizontalInside: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerLow),
              children: [
                for (final property in visible) Padding(padding: const EdgeInsets.all(10), child: Text(property.name, style: Theme.of(context).textTheme.labelLarge)),
                const SizedBox.shrink(),
              ],
            ),
            for (final item in items)
              TableRow(children: [
                for (final property in visible)
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), child: Text(displayNoteValue(property, item.values[property.id]), maxLines: 2, overflow: TextOverflow.ellipsis)),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(tooltip: 'Edit', onPressed: () => onEdit(item), icon: const Icon(Icons.edit_outlined, size: 19)),
                  IconButton(tooltip: 'Delete', onPressed: () => onDelete(item), icon: const Icon(Icons.delete_outline, size: 19)),
                ]),
              ]),
          ],
        ),
      ),
    );
  }
}

class _MobileItemCard extends StatelessWidget {
  const _MobileItemCard({required this.bundle, required this.item, required this.onEdit, required this.onDelete});
  final NotePlusListBundle bundle;
  final NotePlusItem item;
  final VoidCallback onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final primary = bundle.primaryProperty;
    final title = primary == null ? 'Item' : displayNoteValue(primary, item.values[primary.id]);
    return Card(
      child: ListTile(
        onTap: onEdit,
        title: Text(title.isEmpty ? 'Untitled item' : title),
        subtitle: Text(bundle.properties.where((p) => p.id != primary?.id).take(3).map((p) {
          final value = displayNoteValue(p, item.values[p.id]);
          return value.isEmpty ? null : '${p.name}: $value';
        }).whereType<String>().join(' · '), maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: PopupMenuButton<String>(onSelected: (v) => v == 'edit' ? onEdit() : onDelete(), itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))]),
      ),
    );
  }
}

class _PropertiesDialog extends ConsumerStatefulWidget {
  const _PropertiesDialog({required this.bundle});
  final NotePlusListBundle bundle;
  @override
  ConsumerState<_PropertiesDialog> createState() => _PropertiesDialogState();
}

class _PropertiesDialogState extends ConsumerState<_PropertiesDialog> {
  late List<NotePlusProperty> properties = [...widget.bundle.properties];

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Manage properties'),
        content: SizedBox(
          width: 560,
          height: 440,
          child: Column(children: [
            Expanded(
              child: ReorderableListView.builder(
                itemCount: properties.length,
                onReorderItem: (oldIndex, newIndex) async {
                  if (oldIndex == 0) return;
                  if (newIndex == 0) newIndex = 1;
                  setState(() {
                    final moved = properties.removeAt(oldIndex);
                    properties.insert(newIndex, moved);
                  });
                  await ref.read(notePlusRepositoryProvider).reorderProperties(widget.bundle.list.id, properties);
                },
                itemBuilder: (context, index) {
                  final property = properties[index];
                  return ListTile(
                    key: ValueKey(property.id),
                    leading: property.isPrimary ? const Icon(Icons.key_outlined) : const Icon(Icons.drag_handle),
                    title: Text(property.name),
                    subtitle: Text('${property.type.label}${property.isPrimary ? ' · Primary title' : ''}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(onPressed: property.isPrimary ? null : () => _edit(property), icon: const Icon(Icons.edit_outlined)),
                      IconButton(onPressed: property.isPrimary ? null : () => _delete(property), icon: const Icon(Icons.delete_outline)),
                    ]),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: FilledButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Add property'))),
          ]),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
      );

  Future<void> _add() async {
    final draft = await showDialog<NotePropertyDraft>(context: context, builder: (_) => const _PropertyEditor());
    if (draft == null || !mounted) return;
    await ref.read(notePlusRepositoryProvider).addProperty(widget.bundle.list.id, draft);
    final snapshot = await ref.read(notePlusRepositoryProvider).load();
    if (!mounted) return;
    setState(() => properties = [...snapshot.lists.firstWhere((b) => b.list.id == widget.bundle.list.id).properties]);
  }

  Future<void> _edit(NotePlusProperty property) async {
    final draft = await showDialog<NotePropertyDraft>(context: context, builder: (_) => _PropertyEditor(property: property));
    if (draft == null || !mounted) return;
    await ref.read(notePlusRepositoryProvider).updateProperty(property, draft);
    final snapshot = await ref.read(notePlusRepositoryProvider).load();
    if (!mounted) return;
    setState(() => properties = [...snapshot.lists.firstWhere((b) => b.list.id == widget.bundle.list.id).properties]);
  }

  Future<void> _delete(NotePlusProperty property) async {
    final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Delete property?'), content: Text('Delete “${property.name}” and all values stored in it?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))])) ?? false;
    if (!ok) return;
    await ref.read(notePlusRepositoryProvider).deleteProperty(property);
    if (mounted) setState(() => properties.removeWhere((p) => p.id == property.id));
  }
}

class _PropertyEditor extends StatefulWidget {
  const _PropertyEditor({this.property});
  final NotePlusProperty? property;
  @override
  State<_PropertyEditor> createState() => _PropertyEditorState();
}

class _PropertyEditorState extends State<_PropertyEditor> {
  late final TextEditingController name = TextEditingController(text: widget.property?.name ?? '');
  late final TextEditingController options = TextEditingController(text: widget.property?.options.join(', ') ?? '');
  late NotePropertyType type = widget.property?.type ?? NotePropertyType.text;

  @override
  void dispose() { name.dispose(); options.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.property == null ? 'Add property' : 'Edit property'),
        content: SizedBox(width: 440, child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Property name', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          DropdownButtonFormField<NotePropertyType>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
            items: [for (final value in NotePropertyType.values) DropdownMenuItem(value: value, child: Text(value.label))],
            onChanged: (value) => setState(() => type = value ?? type),
          ),
          if (type.hasOptions) ...[
            const SizedBox(height: 10),
            TextField(controller: options, decoration: const InputDecoration(labelText: 'Options', hintText: 'Option 1, Option 2, Option 3', border: OutlineInputBorder())),
          ],
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            final trimmed = name.text.trim();
            if (trimmed.isEmpty) return;
            final values = type.hasOptions ? options.text.split(',').map((v) => v.trim()).where((v) => v.isNotEmpty).toSet().toList() : <String>[];
            Navigator.pop(context, NotePropertyDraft(name: trimmed, type: type, options: values));
          }, child: const Text('Save')),
        ],
      );
}

class _ItemEditor extends ConsumerStatefulWidget {
  const _ItemEditor({required this.bundle, required this.item});
  final NotePlusListBundle bundle;
  final NotePlusItem item;
  @override
  ConsumerState<_ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends ConsumerState<_ItemEditor> {
  late final Map<String, Object?> values = {...widget.item.values};

  @override
  Widget build(BuildContext context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 720),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [Expanded(child: Text('Edit item', style: Theme.of(context).textTheme.titleLarge)), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))]),
              const SizedBox(height: 8),
              Expanded(child: ListView.separated(itemCount: widget.bundle.properties.length, separatorBuilder: (_, _) => const SizedBox(height: 10), itemBuilder: (_, i) => _field(widget.bundle.properties[i]))),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), const SizedBox(width: 6), FilledButton(onPressed: _save, child: const Text('Save'))]),
            ]),
          ),
        ),
      );

  Widget _field(NotePlusProperty property) {
    final value = values[property.id];
    switch (property.type) {
      case NotePropertyType.checkbox:
        return SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(property.name), value: value == true, onChanged: (v) => setState(() => values[property.id] = v));
      case NotePropertyType.select:
      case NotePropertyType.status:
        final current = value?.toString();
        return DropdownButtonFormField<String>(
          initialValue: property.options.contains(current) ? current : null,
          decoration: InputDecoration(labelText: property.name, border: const OutlineInputBorder()),
          items: [for (final option in property.options) DropdownMenuItem(value: option, child: Text(option))],
          onChanged: (v) => values[property.id] = v,
        );
      case NotePropertyType.multiSelect:
        final selected = value is List ? value.map((v) => v.toString()).toSet() : <String>{};
        return InputDecorator(
          decoration: InputDecoration(labelText: property.name, border: const OutlineInputBorder()),
          child: Wrap(spacing: 5, runSpacing: 4, children: [for (final option in property.options) FilterChip(label: Text(option), selected: selected.contains(option), onSelected: (on) => setState(() { on ? selected.add(option) : selected.remove(option); values[property.id] = selected.toList(); }))]),
        );
      case NotePropertyType.rating:
        final rating = noteNumericValue(value)?.round() ?? 0;
        return InputDecorator(decoration: InputDecoration(labelText: property.name, border: const OutlineInputBorder()), child: Row(children: [for (var i = 1; i <= 5; i++) IconButton(onPressed: () => setState(() => values[property.id] = i), icon: Icon(i <= rating ? Icons.star : Icons.star_border))]));
      case NotePropertyType.progress:
        final progress = noteNumericValue(value)?.clamp(0, 100) ?? 0;
        return InputDecorator(decoration: InputDecoration(labelText: '${property.name} · ${progress.round()}%', border: const OutlineInputBorder()), child: Slider(value: progress.toDouble(), max: 100, divisions: 20, onChanged: (v) => setState(() => values[property.id] = v.round())));
      case NotePropertyType.date:
      case NotePropertyType.dateTime:
        return _DateValueField(label: property.name, includeTime: property.type == NotePropertyType.dateTime, value: value?.toString(), onChanged: (v) => setState(() => values[property.id] = v));
      case NotePropertyType.checklist:
        return _ChecklistField(label: property.name, value: value, onChanged: (v) => values[property.id] = v);
      case NotePropertyType.longText:
        return _TextValueField(label: property.name, initial: value?.toString() ?? '', maxLines: 4, onChanged: (v) => values[property.id] = v);
      case NotePropertyType.number:
      case NotePropertyType.currency:
        return _TextValueField(label: property.name, initial: value?.toString() ?? '', keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (v) => values[property.id] = double.tryParse(v) ?? v);
      case NotePropertyType.url:
        return _TextValueField(label: property.name, initial: value?.toString() ?? '', keyboardType: TextInputType.url, onChanged: (v) => values[property.id] = v);
      case NotePropertyType.text:
        return _TextValueField(label: property.name, initial: value?.toString() ?? '', onChanged: (v) => values[property.id] = v);
    }
  }

  Future<void> _save() async {
    final primary = widget.bundle.primaryProperty;
    if (primary != null && (values[primary.id]?.toString().trim().isEmpty ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${primary.name} is required.')));
      return;
    }
    await ref.read(notePlusRepositoryProvider).saveItemValues(widget.bundle.list.id, widget.item.row.id, values);
    if (mounted) Navigator.pop(context);
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
  late final List<Map<String, Object>> entries = widget.value is List
      ? (widget.value as List).whereType<Map>().map((e) => <String, Object>{'text': e['text']?.toString() ?? '', 'done': e['done'] == true}).toList()
      : <Map<String, Object>>[];
  final add = TextEditingController();
  @override
  void dispose() { add.dispose(); super.dispose(); }
  void changed() => widget.onChanged(entries.map((e) => Map<String, Object>.from(e)).toList());
  @override
  Widget build(BuildContext context) => InputDecorator(
        decoration: InputDecoration(labelText: widget.label, border: const OutlineInputBorder()),
        child: Column(children: [
          for (var i = 0; i < entries.length; i++)
            Row(children: [
              Checkbox(value: entries[i]['done'] == true, onChanged: (v) { setState(() => entries[i]['done'] = v == true); changed(); }),
              Expanded(child: Text(entries[i]['text'].toString())),
              IconButton(onPressed: () { setState(() => entries.removeAt(i)); changed(); }, icon: const Icon(Icons.close, size: 18)),
            ]),
          Row(children: [
            Expanded(child: TextField(controller: add, decoration: const InputDecoration(hintText: 'Add mini-task', border: InputBorder.none), onSubmitted: (_) => _add())),
            IconButton(onPressed: _add, icon: const Icon(Icons.add)),
          ]),
        ]),
      );
  void _add() {
    final text = add.text.trim();
    if (text.isEmpty) return;
    setState(() { entries.add({'text': text, 'done': false}); add.clear(); });
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

IconData _iconFor(String icon) => switch (icon) {
      'shopping' => Icons.shopping_cart_outlined,
      'movie' => Icons.movie_outlined,
      'project' => Icons.account_tree_outlined,
      'book' => Icons.menu_book_outlined,
      'travel' => Icons.flight_takeoff_outlined,
      _ => Icons.table_rows_outlined,
    };

String _formatDate(DateTime value, {bool includeTime = false}) {
  final date = '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  if (!includeTime) return date;
  return '$date ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
