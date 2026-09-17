import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/eeclass_client.dart';
import '../data/eeclass_parser.dart';
import '../data/elearn_client.dart';
import '../data/lms_session_service.dart';
import '../data/lms_task_sync_service.dart';
import '../domain/lms_types.dart';
import '../providers/lms_providers.dart';

class NthuLmsSettingsSection extends ConsumerWidget {
  const NthuLmsSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final eeclassAsync = ref.watch(eeclassConnectionProvider);
    final elearnAsync = ref.watch(elearnConnectionProvider);
    final ignoredAsync = ref.watch(ignoredLmsTasksProvider);
    final ignoredTasks = ignoredAsync.value ?? const <LmsIgnoredTask>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NTHU LMS', style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(
          'Connect eeclass and/or eLearn to import verified assignments into Tasks. '
          'Each service keeps its own connection and task identities. Existing reminders, completion state, '
          'and manual title, notes, or deadline edits are preserved. Deleted LMS-imported tasks stay deleted '
          'during future syncs and can be restored below. The app does not read or store your password.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        _LmsProviderCard(
          name: 'eeclass',
          asyncState: eeclassAsync,
          onConnect: () => _connectEeclass(context, ref),
          onSync: () =>
              ref.read(eeclassConnectionProvider.notifier).sync(),
          onOpen: () => showDialog<void>(
            context: context,
            builder: (_) => EeclassSessionBrowserDialog(
              session: ref.read(lmsSessionServiceProvider),
            ),
          ),
          onDisconnect: () =>
              ref.read(eeclassConnectionProvider.notifier).disconnect(),
        ),
        const SizedBox(height: 10),
        _LmsProviderCard(
          name: 'eLearn',
          asyncState: elearnAsync,
          onConnect: () => _connectElearn(context, ref),
          onSync: () => ref.read(elearnConnectionProvider.notifier).sync(),
          onOpen: () => showDialog<void>(
            context: context,
            builder: (_) => ElearnSessionBrowserDialog(
              session: ref.read(lmsSessionServiceProvider),
            ),
          ),
          onDisconnect: () =>
              ref.read(elearnConnectionProvider.notifier).disconnect(),
        ),
        if (ignoredTasks.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deleted LMS tasks', style: theme.textTheme.labelMedium),
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
                              Text(item.title, style: theme.textTheme.bodyMedium),
                              Text(
                                '${_providerName(item.provider)} · ${item.courseName}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
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
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _connectEeclass(BuildContext context, WidgetRef ref) async {
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

  Future<void> _connectElearn(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(elearnConnectionProvider.notifier);
    notifier.beginConnect();
    final result = await showDialog<LmsPreviewSnapshot>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ElearnLoginDialog(
        session: ref.read(lmsSessionServiceProvider),
        client: ref.read(elearnClientProvider),
      ),
    );
    if (result == null) {
      notifier.cancelConnect();
    } else {
      await notifier.acceptConnectedPreview(result);
    }
  }

  static String _providerName(String value) => switch (value) {
    'elearn' => 'eLearn',
    'eeclass' => 'eeclass',
    _ => value,
  };
}

class _LmsProviderCard extends StatelessWidget {
  const _LmsProviderCard({
    required this.name,
    required this.asyncState,
    required this.onConnect,
    required this.onSync,
    required this.onOpen,
    required this.onDisconnect,
  });

  final String name;
  final AsyncValue<LmsConnectionState> asyncState;
  final VoidCallback onConnect;
  final VoidCallback onSync;
  final VoidCallback onOpen;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = asyncState.value;
    final preview = state?.lastSuccessfulPreview;
    final message = state?.message;
    final status = state?.status;
    final busy =
        status == LmsConnectionStatus.connecting ||
        status == LmsConnectionStatus.syncing;
    final disconnected =
        status == null || status == LmsConnectionStatus.disconnected;
    final needsSignIn =
        disconnected ||
        status == LmsConnectionStatus.sessionExpired ||
        status == LmsConnectionStatus.unsupported;
    final canOpen =
        status != null &&
        status != LmsConnectionStatus.disconnected &&
        status != LmsConnectionStatus.sessionExpired &&
        status != LmsConnectionStatus.unsupported;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: asyncState.isLoading && state == null
          ? const Text('Loading saved connection…')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school_outlined, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(name, style: theme.textTheme.titleSmall),
                    ),
                    _StatusChip(status: state?.status),
                  ],
                ),
                if (message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _isErrorStatus(state?.status)
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (preview != null) ...[
                  const SizedBox(height: 6),
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
                    if (needsSignIn)
                      FilledButton.tonalIcon(
                        onPressed: busy ? null : onConnect,
                        icon: const Icon(Icons.login_rounded),
                        label: Text(
                          state?.status == LmsConnectionStatus.sessionExpired
                              ? 'Sign in again'
                              : 'Connect',
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: busy ? null : onConnect,
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Reconnect'),
                      ),
                    if (!disconnected)
                      FilledButton.tonalIcon(
                        onPressed: busy ? null : onSync,
                        icon: const Icon(Icons.sync_rounded),
                        label: const Text('Sync now'),
                      ),
                    if (canOpen)
                      OutlinedButton.icon(
                        onPressed: busy ? null : onOpen,
                        icon: const Icon(Icons.open_in_browser_rounded),
                        label: Text('Open $name'),
                      ),
                    if (!disconnected)
                      TextButton.icon(
                        onPressed: busy ? null : onDisconnect,
                        icon: const Icon(Icons.link_off_rounded),
                        label: const Text('Disconnect'),
                      ),
                  ],
                ),
                if (busy) ...[
                  const SizedBox(height: 10),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
    );
  }

  static bool _isErrorStatus(LmsConnectionStatus? status) =>
      status == LmsConnectionStatus.networkError ||
      status == LmsConnectionStatus.taskSyncError ||
      status == LmsConnectionStatus.parseError ||
      status == LmsConnectionStatus.sessionExpired ||
      status == LmsConnectionStatus.unsupported;

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
    return _LmsLoginDialogFrame(
      title: 'Connect NTHU eeclass',
      status: _error ?? _status,
      isError: _error != null,
      busy: _collecting,
      initializing: _initializing,
      onClose: _collecting ? null : () => Navigator.of(context).pop(),
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
              onWebViewCreated: (controller) async {
                widget.session.attachEeclassController(controller);
                await controller.loadUrl(
                  urlRequest: URLRequest(
                    url: WebUri(EeclassClient.recentEventsUrl),
                  ),
                );
              },
              onLoadStart: (controller, url) {
                if (!mounted) return;
                setState(() => _status = _friendlyStatus(url?.toString()));
              },
              onLoadStop: (controller, url) async {
                if (!mounted || _collecting) return;
                final current = url?.toString() ?? '';
                if (!current.startsWith(EeclassClient.recentEventsUrl)) {
                  if (_isAuthenticatedEeclassPage(current) &&
                      !_navigatingToRecentEvents) {
                    setState(() {
                      _navigatingToRecentEvents = true;
                      _status = 'Sign-in successful. Opening Recent Events…';
                    });
                    await controller.loadUrl(
                      urlRequest: URLRequest(
                        url: WebUri(EeclassClient.recentEventsUrl),
                      ),
                    );
                    return;
                  }
                  setState(() => _status = _friendlyStatus(current));
                  return;
                }
                setState(() {
                  _collecting = true;
                  _status = 'Sign-in successful. Reading Recent Events…';
                });
                try {
                  final html = await controller.getHtml();
                  if (html == null || html.trim().isEmpty) {
                    throw const LmsParseException(
                      'eeclass returned an empty Recent Event page.',
                    );
                  }
                  final parsed = widget.parser.parseRecentEvents(html);
                  final preview = LmsPreviewSnapshot(
                    items: parsed.assignments,
                    accountScope: parsed.accountScope,
                    ignoredUnknownEvents: parsed.ignoredUnknownEvents,
                    syncedAt: DateTime.now(),
                  );
                  if (!context.mounted) return;
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
                if (!mounted || request.isForMainFrame == false) return;
                final failed = request.url.toString();
                if (failed.startsWith('https://eeclass.nthu.edu.tw/')) {
                  setState(() {
                    _error =
                        'Could not load eeclass. Check your internet connection and try again.';
                  });
                }
              },
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

class ElearnLoginDialog extends StatefulWidget {
  const ElearnLoginDialog({
    required this.session,
    required this.client,
    super.key,
  });

  final LmsSessionService session;
  final ElearnClient client;

  @override
  State<ElearnLoginDialog> createState() => _ElearnLoginDialogState();
}

class _ElearnLoginDialogState extends State<ElearnLoginDialog> {
  bool _initializing = true;
  bool _collecting = false;
  bool _openingDashboard = false;
  String? _error;
  String _status = 'Preparing secure eLearn sign-in…';

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
    return _LmsLoginDialogFrame(
      title: 'Connect NTHU eLearn',
      status: _error ?? _status,
      isError: _error != null,
      busy: _collecting,
      initializing: _initializing,
      onClose: _collecting ? null : () => Navigator.of(context).pop(),
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
              keepAlive: widget.session.elearnKeepAlive,
              webViewEnvironment: widget.session.webViewEnvironment,
              // Always open the real eLearn login page when the user presses
              // Connect. If Moodle already has an authenticated session, NTHU
              // may show an "already logged in" confirmation page; the
              // onLoadStop handler recognizes that state and immediately sends
              // the browser to the Dashboard.
              initialUrlRequest: URLRequest(
                url: WebUri(ElearnClient.loginUrl),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                isInspectable: kDebugMode,
              ),
              onWebViewCreated: (controller) {
                widget.session.attachElearnController(controller);
              },
              onLoadStart: (controller, url) {
                if (!mounted || _collecting) return;
                final current = url?.toString();
                setState(() {
                  _status = _openingDashboard && _isDashboardPage(current ?? '')
                      ? 'Sign-in successful. Opening eLearn Dashboard…'
                      : _friendlyStatus(current);
                });
              },
              onLoadStop: (controller, url) async {
                if (!mounted || _collecting) return;
                final current = url?.toString() ?? '';
                final uri = Uri.tryParse(current);

                if (uri?.host != 'elearn.nthu.edu.tw') {
                  setState(() => _status = _friendlyStatus(current));
                  return;
                }

                final authenticated = await _hasAuthenticatedSession(controller);
                if (!mounted || _collecting) return;

                if (!authenticated) {
                  _openingDashboard = false;
                  setState(() => _status = _friendlyStatus(current));
                  return;
                }

                if (!_isDashboardPage(current)) {
                  if (_openingDashboard) return;
                  _openingDashboard = true;
                  setState(() {
                    _status = 'Sign-in successful. Opening eLearn Dashboard…';
                    _error = null;
                  });
                  try {
                    await controller.loadUrl(
                      urlRequest: URLRequest(
                        url: WebUri(ElearnClient.dashboardUrl),
                      ),
                    );
                  } on Object catch (error) {
                    if (!mounted) return;
                    setState(() {
                      _openingDashboard = false;
                      _error = 'Could not open the eLearn Dashboard: $error';
                    });
                  }
                  return;
                }

                _openingDashboard = false;
                setState(() {
                  _collecting = true;
                  _status = 'Dashboard ready. Reading eLearn assignments…';
                  _error = null;
                });
                try {
                  final preview = await widget.client.fetchAssignments();
                  if (!context.mounted) return;
                  Navigator.of(context).pop(preview);
                } on LmsSessionExpiredException {
                  if (!mounted) return;
                  setState(() {
                    _collecting = false;
                    _openingDashboard = false;
                    _status =
                        'Your eLearn session was not recognized. Sign in again below and the app will open Dashboard automatically.';
                  });
                  final currentUrl =
                      (await controller.getUrl())?.toString() ?? '';
                  if (mounted && !_isLoginPage(currentUrl)) {
                    await controller.loadUrl(
                      urlRequest: URLRequest(
                        url: WebUri(ElearnClient.loginUrl),
                      ),
                    );
                  }
                } on Object catch (error) {
                  if (!mounted) return;
                  setState(() {
                    _collecting = false;
                    _error = error.toString();
                  });
                }
              },
              onReceivedError: (controller, request, error) {
                if (!mounted || request.isForMainFrame == false) return;
                final failed = request.url.toString();
                if (failed.startsWith('https://elearn.nthu.edu.tw/')) {
                  setState(() {
                    _openingDashboard = false;
                    _error =
                        'Could not load eLearn. Check your internet connection and try again.';
                  });
                }
              },
            ),
    );
  }

  Future<bool> _hasAuthenticatedSession(
    InAppWebViewController controller,
  ) async {
    try {
      final result = await controller.evaluateJavascript(
        source: r'''
          (() => {
            const cfg = (window.M && M.cfg) ? M.cfg : null;
            const userId = Number(cfg && cfg.userId ? cfg.userId : 0);
            if (Number.isFinite(userId) && userId > 1) return true;

            // Normal authenticated Moodle pages expose either a logout link
            // or the user menu.
            const hasLogoutControl = !!document.querySelector(
              'a[href*="/login/logout.php"], ' +
              'form[action*="/login/logout.php"], ' +
              'button[name="logout"], input[name="logout"]'
            );
            if (hasLogoutControl) return true;

            const userMenu = document.querySelector(
              '[data-region="usermenu"], .usermenu, .user-menu'
            );
            if (userMenu) return true;

            // NTHU eLearn can show /login/index.php even though the Moodle
            // session is already authenticated. That confirmation page says
            // "You are already logged in as ..." (or its Chinese equivalent)
            // and offers a logout button. Treat it as authenticated so the
            // app can continue straight to /my/index.php.
            const bodyText = (document.body && document.body.innerText
              ? document.body.innerText
              : '').replace(/\s+/g, ' ').trim();
            const alreadyLoggedInEnglish = /already logged in as/i.test(bodyText);
            const alreadyLoggedInChinese =
              bodyText.includes('已經以') &&
              bodyText.includes('身分登入');
            if (alreadyLoggedInEnglish || alreadyLoggedInChinese) return true;

            return false;
          })();
        ''',
      );
      if (result is bool) return result;
      if (result is num) return result != 0;
      if (result is String) return result.toLowerCase() == 'true';
    } on Object {
      // A transient script/navigation failure is not enough to classify the
      // session as logged out. The next completed page load will check again.
    }
    return false;
  }

  String _friendlyStatus(String? url) {
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri?.host == 'elearn.nthu.edu.tw' &&
        uri?.path.startsWith('/login/') == true) {
      return 'Sign in with NTHU Academic Information System below. Your password stays inside the embedded browser.';
    }
    if (uri?.host == 'elearn.nthu.edu.tw' &&
        _isDashboardPage(url ?? '')) {
      return 'Checking eLearn Dashboard…';
    }
    if (uri?.host == 'elearn.nthu.edu.tw') {
      return 'Checking eLearn sign-in…';
    }
    return 'Complete the NTHU sign-in flow below.';
  }

  bool _isLoginPage(String value) {
    final uri = Uri.tryParse(value);
    return uri?.host == 'elearn.nthu.edu.tw' &&
        uri?.path.startsWith('/login/') == true;
  }

  bool _isDashboardPage(String value) {
    final uri = Uri.tryParse(value);
    if (uri?.host != 'elearn.nthu.edu.tw') return false;
    final path = uri?.path ?? '';
    return path == '/my' || path == '/my/' || path == '/my/index.php';
  }
}

class _LmsLoginDialogFrame extends StatelessWidget {
  const _LmsLoginDialogFrame({
    required this.title,
    required this.status,
    required this.isError,
    required this.busy,
    required this.initializing,
    required this.onClose,
    required this.child,
  });

  final String title;
  final String status;
  final bool isError;
  final bool busy;
  final bool initializing;
  final VoidCallback? onClose;
  final Widget child;

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
                        Text(title, style: theme.textTheme.titleMedium),
                        Text(
                          status,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isError
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cancel',
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: child),
                  if (busy && !initializing)
                    Positioned.fill(
                      child: ColoredBox(
                        color: theme.colorScheme.surface.withValues(alpha: 0.82),
                        child: const Center(child: CircularProgressIndicator()),
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
  Widget build(BuildContext context) => _SessionBrowserFrame(
    title: 'eeclass session',
    description:
        'This uses the same embedded-browser session as Sync. You can log out here to test expired-session handling.',
    initializing: _initializing,
    error: _error,
    child: InAppWebView(
      keepAlive: widget.session.eeclassKeepAlive,
      webViewEnvironment: widget.session.webViewEnvironment,
      initialUrlRequest: URLRequest(url: WebUri(EeclassClient.recentEventsUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        isInspectable: kDebugMode,
      ),
      onWebViewCreated: widget.session.attachEeclassController,
    ),
  );
}

class ElearnSessionBrowserDialog extends StatefulWidget {
  const ElearnSessionBrowserDialog({required this.session, super.key});

  final LmsSessionService session;

  @override
  State<ElearnSessionBrowserDialog> createState() =>
      _ElearnSessionBrowserDialogState();
}

class _ElearnSessionBrowserDialogState
    extends State<ElearnSessionBrowserDialog> {
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
  Widget build(BuildContext context) => _SessionBrowserFrame(
    title: 'eLearn session',
    description:
        'This uses the same embedded-browser session as eLearn Sync. You can browse or log out here.',
    initializing: _initializing,
    error: _error,
    child: InAppWebView(
      keepAlive: widget.session.elearnKeepAlive,
      webViewEnvironment: widget.session.webViewEnvironment,
      initialUrlRequest: URLRequest(url: WebUri(ElearnClient.dashboardUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        isInspectable: kDebugMode,
      ),
      onWebViewCreated: widget.session.attachElearnController,
    ),
  );
}

class _SessionBrowserFrame extends StatelessWidget {
  const _SessionBrowserFrame({
    required this.title,
    required this.description,
    required this.initializing,
    required this.error,
    required this.child,
  });

  final String title;
  final String description;
  final bool initializing;
  final String? error;
  final Widget child;

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
                        Text(title, style: theme.textTheme.titleMedium),
                        Text(
                          description,
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
              child: initializing
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(error!, textAlign: TextAlign.center),
                      ),
                    )
                  : child,
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
