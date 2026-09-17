import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../domain/lms_types.dart';
import 'elearn_parser.dart';
import 'lms_session_service.dart';

class ElearnClient {
  ElearnClient(this.session, this.parser);

  final LmsSessionService session;
  final ElearnParser parser;

  static const dashboardUrl = 'https://elearn.nthu.edu.tw/my/index.php';
  static const loginUrl = 'https://elearn.nthu.edu.tw/login/index.php';

  /// Reads Moodle action events using the exact embedded WebView session that
  /// performed eLearn/NTHU authentication. The call runs same-origin inside
  /// eLearn, so the app never needs to read or store the user's password.
  Future<LmsPreviewSnapshot> fetchAssignments({
    Duration timeout = const Duration(seconds: 35),
    Duration lookBack = const Duration(days: 14),
    Duration lookAhead = const Duration(days: 365),
  }) async {
    await session.ensureInitialized();
    final controller = session.elearnController;
    if (controller == null) {
      throw const LmsSessionExpiredException(
        'Your eLearn session is not active. Sign in again.',
      );
    }

    final deadline = DateTime.now().add(timeout);
    try {
      // Reuse the page that completed the interactive sign-in whenever it is
      // already an authenticated eLearn page. Reloading /my/index.php here
      // races Moodle's Dashboard initialization and can restart the page while
      // the login dialog is already trying to read the Timeline.
      final currentBeforeSync = (await controller.getUrl())?.toString() ?? '';
      if (!_isAuthenticatedElearnPage(currentBeforeSync)) {
        await controller.loadUrl(
          urlRequest: URLRequest(url: WebUri(dashboardUrl)),
        );
      }

      while (DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        final current = (await controller.getUrl())?.toString() ?? '';
        if (current.isEmpty) continue;

        if (_isLoginUrl(current)) {
          throw const LmsSessionExpiredException(
            'Your eLearn session has expired. Sign in again.',
          );
        }

        final uri = Uri.tryParse(current);
        if (uri == null || uri.host != 'elearn.nthu.edu.tw') {
          // NTHU SSO may briefly navigate away from eLearn. A manual sync has
          // no UI for completing that flow, so wait for an automatic redirect
          // back before classifying the session as expired.
          continue;
        }

        if (!_isAuthenticatedElearnPage(current)) continue;

        // Reaching an authenticated eLearn page only means navigation has
        // completed. Moodle initializes M.cfg asynchronously, so wait for its
        // session key before calling the Timeline API. M.cfg.userId is not
        // guaranteed to exist on this NTHU Moodle build and must not gate sync.
        if (!await _isMoodleSessionReady(controller)) continue;

        final now = DateTime.now();
        final fromSeconds = now
            .subtract(lookBack)
            .toUtc()
            .millisecondsSinceEpoch ~/ 1000;
        final toSeconds = now
            .add(lookAhead)
            .toUtc()
            .millisecondsSinceEpoch ~/ 1000;
        return _fetchTimeline(
          controller,
          timesortFrom: fromSeconds,
          timesortTo: toSeconds,
        );
      }
    } on LmsSessionExpiredException {
      rethrow;
    } on LmsParseException {
      rethrow;
    } on LmsUnsupportedException {
      rethrow;
    } on LmsNetworkException {
      rethrow;
    } on Object catch (error) {
      throw LmsNetworkException('Could not sync eLearn: $error');
    }

    final finalUrl = (await controller.getUrl())?.toString() ?? '';
    if (_isLoginUrl(finalUrl)) {
      throw const LmsSessionExpiredException(
        'Your eLearn session has expired. Sign in again.',
      );
    }
    throw const LmsNetworkException(
      'eLearn did not finish loading in time. Try again.',
    );
  }

  Future<bool> _isMoodleSessionReady(
    InAppWebViewController controller,
  ) async {
    try {
      final result = await controller.evaluateJavascript(
        source: r'''
          (() => {
            const cfg = (window.M && M.cfg) ? M.cfg : null;
            return !!(cfg && typeof cfg.sesskey === 'string' && cfg.sesskey.length > 0);
          })();
        ''',
      );
      if (result is bool) return result;
      if (result is num) return result != 0;
      if (result is String) return result.toLowerCase() == 'true';
    } on Object {
      // Navigation can briefly invalidate JavaScript execution. The outer
      // polling loop will retry until the Dashboard/session is ready.
    }
    return false;
  }

  Future<LmsPreviewSnapshot> _fetchTimeline(
    InAppWebViewController controller, {
    required int timesortFrom,
    required int timesortTo,
  }) async {
    final result = await controller.callAsyncJavaScript(
      functionBody: r'''
        if (typeof M === 'undefined' || !M.cfg || !M.cfg.sesskey) {
          return JSON.stringify({kind: 'session'});
        }

        // Moodle does not guarantee M.cfg.userId on every theme/build. Resolve
        // a stable account identity from the authenticated page instead, using
        // the numeric user id when available and the current user-menu label as
        // a final fallback. The Dart parser only needs a stable non-empty scope.
        const resolveAccountId = () => {
          const cfgUserId = Number(M.cfg.userId || 0);
          if (Number.isFinite(cfgUserId) && cfgUserId > 1) {
            return String(cfgUserId);
          }

          const body = document.body;
          const dataUserId = Number(
            body && body.dataset
              ? (body.dataset.userId || body.dataset.userid || 0)
              : 0
          );
          if (Number.isFinite(dataUserId) && dataUserId > 1) {
            return String(dataUserId);
          }

          const bodyClass = body ? String(body.className || '') : '';
          const bodyMatch = bodyClass.match(/(?:^|\s)user-(\d+)(?:\s|$)/);
          if (bodyMatch && Number(bodyMatch[1]) > 1) {
            return bodyMatch[1];
          }

          const userMenu = document.querySelector(
            '[data-region="usermenu"], .usermenu, .user-menu'
          );
          if (userMenu) {
            const profileLink = userMenu.querySelector(
              'a[href*="/user/profile.php"]'
            );
            if (profileLink && profileLink.href) {
              try {
                const profileUrl = new URL(profileLink.href, location.origin);
                const profileId = Number(profileUrl.searchParams.get('id') || 0);
                if (Number.isFinite(profileId) && profileId > 1) {
                  return String(profileId);
                }
              } catch (_) {}
            }

            const label = String(userMenu.innerText || userMenu.textContent || '')
              .replace(/\s+/g, ' ')
              .trim();
            if (label) return 'name:' + label;
          }

          const userText = document.querySelector('.usertext');
          const label = String(
            userText ? (userText.innerText || userText.textContent || '') : ''
          ).replace(/\s+/g, ' ').trim();
          if (label) return 'name:' + label;

          // This is only a last-resort scope for a valid authenticated session.
          // It keeps sync functional on themes that expose no account metadata.
          return 'authenticated';
        };

        const accountId = resolveAccountId();
        const method = 'core_calendar_get_action_events_by_timesort';
        const allEvents = [];
        let afterEventId = 0;
        let pages = 0;

        while (pages < 40) {
          const request = [{
            index: 0,
            methodname: method,
            args: {
              timesortfrom: timesortFrom,
              timesortto: timesortTo,
              aftereventid: afterEventId,
              limitnum: 50,
              limittononsuspendedevents: true
            }
          }];
          const endpoint = '/lib/ajax/service.php?sesskey=' +
            encodeURIComponent(M.cfg.sesskey) + '&info=' + encodeURIComponent(method);
          const response = await fetch(endpoint, {
            method: 'POST',
            credentials: 'same-origin',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(request)
          });
          if (!response.ok) {
            return JSON.stringify({kind: 'network', status: response.status});
          }
          const envelope = await response.json();
          const entry = Array.isArray(envelope) ? envelope[0] : null;
          if (!entry) {
            return JSON.stringify({kind: 'parse', message: 'Missing Moodle AJAX response.'});
          }
          if (entry.error) {
            const message = entry.exception && entry.exception.message
              ? entry.exception.message
              : 'Moodle rejected the timeline request.';
            return JSON.stringify({kind: 'api', message: message});
          }
          const data = entry.data;
          if (!data || !Array.isArray(data.events)) {
            return JSON.stringify({kind: 'parse', message: 'Missing Moodle timeline events.'});
          }

          allEvents.push(...data.events);
          pages += 1;
          const nextId = Number(data.lastid || 0);
          if (data.events.length < 50 || !nextId || nextId === afterEventId) break;
          afterEventId = nextId;
        }

        return JSON.stringify({
          kind: 'ok',
          userId: accountId,
          events: allEvents
        });
      ''',
      arguments: {
        'timesortFrom': timesortFrom,
        'timesortTo': timesortTo,
      },
    );

    if (result == null) {
      throw const LmsParseException(
        'eLearn did not return timeline data. No Tasks were changed.',
      );
    }
    if (result.error != null) {
      throw LmsParseException(
        'eLearn timeline script failed: ${result.error}. No Tasks were changed.',
      );
    }

    final rawValue = result.value;
    final decoded = switch (rawValue) {
      String text => jsonDecode(text),
      Map value => value,
      _ => null,
    };
    if (decoded is! Map) {
      throw const LmsParseException(
        'eLearn returned an unreadable timeline response. No Tasks were changed.',
      );
    }
    final payload = decoded.cast<String, Object?>();
    final kind = payload['kind']?.toString();
    switch (kind) {
      case 'session':
        throw const LmsSessionExpiredException(
          'Your eLearn session has expired. Sign in again.',
        );
      case 'network':
        throw LmsNetworkException(
          'eLearn timeline request failed (HTTP ${payload['status'] ?? 'unknown'}).',
        );
      case 'api':
        throw LmsParseException(
          'eLearn could not read the assignment timeline: ${payload['message'] ?? 'unknown Moodle error'}',
        );
      case 'parse':
        throw LmsParseException(
          'eLearn returned an unexpected timeline format: ${payload['message'] ?? 'unknown format error'}',
        );
      case 'ok':
        final parsed = parser.parseActionEvents(payload);
        return LmsPreviewSnapshot(
          items: parsed.assignments,
          accountScope: parsed.accountScope,
          ignoredUnknownEvents: parsed.ignoredUnknownEvents,
          syncedAt: DateTime.now(),
        );
      default:
        throw const LmsParseException(
          'eLearn returned an unknown timeline response. No Tasks were changed.',
        );
    }
  }

  static bool isElearnUrl(String value) =>
      Uri.tryParse(value)?.host == 'elearn.nthu.edu.tw';

  static bool _isLoginUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri?.host == 'elearn.nthu.edu.tw' &&
        uri?.path.startsWith('/login/') == true;
  }

  static bool _isAuthenticatedElearnPage(String value) {
    final uri = Uri.tryParse(value);
    if (uri?.host != 'elearn.nthu.edu.tw') return false;
    final path = uri?.path ?? '';
    return path == '/my/' ||
        path == '/my' ||
        path == '/my/index.php' ||
        path.startsWith('/course/') ||
        path.startsWith('/mod/') ||
        path == '/';
  }
}
