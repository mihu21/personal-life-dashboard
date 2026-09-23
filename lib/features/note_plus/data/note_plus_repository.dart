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
    await _migrateLegacyStatusProperties();
    await _seedMissingProgressDefaults();
    final noteRows = await db.customSelect('''
      SELECT n.id, n.title, n.body, n.pinned, n.archived, n.created_at, n.updated_at,
             COALESCE(o.position, 2147483647) AS entry_position
      FROM note_plus_notes n
      LEFT JOIN note_plus_entry_order o
        ON o.entry_type = 'note' AND o.entry_id = n.id
      WHERE n.deleted_at IS NULL
      ORDER BY n.pinned DESC, entry_position ASC, n.updated_at DESC
    ''').get();
    final listRows = await db.customSelect('''
      SELECT l.id, l.name, l.icon, l.pinned, l.archived, l.created_at, l.updated_at,
             COALESCE(o.position, 2147483647) AS entry_position
      FROM note_plus_lists l
      LEFT JOIN note_plus_entry_order o
        ON o.entry_type = 'list' AND o.entry_id = l.id
      WHERE l.deleted_at IS NULL
      ORDER BY l.pinned DESC, entry_position ASC, l.updated_at DESC
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
          position: row.read<int>('entry_position'),
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
          position: row.read<int>('entry_position'),
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

  Future<void> _migrateLegacyStatusProperties() async {
    final legacyRows = await db.customSelect("""
      SELECT id, configuration
      FROM note_plus_properties
      WHERE property_type = 'status' AND deleted_at IS NULL
    """).get();
    if (legacyRows.isEmpty) return;

    final now = DateTime.now().toIso8601String();
    await db.transaction(() async {
      for (final row in legacyRows) {
        final configuration = row.read<String>('configuration');
        final existingOptions = decodeOptions(
          configuration,
          NotePropertyType.status,
        );
        final options = existingOptions.isEmpty
            ? const ['Planned', 'Doing', 'Done']
            : existingOptions;
        await db.customStatement(
          """UPDATE note_plus_properties
             SET property_type = 'select', configuration = ?, updated_at = ?
             WHERE id = ?""",
          [encodeOptions(options), now, row.read<String>('id')],
        );
      }
    });
  }

  Future<String> createNote({
    String title = 'Untitled note',
    String body = '',
  }) async {
    final now = DateTime.now().toIso8601String();
    final id = _uuid.v4();
    final position = await _nextEntryPosition();
    await db.transaction(() async {
      await db.customStatement(
        '''INSERT INTO note_plus_notes
           (id, title, body, pinned, archived, created_at, updated_at, deleted_at)
           VALUES (?, ?, ?, 0, 0, ?, ?, NULL)''',
        [id, title, body, now, now],
      );
      await _insertEntryOrder('note', id, position);
    });
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
    final requestedTitle = (title ?? note.title).trim();
    final nextTitle = requestedTitle.isEmpty ? 'Untitled note' : requestedTitle;
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
    await db.transaction(() async {
      await db.customStatement(
        'UPDATE note_plus_notes SET deleted_at = ?, updated_at = ? WHERE id = ?',
        [now, now, id],
      );
      await db.customStatement(
        "DELETE FROM note_plus_entry_order WHERE entry_type = 'note' AND entry_id = ?",
        [id],
      );
    });
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
    final position = await _nextEntryPosition();
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
      await _insertEntryOrder('list', id, position);
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
            encodePropertyConfiguration(
              draft.options,
              linkedChecklistId: draft.linkedChecklistId,
            ),
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
      await db.customStatement(
        "DELETE FROM note_plus_entry_order WHERE entry_type = 'list' AND entry_id = ?",
        [id],
      );
    });
    _notify();
  }

  Future<String> addProperty(String listId, NotePropertyDraft draft) async {
    final current = await db.customSelect(
      'SELECT COUNT(*) AS count FROM note_plus_properties WHERE list_id = ? AND deleted_at IS NULL',
      variables: [Variable<String>(listId)],
    ).getSingle();
    final name = await _resolvePropertyName(listId, draft);
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    await db.transaction(() async {
      await db.customStatement(
        '''INSERT INTO note_plus_properties
           (id, list_id, name, property_type, position, is_primary, configuration, created_at, updated_at, deleted_at)
           VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?, NULL)''',
        [
          id,
          listId,
          name,
          draft.type.name,
          current.read<int>('count'),
          encodePropertyConfiguration(
            draft.options,
            linkedChecklistId: draft.linkedChecklistId,
          ),
          now,
          now,
        ],
      );
      if (draft.type == NotePropertyType.progress) {
        await _seedProgressDefaults(listId, id);
        if (draft.linkedChecklistId != null) {
          await _syncLinkedProgressForList(listId);
        }
      }
      await _touchList(listId);
    });
    _notify();
    return id;
  }

  Future<void> updateProperty(
    NotePlusProperty property,
    NotePropertyDraft draft,
  ) async {
    final name = await _resolvePropertyName(
      property.row.listId,
      draft,
      excludeId: property.id,
    );
    await db.transaction(() async {
      await db.customStatement(
        '''UPDATE note_plus_properties
           SET name = ?, property_type = ?, configuration = ?, updated_at = ?
           WHERE id = ? AND deleted_at IS NULL''',
        [
          name,
          draft.type.name,
          encodePropertyConfiguration(
            draft.options,
            linkedChecklistId: draft.linkedChecklistId,
          ),
          DateTime.now().toIso8601String(),
          property.id,
        ],
      );
      if (draft.type == NotePropertyType.progress) {
        await _seedProgressDefaults(property.row.listId, property.id);
        if (draft.linkedChecklistId != null) {
          await _syncLinkedProgressForList(property.row.listId);
        }
      }
      await _touchList(property.row.listId);
    });
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
      if (property.type == NotePropertyType.checklist) {
        final progressRows = await db.customSelect(
          '''SELECT id, configuration
             FROM note_plus_properties
             WHERE list_id = ?
               AND property_type = 'progress'
               AND deleted_at IS NULL''',
          variables: [Variable<String>(property.row.listId)],
        ).get();
        for (final row in progressRows) {
          final configuration = row.read<String>('configuration');
          if (decodeLinkedChecklistId(configuration) != property.id) continue;
          await db.customStatement(
            '''UPDATE note_plus_properties
               SET configuration = ?, updated_at = ?
               WHERE id = ?''',
            [
              encodePropertyConfiguration(
                decodeOptions(configuration, NotePropertyType.progress),
              ),
              DateTime.now().toIso8601String(),
              row.read<String>('id'),
            ],
          );
        }
      }
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

  Future<String> createItem(
    String listId, {
    Map<String, Object?> values = const {},
  }) async {
    final current = await db.customSelect(
      '''SELECT COALESCE(MAX(position), -1) + 1 AS next_position
         FROM note_plus_items
         WHERE list_id = ? AND deleted_at IS NULL''',
      variables: [Variable<String>(listId)],
    ).getSingle();
    final progressRows = await db.customSelect(
      '''SELECT id, configuration FROM note_plus_properties
         WHERE list_id = ? AND property_type = 'progress' AND deleted_at IS NULL''',
      variables: [Variable<String>(listId)],
    ).get();
    final effectiveValues = <String, Object?>{...values};
    for (final row in progressRows) {
      final propertyId = row.read<String>('id');
      effectiveValues[propertyId] ??= 0;
    }

    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    await db.transaction(() async {
      await db.customStatement(
        '''INSERT INTO note_plus_items
           (id, list_id, position, created_at, updated_at, deleted_at)
           VALUES (?, ?, ?, ?, ?, NULL)''',
        [
          id,
          listId,
          current.read<int>('next_position'),
          now,
          now,
        ],
      );
      for (final entry in effectiveValues.entries) {
        await db.customStatement(
          'INSERT INTO note_plus_values(item_id, property_id, value) VALUES (?, ?, ?)',
          [id, entry.key, encodeNoteValue(entry.value)],
        );
      }
      await _syncLinkedProgressForItem(
        listId,
        id,
        overrides: effectiveValues,
      );
      await _touchList(listId);
    });
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
      await _syncLinkedProgressForItem(
        listId,
        itemId,
        overrides: values,
      );
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

  Future<void> reorderItems(
    String listId,
    List<NotePlusItem> items,
  ) async {
    await db.transaction(() async {
      for (var i = 0; i < items.length; i++) {
        await db.customStatement(
          '''UPDATE note_plus_items
             SET position = ?, updated_at = ?
             WHERE id = ? AND list_id = ? AND deleted_at IS NULL''',
          [i, DateTime.now().toIso8601String(), items[i].row.id, listId],
        );
      }
      await _touchList(listId);
    });
    _notify();
  }

  Future<void> reorderEntries(List<NotePlusEntry> entries) async {
    await db.transaction(() async {
      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        await db.customStatement(
          '''INSERT INTO note_plus_entry_order(entry_type, entry_id, position)
             VALUES (?, ?, ?)
             ON CONFLICT(entry_type, entry_id)
             DO UPDATE SET position = excluded.position''',
          [entry.kind.name, entry.id, i],
        );
      }
    });
    _notify();
  }

  Future<int> _nextEntryPosition() async {
    final row = await db.customSelect(
      'SELECT COALESCE(MAX(position), -1) + 1 AS next_position FROM note_plus_entry_order',
    ).getSingle();
    return row.read<int>('next_position');
  }

  Future<void> _insertEntryOrder(String type, String id, int position) =>
      db.customStatement(
        '''INSERT INTO note_plus_entry_order(entry_type, entry_id, position)
           VALUES (?, ?, ?)''',
        [type, id, position],
      );

  Future<String> _resolvePropertyName(
    String listId,
    NotePropertyDraft draft, {
    String? excludeId,
  }) async {
    final rows = await db.customSelect(
      '''SELECT id, name, property_type
         FROM note_plus_properties
         WHERE list_id = ? AND deleted_at IS NULL''',
      variables: [Variable<String>(listId)],
    ).get();

    if (draft.type == NotePropertyType.checkbox) {
      final excludedWasCheckbox = excludeId != null &&
          rows.any(
            (row) =>
                row.read<String>('id') == excludeId &&
                row.read<String>('property_type') ==
                    NotePropertyType.checkbox.name,
          );
      final hasOtherCheckbox = rows.any(
        (row) =>
            row.read<String>('property_type') == NotePropertyType.checkbox.name &&
            row.read<String>('id') != excludeId,
      );
      if (hasOtherCheckbox && !excludedWasCheckbox) {
        throw StateError('A list can only have one Checkbox property.');
      }
      return 'Checkbox';
    }

    final requested = draft.name.trim();
    final base = requested.isEmpty ? draft.type.label : requested;
    final used = rows
        .where((row) => row.read<String>('id') != excludeId)
        .map((row) => row.read<String>('name').trim().toLowerCase())
        .toSet();
    if (!used.contains(base.toLowerCase())) return base;

    var suffix = 2;
    while (used.contains('$base $suffix'.toLowerCase())) {
      suffix++;
    }
    return '$base $suffix';
  }

  Future<void> _syncLinkedProgressForList(String listId) async {
    final items = await db.customSelect(
      '''SELECT id FROM note_plus_items
         WHERE list_id = ? AND deleted_at IS NULL''',
      variables: [Variable<String>(listId)],
    ).get();
    for (final item in items) {
      await _syncLinkedProgressForItem(listId, item.read<String>('id'));
    }
  }

  Future<void> _syncLinkedProgressForItem(
    String listId,
    String itemId, {
    Map<String, Object?> overrides = const {},
  }) async {
    final progressRows = await db.customSelect(
      '''SELECT id, configuration
         FROM note_plus_properties
         WHERE list_id = ?
           AND property_type = 'progress'
           AND deleted_at IS NULL''',
      variables: [Variable<String>(listId)],
    ).get();

    for (final progressRow in progressRows) {
      final linkedChecklistId = decodeLinkedChecklistId(
        progressRow.read<String>('configuration'),
      );
      if (linkedChecklistId == null) continue;

      Object? checklistValue;
      if (overrides.containsKey(linkedChecklistId)) {
        checklistValue = overrides[linkedChecklistId];
      } else {
        final row = await db.customSelect(
          '''SELECT value FROM note_plus_values
             WHERE item_id = ? AND property_id = ?''',
          variables: [
            Variable<String>(itemId),
            Variable<String>(linkedChecklistId),
          ],
        ).getSingleOrNull();
        final rawValue = row?.data['value'] as String?;
        checklistValue = decodeNoteValue(rawValue);
      }

      final progress = _checklistProgress(checklistValue);
      await db.customStatement(
        '''INSERT INTO note_plus_values(item_id, property_id, value)
           VALUES (?, ?, ?)
           ON CONFLICT(item_id, property_id)
           DO UPDATE SET value = excluded.value''',
        [
          itemId,
          progressRow.read<String>('id'),
          encodeNoteValue(progress),
        ],
      );
    }
  }

  double _checklistProgress(Object? value) {
    if (value is! List || value.isEmpty) return 0;
    var total = 0;
    var done = 0;
    for (final entry in value) {
      if (entry is! Map) continue;
      final text = entry['text']?.toString().trim() ?? '';
      if (text.isEmpty) continue;
      total++;
      if (entry['done'] == true) done++;
    }
    if (total == 0) return 0;
    return done / total * 100;
  }

  Future<void> _seedMissingProgressDefaults() async {
    await db.customStatement(
      '''INSERT INTO note_plus_values(item_id, property_id, value)
         SELECT i.id, p.id, ?
         FROM note_plus_items i
         JOIN note_plus_properties p ON p.list_id = i.list_id
         WHERE i.deleted_at IS NULL
           AND p.deleted_at IS NULL
           AND p.property_type = 'progress'
           AND NOT EXISTS (
             SELECT 1 FROM note_plus_values v
             WHERE v.item_id = i.id AND v.property_id = p.id
           )''',
      [encodeNoteValue(0)],
    );
  }

  Future<void> _seedProgressDefaults(String listId, String propertyId) async {
    await db.customStatement(
      '''INSERT INTO note_plus_values(item_id, property_id, value)
         SELECT i.id, ?, ?
         FROM note_plus_items i
         WHERE i.list_id = ?
           AND i.deleted_at IS NULL
           AND NOT EXISTS (
             SELECT 1 FROM note_plus_values v
             WHERE v.item_id = i.id AND v.property_id = ?
           )''',
      [propertyId, encodeNoteValue(0), listId, propertyId],
    );
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
    this.linkedChecklistId,
  });
  final String name;
  final NotePropertyType type;
  final List<String> options;
  final bool isPrimary;
  final String? linkedChecklistId;
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
    NotePropertyDraft(name: 'Checkbox', type: NotePropertyType.checkbox),
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
    NotePropertyDraft(name: 'Checkbox', type: NotePropertyType.checkbox),
  ]),
  NoteListTemplate('Projects', 'project', [
    NotePropertyDraft(
      name: 'Project',
      type: NotePropertyType.text,
      isPrimary: true,
    ),
    NotePropertyDraft(
      name: 'Status',
      type: NotePropertyType.select,
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
    NotePropertyDraft(name: 'Checkbox', type: NotePropertyType.checkbox),
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
    NotePropertyDraft(name: 'Checkbox', type: NotePropertyType.checkbox),
  ]),
];
