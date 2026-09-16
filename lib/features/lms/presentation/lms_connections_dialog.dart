import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/eeclass_client.dart';
import '../data/eeclass_parser.dart';
import '../data/lms_session_service.dart';
import '../data/lms_task_sync_service.dart';
import '../domain/lms_types.dart';
import '../providers/lms_providers.dart';

class NthuLmsSettingsSection extends ConsumerWidget {
  const NthuLmsSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncState = ref.watch(eeclassConnectionProvider);
    final ignoredAsync = ref.watch(ignoredLmsTasksProvider);
    final ignoredTasks = ignoredAsync.value ?? const <LmsIgnoredTask>[];
    final state = asyncState.value;
    final preview = state?.lastSuccessfulPreview;
    final message = state?.message;
    final busy =
        state?.status == LmsConnectionStatus.connecting ||
        state?.status == LmsConnectionStatus.syncing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NTHU LMS', style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(
          'Connect eeclass to sync verified homework links detected from Recent Events into Tasks. '
          'Existing reminders, completion state, and manual title/deadline edits are preserved. '
          'Deleted LMS-imported tasks stay deleted during future syncs and can be restored later from this section. '
          'Unverified event types are ignored, and the app does not read or store your password.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: asyncState.isLoading && state == null
              ? const LinearProgressIndicator()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school_outlined, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'eeclass',
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        _StatusChip(status: state?.status),
                      ],
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              state?.status ==
                                      LmsConnectionStatus.networkError ||
                                  state?.status ==
                                      LmsConnectionStatus.taskSyncError ||
                                  state?.status ==
                                      LmsConnectionStatus.parseError ||
                                  state?.status ==
                                      LmsConnectionStatus.sessionExpired ||
                                  state?.status ==
                                      LmsConnectionStatus.unsupported
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (preview != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Assignments detected from Recent Events',
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(height: 6),
                      if (preview.items.isEmpty)
                        Text(
                          'No upcoming eeclass assignments were present in Recent Events at the last successful sync.',
                          style: theme.textTheme.bodySmall,
                        )
                      else
                        for (final item in preview.items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _PreviewItem(item: item),
                          ),
                      if (preview.ignoredUnknownEvents > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${preview.ignoredUnknownEvents} other Recent Event item(s) were ignored because their type is not verified yet.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Last successful sync: ${_formatDateTime(preview.syncedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (state == null ||
                            state.status == LmsConnectionStatus.disconnected ||
                            state.status ==
                                LmsConnectionStatus.sessionExpired ||
                            state.status == LmsConnectionStatus.unsupported)
                          FilledButton.tonalIcon(
                            onPressed: busy
                                ? null
                                : () => _connect(context, ref),
                            icon: const Icon(Icons.login_rounded),
                            label: Text(
                              state?.status ==
                                      LmsConnectionStatus.sessionExpired
                                  ? 'Sign in again'
                                  : 'Connect',
                            ),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: busy
                                ? null
                                : () => _connect(context, ref),
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('Reconnect'),
                          ),
                        if (state != null &&
                            state.status != LmsConnectionStatus.disconnected)
                          FilledButton.tonalIcon(
                            onPressed: busy
                                ? null
                                : () => ref
                                      .read(eeclassConnectionProvider.notifier)
                                      .sync(),
                            icon: const Icon(Icons.sync_rounded),
                            label: const Text('Sync now'),
                          ),
                        if (state != null &&
                            state.status != LmsConnectionStatus.disconnected &&
                            state.status !=
                                LmsConnectionStatus.sessionExpired &&
                            state.status != LmsConnectionStatus.unsupported)
                          OutlinedButton.icon(
                            onPressed: busy
                                ? null
                                : () => showDialog<void>(
                                    context: context,
                                    builder: (_) => EeclassSessionBrowserDialog(
                                      session: ref.read(
                                        lmsSessionServiceProvider,
                                      ),
                                    ),
                                  ),
                            icon: const Icon(Icons.open_in_browser_rounded),
                            label: const Text('Open eeclass'),
                          ),
                        if (state != null &&
                            state.status != LmsConnectionStatus.disconnected)
                          TextButton.icon(
                            onPressed: busy
                                ? null
                                : () => ref
                                      .read(eeclassConnectionProvider.notifier)
                                      .disconnect(),
                            icon: const Icon(Icons.link_off_rounded),
                            label: const Text('Disconnect'),
                          ),
                      ],
                    ),
                    if (ignoredTasks.isNotEmpty) ...[
                      const Divider(height: 24),
                      Text(
                        'Deleted LMS tasks',
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Deleted LMS-imported tasks stay deleted during future syncs. Restore one here to show it again.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (final item in ignoredTasks)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.delete_outline_rounded, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      item.courseName,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: busy
                                    ? null
                                    : () async {
                                        await ref
                                            .read(lmsTaskSyncServiceProvider)
                                            .restoreIgnoredTask(item.taskId);
                                        ref.invalidate(ignoredLmsTasksProvider);
                                      },
                                child: const Text('Restore'),
                              ),
                            ],
                          ),
                        ),
                    ],
                    if (busy) ...[
                      const SizedBox(height: 10),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _connect(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(eeclassConnectionProvider.notifier);
    notifier.beginConnect();
    final result = await showDialog<LmsPreviewSnapshot>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EeclassLoginDialog(
        session: ref.read(lmsSessionServiceProvider),
        parser: ref.read(eeclassParserProvider),
      ),
    );
    if (result == null) {
      notifier.cancelConnect();
    } else {
      await notifier.acceptConnectedPreview(result);
    }
  }

  static String _formatDateTime(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}

class EeclassLoginDialog extends StatefulWidget {
  const EeclassLoginDialog({
    required this.session,
    required this.parser,
    super.key,
  });

  final LmsSessionService session;
  final EeclassParser parser;

  @override
  State<EeclassLoginDialog> createState() => _EeclassLoginDialogState();
}

class _EeclassLoginDialogState extends State<EeclassLoginDialog> {
  bool _initializing = true;
  bool _collecting = false;
  bool _navigatingToRecentEvents = false;
  String? _error;
  String _status = 'Preparing secure eeclass sign-in…';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await widget.session.ensureInitialized();
      if (mounted) setState(() => _initializing = false);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: size.width < 900 ? size.width - 32 : 900,
        height: size.height < 720 ? size.height - 32 : 680,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              child: Row(
                children: [
                  const Icon(Icons.school_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect NTHU eeclass',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          _error ?? _status,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _error == null
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cancel',
                    onPressed: _collecting
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _initializing
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                    )
                  : Stack(
                      children: [
                        InAppWebView(
                          keepAlive: widget.session.eeclassKeepAlive,
                          webViewEnvironment: widget.session.webViewEnvironment,
                          initialUrlRequest: URLRequest(
                            url: WebUri(EeclassClient.recentEventsUrl),
                          ),
                          initialSettings: InAppWebViewSettings(
                            javaScriptEnabled: true,
                            isInspectable: kDebugMode,
                          ),
                          onWebViewCreated: (controller) async {
                            widget.session.attachEeclassController(controller);
                            // A keep-alive WebView may already exist from an
                            // earlier connection attempt. Reload Recent Events
                            // so this dialog always starts from a known page and
                            // can either parse it or follow eeclass to login.
                            await controller.loadUrl(
                              urlRequest: URLRequest(
                                url: WebUri(EeclassClient.recentEventsUrl),
                              ),
                            );
                          },
                          onLoadStart: (controller, url) {
                            if (!mounted) return;
                            setState(() {
                              _status = _friendlyStatus(url?.toString());
                            });
                          },
                          onLoadStop: (controller, url) async {
                            if (!mounted || _collecting) return;
                            final current = url?.toString() ?? '';
                            if (!current.startsWith(
                              EeclassClient.recentEventsUrl,
                            )) {
                              if (_isAuthenticatedEeclassPage(current) &&
                                  !_navigatingToRecentEvents) {
                                setState(() {
                                  _navigatingToRecentEvents = true;
                                  _status =
                                      'Sign-in successful. Opening Recent Events…';
                                });
                                await controller.loadUrl(
                                  urlRequest: URLRequest(
                                    url: WebUri(EeclassClient.recentEventsUrl),
                                  ),
                                );
                                return;
                              }
                              setState(
                                () => _status = _friendlyStatus(current),
                              );
                              return;
                            }
                            setState(() {
                              _collecting = true;
                              _status =
                                  'Sign-in successful. Reading Recent Events…';
                            });
                            try {
                              final html = await controller.getHtml();
                              if (html == null || html.trim().isEmpty) {
                                throw const LmsParseException(
                                  'eeclass returned an empty Recent Event page.',
                                );
                              }
                              final parsed = widget.parser.parseRecentEvents(
                                html,
                              );
                              final preview = LmsPreviewSnapshot(
                                items: parsed.assignments,
                                accountScope: parsed.accountScope,
                                ignoredUnknownEvents:
                                    parsed.ignoredUnknownEvents,
                                syncedAt: DateTime.now(),
                              );
                              if (!context.mounted) {
                                return;
                              }
                              Navigator.of(context).pop(preview);
                            } on Object catch (error) {
                              if (!mounted) return;
                              setState(() {
                                _collecting = false;
                                _error = error.toString();
                              });
                            }
                          },
                          onReceivedError: (controller, request, error) {
                            if (!mounted || request.isForMainFrame == false) {
                              return;
                            }
                            final failed = request.url.toString();
                            if (failed.startsWith(
                              'https://eeclass.nthu.edu.tw/',
                            )) {
                              setState(() {
                                _error =
                                    'Could not load eeclass. Check your internet connection and try again.';
                              });
                            }
                          },
                        ),
                        if (_collecting)
                          ColoredBox(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.82,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _friendlyStatus(String? url) {
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri?.host == 'eeclass.nthu.edu.tw' &&
        uri?.path.startsWith('/index/login') == true) {
      return 'Sign in on the NTHU/eeclass page below. Your password stays inside the embedded browser.';
    }
    if (uri?.host == 'eeclass.nthu.edu.tw') {
      return 'Finishing eeclass sign-in…';
    }
    return 'Complete the NTHU sign-in flow below.';
  }

  bool _isAuthenticatedEeclassPage(String value) {
    final uri = Uri.tryParse(value);
    if (uri?.host != 'eeclass.nthu.edu.tw') return false;
    final path = uri?.path ?? '';
    return path == '/dashboard' ||
        path.startsWith('/dashboard/') ||
        path.startsWith('/course/');
  }
}

class EeclassSessionBrowserDialog extends StatefulWidget {
  const EeclassSessionBrowserDialog({required this.session, super.key});

  final LmsSessionService session;

  @override
  State<EeclassSessionBrowserDialog> createState() =>
      _EeclassSessionBrowserDialogState();
}

class _EeclassSessionBrowserDialogState
    extends State<EeclassSessionBrowserDialog> {
  bool _initializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await widget.session.ensureInitialized();
      if (mounted) setState(() => _initializing = false);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: size.width < 900 ? size.width - 32 : 900,
        height: size.height < 720 ? size.height - 32 : 680,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              child: Row(
                children: [
                  const Icon(Icons.open_in_browser_rounded),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'eeclass session',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          'This uses the same embedded-browser session as Sync. '
                          'You can log out here to test expired-session handling.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _initializing
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                    )
                  : InAppWebView(
                      keepAlive: widget.session.eeclassKeepAlive,
                      webViewEnvironment: widget.session.webViewEnvironment,
                      initialUrlRequest: URLRequest(
                        url: WebUri(EeclassClient.recentEventsUrl),
                      ),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        isInspectable: kDebugMode,
                      ),
                      onWebViewCreated: (controller) {
                        widget.session.attachEeclassController(controller);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final LmsConnectionStatus? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, icon) = switch (status) {
      LmsConnectionStatus.connecting => ('Connecting', Icons.hourglass_top),
      LmsConnectionStatus.authenticated => (
        'Previously connected',
        Icons.check_circle_outline,
      ),
      LmsConnectionStatus.syncing => ('Syncing', Icons.sync),
      LmsConnectionStatus.success => ('Connected', Icons.check_circle_outline),
      LmsConnectionStatus.taskSyncError => (
        'Task sync error',
        Icons.error_outline_rounded,
      ),
      LmsConnectionStatus.sessionExpired => (
        'Sign-in expired',
        Icons.lock_clock_outlined,
      ),
      LmsConnectionStatus.networkError => (
        'Sync failed',
        Icons.cloud_off_outlined,
      ),
      LmsConnectionStatus.parseError => (
        'Format changed',
        Icons.warning_amber_rounded,
      ),
      LmsConnectionStatus.unsupported => ('Unavailable', Icons.block_outlined),
      _ => ('Not connected', Icons.link_off_rounded),
    };
    final error =
        status == LmsConnectionStatus.sessionExpired ||
        status == LmsConnectionStatus.networkError ||
        status == LmsConnectionStatus.taskSyncError ||
        status == LmsConnectionStatus.parseError ||
        status == LmsConnectionStatus.unsupported;
    final color = error ? theme.colorScheme.error : theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _PreviewItem extends StatelessWidget {
  const _PreviewItem({required this.item});

  final LmsItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final due = item.dueAt;
    String two(int n) => n.toString().padLeft(2, '0');
    final date = '${two(due.month)}/${two(due.day)}';
    final time = item.duePrecision == LmsDuePrecision.dateTime
        ? ' · ${two(due.hour)}:${two(due.minute)}'
        : '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.assignment_outlined,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: theme.textTheme.bodySmall),
              Text(
                '${item.courseName} · $date$time',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
