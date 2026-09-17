enum LmsProvider { eeclass, elearn }

enum LmsResourceType { homework, unknown }

enum LmsDuePrecision { dateTime, dateOnly }

enum LmsConnectionStatus {
  disconnected,
  connecting,
  authenticated,
  syncing,
  success,
  taskSyncError,
  sessionExpired,
  networkError,
  parseError,
  unsupported,
}

extension LmsProviderLabel on LmsProvider {
  String get displayName => switch (this) {
    LmsProvider.eeclass => 'eeclass',
    LmsProvider.elearn => 'eLearn',
  };
}

class LmsItem {
  const LmsItem({
    required this.provider,
    required this.resourceType,
    required this.externalId,
    required this.title,
    required this.courseName,
    required this.dueAt,
    required this.duePrecision,
    required this.url,
    this.courseId,
    this.description = '',
  });

  final LmsProvider provider;
  final LmsResourceType resourceType;
  final String externalId;
  final String title;
  final String courseName;
  final String? courseId;
  final DateTime dueAt;
  final LmsDuePrecision duePrecision;
  final String url;
  final String description;

  Map<String, Object?> toJson() => {
    'provider': provider.name,
    'resourceType': resourceType.name,
    'externalId': externalId,
    'title': title,
    'courseName': courseName,
    'courseId': courseId,
    'dueAt': dueAt.toIso8601String(),
    'duePrecision': duePrecision.name,
    'url': url,
    'description': description,
  };

  factory LmsItem.fromJson(Map<String, Object?> json) => LmsItem(
    provider: LmsProvider.values.byName(json['provider']! as String),
    resourceType: LmsResourceType.values.byName(
      json['resourceType']! as String,
    ),
    externalId: json['externalId']! as String,
    title: json['title']! as String,
    courseName: json['courseName']! as String,
    courseId: json['courseId'] as String?,
    dueAt: DateTime.parse(json['dueAt']! as String),
    duePrecision: LmsDuePrecision.values.byName(
      json['duePrecision']! as String,
    ),
    url: json['url']! as String,
    description: json['description'] as String? ?? '',
  );
}

class LmsPreviewSnapshot {
  const LmsPreviewSnapshot({
    required this.items,
    required this.syncedAt,
    this.accountScope = 'legacy',
    this.ignoredUnknownEvents = 0,
  });

  final List<LmsItem> items;
  final DateTime syncedAt;
  final String accountScope;
  final int ignoredUnknownEvents;

  LmsProvider? get provider => items.isEmpty ? null : items.first.provider;

  Map<String, Object?> toJson() => {
    'items': [for (final item in items) item.toJson()],
    'syncedAt': syncedAt.toIso8601String(),
    'accountScope': accountScope,
    'ignoredUnknownEvents': ignoredUnknownEvents,
  };

  factory LmsPreviewSnapshot.fromJson(Map<String, Object?> json) {
    final rawItems = json['items'];
    if (rawItems is! List) {
      throw const FormatException('LMS preview items are missing.');
    }
    return LmsPreviewSnapshot(
      items: [
        for (final item in rawItems)
          LmsItem.fromJson((item as Map).cast<String, Object?>()),
      ],
      syncedAt: DateTime.parse(json['syncedAt']! as String),
      accountScope: json['accountScope'] as String? ?? 'legacy',
      ignoredUnknownEvents: json['ignoredUnknownEvents'] as int? ?? 0,
    );
  }
}

class LmsTaskSyncResult {
  const LmsTaskSyncResult({
    required this.created,
    required this.updated,
    required this.unchanged,
    required this.restored,
    required this.suppressed,
    required this.preservedOverrides,
  });

  final int created;
  final int updated;
  final int unchanged;
  final int restored;
  final int suppressed;
  final int preservedOverrides;

  int get processed => created + updated + unchanged + restored + suppressed;

  String get message {
    if (processed == 0) return 'No LMS assignments needed task changes.';
    final parts = <String>[];
    if (created > 0) parts.add('$created created');
    if (updated > 0) parts.add('$updated updated');
    if (unchanged > 0) parts.add('$unchanged unchanged');
    if (restored > 0) parts.add('$restored restored');
    if (suppressed > 0) {
      parts.add(
        '$suppressed deleted task${suppressed == 1 ? '' : 's'} kept deleted',
      );
    }
    var text = 'Tasks synced: ${parts.join(', ')}.';
    if (preservedOverrides > 0) {
      text += ' Preserved $preservedOverrides manual field override(s).';
    }
    return text;
  }
}

class LmsConnectionState {
  const LmsConnectionState({
    required this.status,
    this.lastSuccessfulPreview,
    this.message,
  });

  final LmsConnectionStatus status;
  final LmsPreviewSnapshot? lastSuccessfulPreview;
  final String? message;

  LmsConnectionState copyWith({
    LmsConnectionStatus? status,
    LmsPreviewSnapshot? lastSuccessfulPreview,
    bool clearPreview = false,
    String? message,
    bool clearMessage = false,
  }) => LmsConnectionState(
    status: status ?? this.status,
    lastSuccessfulPreview: clearPreview
        ? null
        : lastSuccessfulPreview ?? this.lastSuccessfulPreview,
    message: clearMessage ? null : message ?? this.message,
  );
}

class LmsSessionExpiredException implements Exception {
  const LmsSessionExpiredException([
    this.message = 'Your LMS session has expired. Sign in again.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class LmsNetworkException implements Exception {
  const LmsNetworkException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LmsParseException implements Exception {
  const LmsParseException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LmsUnsupportedException implements Exception {
  const LmsUnsupportedException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LmsTaskSyncException implements Exception {
  const LmsTaskSyncException(this.message);

  final String message;

  @override
  String toString() => message;
}
