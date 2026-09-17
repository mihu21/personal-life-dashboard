import 'dart:async';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../class_schedule/data/academic_database.dart';
import '../domain/note_plus_types.dart';

class NotePlusRepository {
  NotePlusRepository(this.db, {this._uuid = const Uuid()});

  final AcademicDatabase db;
  final Uuid _uuid;
  final _changes = StreamController<void>.broadcast();

  void dispose() => _changes.close();

  Stream<NotePlusSnapshot> watch() async* {
    yield await load();
    await for (final _ in _changes.stream) {
      yield await load();
    }
  }

  Future<NotePlusSnapshot> load() async {
    final noteRows = await db.customSelect('''
      SELECT id, title, body, pinned, archived, created_at, updated_at
      FROM note_plus_notes
      WHERE deleted_at IS NULL
      ORDER BY pinned DESC, updated_at DESC
    ''').get();
    final listRows = await db.customSelect('''
      SELECT id, name, icon, pinned, archived, created_at, updated_at
      FROM note_plus_lists
      WHERE deleted_at IS NULL
      ORDER BY pinned DESC, updated_at DESC
    ''').get();
    final propertyRows = await db.customSelect('''
      SELECT id, list_id, name, property_type, position, is_primary, configuration
      FROM note_plus_properties
      WHERE deleted_at IS NULL
      ORDER BY position ASC
    ''').get();
    final itemRows = await db.customSelect('''
      SELECT id, list_id, position, created_at, updated_at
      FROM note_plus_items
      WHERE deleted_at IS NULL
      ORDER BY position ASC
    ''').get();
    final valueRows = await db.customSelect(
      'SELECT item_id, property_id, value FROM note_plus_values',
    ).get();

    final notes = [
      for (final row in noteRows)
        NoteRecord(
          id: row.read<String>('id'),
          title: row.read<String>('title'),
          body: row.read<String>('body'),
          pinned: row.read<int>('pinned') != 0,
          archived: row.read<int>('archived') != 0,
          createdAt: DateTime.parse(row.read<String>('created_at')),
          updatedAt: DateTime.parse(row.read<String>('updated_at')),
        ),
    ];
    final lists = [
      for (final row in listRows)
        NoteList(
          id: row.read<String>('id'),
          name: row.read<String>('name'),
          icon: row.read<String>('icon'),
          pinned: row.read<int>('pinned') != 0,
          archived: row.read<int>('archived') != 0,
          createdAt: DateTime.parse(row.read<String>('created_at')),
          updatedAt: DateTime.parse(row.read<String>('updated_at')),
        ),
    ];

    final properties = <String, List<NotePlusProperty>>{};
    for (final row in propertyRows) {
      final rawType = row.read<String>('property_type');
      final type = parseNotePropertyType(rawType);
      final propertyRow = NotePropertyRow(
        id: row.read<String>('id'),
        listId: row.read<String>('list_id'),
        name: row.read<String>('name'),
        propertyType: rawType,
        position: row.read<int>('position'),
        isPrimary: row.read<int>('is_primary') != 0,
        configuration: row.read<String>('configuration'),
      );
      properties.putIfAbsent(propertyRow.listId, () => []).add(
            NotePlusProperty(
              row: propertyRow,
              type: type,
              options: decodeOptions(propertyRow.configuration, type),
            ),
          );
    }

    final values = <String, Map<String, Object?>>{};
    for (final row in valueRows) {
      values.putIfAbsent(row.read<String>('item_id'), () => {})[
          row.read<String>('property_id')] = decodeNoteValue(
        row.data['value'] as String?,
      );
    }

    final items = <String, List<NotePlusItem>>{};
    for (final row in itemRows) {
      final item = NoteItemRow(
        id: row.read<String>('id'),
        listId: row.read<String>('list_id'),
        position: row.read<int>('position'),
        createdAt: DateTime.parse(row.read<String>('created_at')),
        updatedAt: DateTime.parse(row.read<String>('updated_at')),
      );
      items.putIfAbsent(item.listId, () => []).add(
            NotePlusItem(item, values[item.id] ?? const {}),
          );
    }

    return NotePlusSnapshot(
      notes: notes,
      lists: [
        for (final list in lists)
          NotePlusListBundle(
            list: list,
            properties: properties[list.id] ?? const [],
            items: items[list.id] ?? const [],
          ),
      ],
    );
  }

  Future<String> createNote({
    String title = 'Untitled note',
    String body = '',
  }) async {
    final now = DateTime.now().toIso8601String();
    final id = _uuid.v4();
    await db.customStatement(
      '''INSERT INTO note_plus_notes
         (id, title, body, pinned, archived, created_at, updated_at, deleted_at)
         VALUES (?, ?, ?, 0, 0, ?, ?, NULL)''',
      [id, title, body, now, now],
    );
    _notify();
    return id;
  }

  Future<void> saveNote(
    NoteRecord note, {
    String? title,
    String? body,
    bool? pinned,
    bool? archived,
  }) async {
    final nextTitle = (title ?? note.title).trim();
    if (nextTitle.isEmpty) throw ArgumentError('Note title is required.');
    await db.customStatement(
      '''UPDATE note_plus_notes
         SET title = ?, body = ?, pinned = ?, archived = ?, updated_at = ?
         WHERE id = ? AND deleted_at IS NULL''',
      [
        nextTitle,
        body ?? note.body,
        (pinned ?? note.pinned) ? 1 : 0,
        (archived ?? note.archived) ? 1 : 0,
        DateTime.now().toIso8601String(),
        note.id,
      ],
    );
    _notify();
  }

  Future<void> deleteNote(String id) async {
    final now = DateTime.now().toIso8601String();
    await db.customStatement(
      'UPDATE note_plus_notes SET deleted_at = ?, updated_at = ? WHERE id = ?',
      [now, now, id],
    );
    _notify();
  }

  Future<String> createList({
    required String name,
    String icon = 'list',
    List<NotePropertyDraft>? properties,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('List name is required.');
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    final drafts = properties ??
        const [
          NotePropertyDraft(
            name: 'Name',
            type: NotePropertyType.text,
            isPrimary: true,
          ),
        ];
    await db.transaction(() async {
      await db.customStatement(
        '''INSERT INTO note_plus_lists
           (id, name, icon, pinned, archived, created_at, updated_at, deleted_at)
           VALUES (?, ?, ?, 0, 0, ?, ?, NULL)''',
        [id, trimmed, icon, now, now],
      );
      for (var i = 0; i < drafts.length; i++) {
        final draft = drafts[i];
        await db.customStatement(
          '''INSERT INTO note_plus_properties
             (id, list_id, name, property_type, position, is_primary, configuration, created_at, updated_at, deleted_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL)''',
          [
            _uuid.v4(),
            id,
            draft.name,
            draft.type.name,
            i,
            i == 0 || draft.isPrimary ? 1 : 0,
            encodeOptions(draft.options),
            now,
            now,
          ],
        );
      }
    });
    _notify();
    return id;
  }

  Future<void> saveList(
    NoteList list, {
    String? name,
    String? icon,
    bool? pinned,
    bool? archived,
  }) async {
    final nextName = (name ?? list.name).trim();
    if (nextName.isEmpty) throw ArgumentError('List name is required.');
    await db.customStatement(
      '''UPDATE note_plus_lists
         SET name = ?, icon = ?, pinned = ?, archived = ?, updated_at = ?
         WHERE id = ? AND deleted_at IS NULL''',
      [
        nextName,
        icon ?? list.icon,
        (pinned ?? list.pinned) ? 1 : 0,
        (archived ?? list.archived) ? 1 : 0,
        DateTime.now().toIso8601String(),
        list.id,
      ],
    );
    _notify();
  }

  Future<void> deleteList(String id) async {
    final now = DateTime.now().toIso8601String();
    await db.transaction(() async {
      await db.customStatement(
        'UPDATE note_plus_lists SET deleted_at = ?, updated_at = ? WHERE id = ?',
        [now, now, id],
      );
      await db.customStatement(
        'UPDATE note_plus_properties SET deleted_at = ?, updated_at = ? WHERE list_id = ?',
        [now, now, id],
      );
      await db.customStatement(
        'UPDATE note_plus_items SET deleted_at = ?, updated_at = ? WHERE list_id = ?',
        [now, now, id],
      );
    });
    _notify();
  }

  Future<String> addProperty(String listId, NotePropertyDraft draft) async {
    final current = await db.customSelect(
      'SELECT COUNT(*) AS count FROM note_plus_properties WHERE list_id = ? AND deleted_at IS NULL',
      variables: [Variable<String>(listId)],
    ).getSingle();
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    await db.customStatement(
      '''INSERT INTO note_plus_properties
         (id, list_id, name, property_type, position, is_primary, configuration, created_at, updated_at, deleted_at)
         VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?, NULL)''',
      [
        id,
        listId,
        draft.name.trim(),
        draft.type.name,
        current.read<int>('count'),
        encodeOptions(draft.options),
        now,
        now,
      ],
    );
    await _touchList(listId);
    _notify();
    return id;
  }

  Future<void> updateProperty(
    NotePlusProperty property,
    NotePropertyDraft draft,
  ) async {
    await db.customStatement(
      '''UPDATE note_plus_properties
         SET name = ?, property_type = ?, configuration = ?, updated_at = ?
         WHERE id = ? AND deleted_at IS NULL''',
      [
        draft.name.trim(),
        draft.type.name,
        encodeOptions(draft.options),
        DateTime.now().toIso8601String(),
        property.id,
      ],
    );
    await _touchList(property.row.listId);
    _notify();
  }

  Future<void> reorderProperties(
    String listId,
    List<NotePlusProperty> properties,
  ) async {
    await db.transaction(() async {
      for (var i = 0; i < properties.length; i++) {
        await db.customStatement(
          'UPDATE note_plus_properties SET position = ?, updated_at = ? WHERE id = ?',
          [
            i,
            DateTime.now().toIso8601String(),
            properties[i].id,
          ],
        );
      }
      await _touchList(listId);
    });
    _notify();
  }

  Future<void> deleteProperty(NotePlusProperty property) async {
    if (property.isPrimary) {
      throw ArgumentError('The primary Name property cannot be deleted.');
    }
    await db.transaction(() async {
      await db.customStatement(
        'DELETE FROM note_plus_values WHERE property_id = ?',
        [property.id],
      );
      final now = DateTime.now().toIso8601String();
      await db.customStatement(
        'UPDATE note_plus_properties SET deleted_at = ?, updated_at = ? WHERE id = ?',
        [now, now, property.id],
      );
      await _touchList(property.row.listId);
    });
    _notify();
  }

  Future<String> createItem(String listId) async {
    final current = await db.customSelect(
      'SELECT COUNT(*) AS count FROM note_plus_items WHERE list_id = ? AND deleted_at IS NULL',
      variables: [Variable<String>(listId)],
    ).getSingle();
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    await db.customStatement(
      '''INSERT INTO note_plus_items
         (id, list_id, position, created_at, updated_at, deleted_at)
         VALUES (?, ?, ?, ?, ?, NULL)''',
      [
        id,
        listId,
        current.read<int>('count'),
        now,
        now,
      ],
    );
    await _touchList(listId);
    _notify();
    return id;
  }

  Future<void> saveItemValues(
    String listId,
    String itemId,
    Map<String, Object?> values,
  ) async {
    final item = await db.customSelect(
      'SELECT list_id, deleted_at FROM note_plus_items WHERE id = ?',
      variables: [Variable<String>(itemId)],
    ).getSingleOrNull();
    if (item == null ||
        item.read<String>('list_id') != listId ||
        item.data['deleted_at'] != null) {
      throw StateError('List item no longer exists.');
    }
    await db.transaction(() async {
      for (final entry in values.entries) {
        await db.customStatement(
          '''INSERT INTO note_plus_values(item_id, property_id, value)
             VALUES (?, ?, ?)
             ON CONFLICT(item_id, property_id) DO UPDATE SET value = excluded.value''',
          [
            itemId,
            entry.key,
            encodeNoteValue(entry.value),
          ],
        );
      }
      await db.customStatement(
        'UPDATE note_plus_items SET updated_at = ? WHERE id = ?',
        [DateTime.now().toIso8601String(), itemId],
      );
      await _touchList(listId);
    });
    _notify();
  }

  Future<void> deleteItem(String listId, String itemId) async {
    await db.transaction(() async {
      await db.customStatement(
        'DELETE FROM note_plus_values WHERE item_id = ?',
        [itemId],
      );
      final now = DateTime.now().toIso8601String();
      await db.customStatement(
        'UPDATE note_plus_items SET deleted_at = ?, updated_at = ? WHERE id = ?',
        [now, now, itemId],
      );
      await _touchList(listId);
    });
    _notify();
  }

  Future<void> _touchList(String id) => db.customStatement(
        'UPDATE note_plus_lists SET updated_at = ? WHERE id = ?',
        [DateTime.now().toIso8601String(), id],
      );

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }
}

class NotePropertyDraft {
  const NotePropertyDraft({
    required this.name,
    required this.type,
    this.options = const [],
    this.isPrimary = false,
  });
  final String name;
  final NotePropertyType type;
  final List<String> options;
  final bool isPrimary;
}

class NoteListTemplate {
  const NoteListTemplate(this.name, this.icon, this.properties);
  final String name;
  final String icon;
  final List<NotePropertyDraft> properties;
}

const noteListTemplates = <NoteListTemplate>[
  NoteListTemplate('Shopping', 'shopping', [
    NotePropertyDraft(
      name: 'Item',
      type: NotePropertyType.text,
      isPrimary: true,
    ),
    NotePropertyDraft(name: 'Quantity', type: NotePropertyType.number),
    NotePropertyDraft(name: 'Price', type: NotePropertyType.currency),
    NotePropertyDraft(
      name: 'Category',
      type: NotePropertyType.select,
      options: ['Food', 'Household', 'Personal', 'Other'],
    ),
    NotePropertyDraft(name: 'Store', type: NotePropertyType.text),
    NotePropertyDraft(name: 'Bought', type: NotePropertyType.checkbox),
  ]),
  NoteListTemplate('Movies', 'movie', [
    NotePropertyDraft(
      name: 'Movie',
      type: NotePropertyType.text,
      isPrimary: true,
    ),
    NotePropertyDraft(
      name: 'Genre',
      type: NotePropertyType.multiSelect,
      options: ['Action', 'Comedy', 'Drama', 'Sci-Fi', 'Thriller'],
    ),
    NotePropertyDraft(name: 'Duration', type: NotePropertyType.number),
    NotePropertyDraft(name: 'Rating', type: NotePropertyType.rating),
    NotePropertyDraft(name: 'Watched', type: NotePropertyType.checkbox),
  ]),
  NoteListTemplate('Projects', 'project', [
    NotePropertyDraft(
      name: 'Project',
      type: NotePropertyType.text,
      isPrimary: true,
    ),
    NotePropertyDraft(
      name: 'Status',
      type: NotePropertyType.status,
      options: ['Planned', 'Doing', 'Done'],
    ),
    NotePropertyDraft(name: 'Deadline', type: NotePropertyType.date),
    NotePropertyDraft(name: 'Mini tasks', type: NotePropertyType.checklist),
    NotePropertyDraft(name: 'Progress', type: NotePropertyType.progress),
  ]),
  NoteListTemplate('Reading', 'book', [
    NotePropertyDraft(
      name: 'Title',
      type: NotePropertyType.text,
      isPrimary: true,
    ),
    NotePropertyDraft(name: 'Author', type: NotePropertyType.text),
    NotePropertyDraft(
      name: 'Category',
      type: NotePropertyType.select,
      options: ['Fiction', 'Non-fiction', 'Study', 'Other'],
    ),
    NotePropertyDraft(name: 'Rating', type: NotePropertyType.rating),
    NotePropertyDraft(name: 'Finished', type: NotePropertyType.checkbox),
  ]),
  NoteListTemplate('Travel', 'travel', [
    NotePropertyDraft(
      name: 'Place',
      type: NotePropertyType.text,
      isPrimary: true,
    ),
    NotePropertyDraft(name: 'Date', type: NotePropertyType.date),
    NotePropertyDraft(
      name: 'Category',
      type: NotePropertyType.select,
      options: ['Visit', 'Food', 'Stay', 'Transport'],
    ),
    NotePropertyDraft(name: 'Link', type: NotePropertyType.url),
    NotePropertyDraft(name: 'Done', type: NotePropertyType.checkbox),
  ]),
];
