import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../domain/lms_types.dart';
import 'eeclass_parser.dart';
import 'lms_session_service.dart';

class EeclassClient {
  EeclassClient(this.session, this.parser);

  final LmsSessionService session;
  final EeclassParser parser;

  static const recentEventsUrl =
      'https://eeclass.nthu.edu.tw/dashboard/latestEvent';

  /// Fetches Recent Events through the exact native WebView that the user
  /// authenticated in. No second/headless WebView is created here.
  ///
  /// This is deliberate: eeclass/SSO authentication was not reliably usable
  /// when cookies were copied from the visible login WebView into a separate
  /// sync WebView, especially on Windows WebView2. The keep-alive controller is
  /// instead reused directly for every manual sync during the current app run.
  Future<LmsPreviewSnapshot> fetchRecentEvents({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    await session.ensureInitialized();
    final controller = session.eeclassController;
    if (controller == null) {
      throw const LmsSessionExpiredException();
    }

    final deadline = DateTime.now().add(timeout);
    var redirectedBackToRecentEvents = false;
    DateTime? externalRedirectSince;
    LmsParseException? lastParseError;

    try {
      await controller.loadUrl(
        urlRequest: URLRequest(url: WebUri(recentEventsUrl)),
      );

      while (DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 250));

        final current = (await controller.getUrl())?.toString() ?? '';
        if (current.isEmpty) continue;

        if (_isLoginUrl(current)) {
          throw const LmsSessionExpiredException();
        }

        final uri = Uri.tryParse(current);
        if (uri != null &&
            uri.host.isNotEmpty &&
            uri.host != 'eeclass.nthu.edu.tw') {
          // An already-authenticated eeclass session can briefly traverse an
          // external SSO host. Give that automatic redirect a little time to
          // come back; if it stays there, user interaction is required again.
          externalRedirectSince ??= DateTime.now();
          if (DateTime.now().difference(externalRedirectSince) >=
              const Duration(seconds: 8)) {
            throw const LmsSessionExpiredException();
          }
          continue;
        }
        externalRedirectSince = null;

        if (_isAuthenticatedEeclassPage(current) &&
            !_isRecentEventsUrl(current)) {
          if (!redirectedBackToRecentEvents) {
            redirectedBackToRecentEvents = true;
            await controller.loadUrl(
              urlRequest: URLRequest(url: WebUri(recentEventsUrl)),
            );
          }
          continue;
        }

        if (!_isRecentEventsUrl(current)) continue;

        final html = await controller.getHtml();
        if (html == null || html.trim().isEmpty) continue;

        try {
          final parsed = parser.parseRecentEvents(html);
          return LmsPreviewSnapshot(
            items: parsed.assignments,
            accountScope: parsed.accountScope,
            ignoredUnknownEvents: parsed.ignoredUnknownEvents,
            syncedAt: DateTime.now(),
          );
        } on LmsSessionExpiredException {
          rethrow;
        } on LmsParseException catch (error) {
          lastParseError = error;

          // If the Recent Event table already exists, the page has loaded far
          // enough that this is a real format/parse problem rather than a
          // transient navigation state. Surface it immediately.
          if (html.contains('recentEventTable')) rethrow;
        }
      }
    } on LmsSessionExpiredException {
      rethrow;
    } on LmsParseException {
      rethrow;
    } on LmsUnsupportedException {
      rethrow;
    } on Object catch (error) {
      throw LmsNetworkException('Could not sync eeclass: $error');
    }

    if (lastParseError != null) throw lastParseError;

    final finalUrl = (await controller.getUrl())?.toString() ?? '';
    final finalUri = Uri.tryParse(finalUrl);
    if (_isLoginUrl(finalUrl) ||
        (finalUri != null &&
            finalUri.host.isNotEmpty &&
            finalUri.host != 'eeclass.nthu.edu.tw')) {
      throw const LmsSessionExpiredException();
    }

    throw const LmsNetworkException(
      'eeclass did not finish loading in time. Try again.',
    );
  }

  static bool _isRecentEventsUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri?.host == 'eeclass.nthu.edu.tw' &&
        uri?.path == '/dashboard/latestEvent';
  }

  static bool _isLoginUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri?.host == 'eeclass.nthu.edu.tw' &&
        uri?.path.startsWith('/index/login') == true;
  }

  static bool _isAuthenticatedEeclassPage(String value) {
    final uri = Uri.tryParse(value);
    if (uri?.host != 'eeclass.nthu.edu.tw') return false;
    final path = uri?.path ?? '';
    return path == '/dashboard' ||
        path.startsWith('/dashboard/') ||
        path.startsWith('/course/');
  }
}
