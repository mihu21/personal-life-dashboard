import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../class_schedule/providers/academic_providers.dart';
import '../data/eeclass_client.dart';
import '../data/eeclass_parser.dart';
import '../data/elearn_client.dart';
import '../data/elearn_parser.dart';
import '../data/lms_session_service.dart';
import '../data/lms_task_sync_service.dart';
import '../domain/lms_types.dart';

final lmsSessionServiceProvider = Provider<LmsSessionService>((ref) {
  final service = LmsSessionService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final eeclassParserProvider = Provider<EeclassParser>((ref) => EeclassParser());
final elearnParserProvider = Provider<ElearnParser>((ref) => ElearnParser());

final eeclassClientProvider = Provider<EeclassClient>(
  (ref) => EeclassClient(
    ref.watch(lmsSessionServiceProvider),
    ref.watch(eeclassParserProvider),
  ),
);

final elearnClientProvider = Provider<ElearnClient>(
  (ref) => ElearnClient(
    ref.watch(lmsSessionServiceProvider),
    ref.watch(elearnParserProvider),
  ),
);

final lmsTaskSyncServiceProvider = Provider<LmsTaskSyncService>(
  (ref) => LmsTaskSyncService(ref.watch(academicDatabaseProvider)),
);

final ignoredLmsTasksProvider = FutureProvider<List<LmsIgnoredTask>>(
  (ref) => ref.watch(lmsTaskSyncServiceProvider).loadIgnoredTasks(),
);

class EeclassConnectionNotifier extends AsyncNotifier<LmsConnectionState> {
  LmsConnectionState? _stateBeforeConnect;

  @override
  Future<LmsConnectionState> build() async {
    final preview = await ref
        .watch(lmsSessionServiceProvider)
        .loadPreview(LmsProvider.eeclass);
    return LmsConnectionState(
      status: preview == null
          ? LmsConnectionStatus.disconnected
          : LmsConnectionStatus.authenticated,
      lastSuccessfulPreview: preview,
    );
  }

  LmsConnectionState get _current =>
      state.value ??
      const LmsConnectionState(status: LmsConnectionStatus.disconnected);

  void beginConnect() {
    _stateBeforeConnect = _current;
    state = AsyncData(
      _current.copyWith(
        status: LmsConnectionStatus.connecting,
        clearMessage: true,
      ),
    );
  }

  void cancelConnect() {
    final previous = _stateBeforeConnect;
    _stateBeforeConnect = null;
    state = AsyncData(
      previous ??
          const LmsConnectionState(status: LmsConnectionStatus.disconnected),
    );
  }

  Future<void> acceptConnectedPreview(LmsPreviewSnapshot preview) async {
    _stateBeforeConnect = null;
    await ref
        .read(lmsSessionServiceProvider)
        .savePreview(LmsProvider.eeclass, preview);
    await _applyPreviewToTasks(preview);
  }

  Future<void> sync() async {
    final previous = _current;
    state = AsyncData(
      previous.copyWith(
        status: LmsConnectionStatus.syncing,
        clearMessage: true,
      ),
    );
    try {
      final preview = await ref.read(eeclassClientProvider).fetchRecentEvents();
      await ref
          .read(lmsSessionServiceProvider)
          .savePreview(LmsProvider.eeclass, preview);
      await _applyPreviewToTasks(preview);
    } on LmsSessionExpiredException catch (error) {
      state = AsyncData(
        previous.copyWith(
          status: LmsConnectionStatus.sessionExpired,
          message: error.message,
        ),
      );
    } on LmsNetworkException catch (error) {
      state = AsyncData(
        previous.copyWith(
          status: LmsConnectionStatus.networkError,
          message: error.message,
        ),
      );
    } on LmsParseException catch (error) {
      state = AsyncData(
        previous.copyWith(
          status: LmsConnectionStatus.parseError,
          message: error.message,
        ),
      );
    } on LmsUnsupportedException catch (error) {
      state = AsyncData(
        previous.copyWith(
          status: LmsConnectionStatus.unsupported,
          message: error.message,
        ),
      );
    } on Object catch (error) {
      state = AsyncData(
        previous.copyWith(
          status: LmsConnectionStatus.networkError,
          message: 'Could not sync eeclass: $error',
        ),
      );
    }
  }

  Future<void> _applyPreviewToTasks(LmsPreviewSnapshot preview) async {
    try {
      final result = await ref
          .read(lmsTaskSyncServiceProvider)
          .syncPreview(preview);
      ref.invalidate(ignoredLmsTasksProvider);
      state = AsyncData(
        LmsConnectionState(
          status: LmsConnectionStatus.success,
          lastSuccessfulPreview: preview,
          message: result.message,
        ),
      );
    } on LmsTaskSyncException catch (error) {
      state = AsyncData(
        LmsConnectionState(
          status: LmsConnectionStatus.taskSyncError,
          lastSuccessfulPreview: preview,
          message: error.message,
        ),
      );
    } on Object catch (error) {
      state = AsyncData(
        LmsConnectionState(
          status: LmsConnectionStatus.taskSyncError,
          lastSuccessfulPreview: preview,
          message:
              'Assignments were detected, but Tasks could not be updated: $error',
        ),
      );
    }
  }

  Future<void> disconnect() async {
    final previous = _current;
    state = AsyncData(
      previous.copyWith(
        status: LmsConnectionStatus.syncing,
        message: 'Disconnecting…',
      ),
    );
    try {
      await ref
          .read(lmsSessionServiceProvider)
          .disconnect(LmsProvider.eeclass);
      state = const AsyncData(
        LmsConnectionState(status: LmsConnectionStatus.disconnected),
      );
    } on LmsUnsupportedException catch (error) {
      state = AsyncData(
        previous.copyWith(
          status: LmsConnectionStatus.unsupported,
          message: error.message,
        ),
      );
    } on Object catch (error) {
      state = AsyncData(
        previous.copyWith(
          status: LmsConnectionStatus.networkError,
          message: 'Could not disconnect eeclass: $error',
        ),
      );
    }
  }
}

final eeclassConnectionProvider =
    AsyncNotifierProvider<EeclassConnectionNotifier, LmsConnectionState>(
      EeclassConnectionNotifier.new,
    );

class ElearnConnectionNotifier extends AsyncNotifier<LmsConnectionState> {
  LmsConnectionState? _stateBeforeConnect;

  @override
  Future<LmsConnectionState> build() async {
    final preview = await ref
        .watch(lmsSessionServiceProvider)
        .loadPreview(LmsProvider.elearn);
    return LmsConnectionState(
      status: preview == null
          ? LmsConnectionStatus.disconnected
          : LmsConnectionStatus.authenticated,
      lastSuccessfulPreview: preview,
    );
  }

  LmsConnectionState get _current =>
      state.value ??
      const LmsConnectionState(status: LmsConnectionStatus.disconnected);

  void beginConnect() {
    _stateBeforeConnect = _current;
    state = AsyncData(
      _current.copyWith(
        status: LmsConnectionStatus.connecting,
        clearMessage: true,
      ),
    );
  }

  void cancelConnect() {
    final previous = _stateBeforeConnect;
    _stateBeforeConnect = null;
    state = AsyncData(
      previous ??
          const LmsConnectionState(status: LmsConnectionStatus.disconnected),
    );
  }

  Future<void> acceptConnectedPreview(LmsPreviewSnapshot preview) async {
    _stateBeforeConnect = null;
    await ref
        .read(lmsSessionServiceProvider)
        .savePreview(LmsProvider.elearn, preview);
    await _applyPreviewToTasks(preview);
  }

  Future<void> sync() async {
    final previous = _current;
    state = AsyncData(
      previous.copyWith(
        status: LmsConnectionStatus.syncing,
        clearMessage: true,
      ),
    );
    try {
      final preview = await ref.read(elearnClientProvider).fetchAssignments();
      await ref
          .read(lmsSessionServiceProvider)
          .savePreview(LmsProvider.elearn, preview);
      await _applyPreviewToTasks(preview);
    } on LmsSessionExpiredException catch (error) {
      state = AsyncData(
        previous.copyWith(
          status: LmsConnectionStatus.sessionExpired,
          message: error.message,
        ),
      );
    } on LmsNetworkException catch (error) {
      state = AsyncData(
        previous.copyWith(
          status: LmsConnectionStatus.networkError,
          message: error.message,
        ),
      );
    } on LmsParseException catch (error) {
      state = AsyncData(
        previous.copyWith(
          status: LmsConnectionStatus.parseError,
          message: error.message,
        ),
      );
    } on LmsUnsupportedException catch (error) {
      state = AsyncData(
        previous.copyWith(
          status: LmsConnectionStatus.unsupported,
          message: error.message,
        ),
      );
    } on Object catch (error) {
      state = AsyncData(
        previous.copyWith(
          status: LmsConnectionStatus.networkError,
          message: 'Could not sync eLearn: $error',
        ),
      );
    }
  }

  Future<void> _applyPreviewToTasks(LmsPreviewSnapshot preview) async {
    try {
      final result = await ref
          .read(lmsTaskSyncServiceProvider)
          .syncPreview(preview);
      ref.invalidate(ignoredLmsTasksProvider);
      state = AsyncData(
        LmsConnectionState(
          status: LmsConnectionStatus.success,
          lastSuccessfulPreview: preview,
          message: result.message,
        ),
      );
    } on LmsTaskSyncException catch (error) {
      state = AsyncData(
        LmsConnectionState(
          status: LmsConnectionStatus.taskSyncError,
          lastSuccessfulPreview: preview,
          message: error.message,
        ),
      );
    } on Object catch (error) {
      state = AsyncData(
        LmsConnectionState(
          status: LmsConnectionStatus.taskSyncError,
          lastSuccessfulPreview: preview,
          message:
              'Assignments were detected, but Tasks could not be updated: $error',
        ),
      );
    }
  }

  Future<void> disconnect() async {
    final previous = _current;
    state = AsyncData(
      previous.copyWith(
        status: LmsConnectionStatus.syncing,
        message: 'Disconnecting…',
      ),
    );
    try {
      await ref
          .read(lmsSessionServiceProvider)
          .disconnect(LmsProvider.elearn);
      state = const AsyncData(
        LmsConnectionState(status: LmsConnectionStatus.disconnected),
      );
    } on LmsUnsupportedException catch (error) {
      state = AsyncData(
        previous.copyWith(
          status: LmsConnectionStatus.unsupported,
          message: error.message,
        ),
      );
    } on Object catch (error) {
      state = AsyncData(
        previous.copyWith(
          status: LmsConnectionStatus.networkError,
          message: 'Could not disconnect eLearn: $error',
        ),
      );
    }
  }
}

final elearnConnectionProvider =
    AsyncNotifierProvider<ElearnConnectionNotifier, LmsConnectionState>(
      ElearnConnectionNotifier.new,
    );
