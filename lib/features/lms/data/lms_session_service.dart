import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/lms_types.dart';

class LmsSessionService {
  static const _previewFileName = 'eeclass_preview.json';

  WebViewEnvironment? _webViewEnvironment;
  InAppWebViewKeepAlive _eeclassKeepAlive = InAppWebViewKeepAlive();
  InAppWebViewController? _eeclassController;
  bool _initialized = false;

  WebViewEnvironment? get webViewEnvironment => _webViewEnvironment;

  /// Token for the single native eeclass WebView used by login, browsing, and
  /// background-style manual syncs while the app process remains alive.
  ///
  /// Reusing the same keep-alive token is important: Windows WebView2 and
  /// Android then keep the exact authenticated native WebView instead of
  /// relying on cookies being copied to a second WebView instance.
  InAppWebViewKeepAlive get eeclassKeepAlive => _eeclassKeepAlive;

  InAppWebViewController? get eeclassController => _eeclassController;

  CookieManager get _cookieManager =>
      CookieManager.instance(webViewEnvironment: _webViewEnvironment);

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (!Platform.isWindows && !Platform.isAndroid) {
      throw const LmsUnsupportedException(
        'The NTHU LMS preview currently supports Windows and Android only.',
      );
    }

    if (Platform.isWindows) {
      final availableVersion = await WebViewEnvironment.getAvailableVersion();
      if (availableVersion == null) {
        throw const LmsUnsupportedException(
          'Microsoft Edge WebView2 Runtime is required for NTHU LMS login on Windows.',
        );
      }
      final root = await getApplicationSupportDirectory();
      final profile = Directory(
        '${root.path}${Platform.pathSeparator}lms${Platform.pathSeparator}eeclass_webview2',
      );
      await profile.create(recursive: true);
      _webViewEnvironment = await WebViewEnvironment.create(
        settings: WebViewEnvironmentSettings(userDataFolder: profile.path),
      );
    } else if (Platform.isAndroid) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
    }
    _initialized = true;
  }

  /// Registers the controller for the keep-alive eeclass WebView.
  ///
  /// The controller intentionally remains registered when a dialog containing
  /// the WebView closes. [InAppWebViewKeepAlive] keeps the native WebView alive,
  /// which lets `Sync now` continue using the exact WebView that performed the
  /// login instead of creating an unauthenticated second browser.
  void attachEeclassController(InAppWebViewController controller) {
    _eeclassController = controller;
  }

  Future<LmsPreviewSnapshot?> loadPreview() async {
    try {
      final file = await _previewFile();
      if (!await file.exists()) return null;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return null;
      return LmsPreviewSnapshot.fromJson(decoded.cast<String, Object?>());
    } on Object {
      return null;
    }
  }

  Future<void> savePreview(LmsPreviewSnapshot snapshot) async {
    final file = await _previewFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(snapshot.toJson()), flush: true);
  }

  Future<void> clearPreview() async {
    final file = await _previewFile();
    if (await file.exists()) await file.delete();
  }

  Future<void> disconnect() async {
    await ensureInitialized();

    // Clearing cookies is still useful for an explicit Disconnect, but normal
    // sync no longer depends on copying cookies between WebView instances.
    await _cookieManager.deleteAllCookies();
    await _disposeEeclassWebView();
    await clearPreview();
  }

  Future<void> dispose() async {
    await _disposeEeclassWebView();
    final environment = _webViewEnvironment;
    _webViewEnvironment = null;
    _initialized = false;
    if (environment != null) await environment.dispose();
  }

  Future<void> _disposeEeclassWebView() async {
    final hadController = _eeclassController != null;
    _eeclassController = null;
    if (hadController) {
      try {
        await InAppWebViewController.disposeKeepAlive(_eeclassKeepAlive);
      } on Object catch (error) {
        debugPrint('Could not dispose eeclass keep-alive WebView: $error');
      }
    }
    _eeclassKeepAlive = InAppWebViewKeepAlive();
  }

  Future<File> _previewFile() async {
    final root = await getApplicationSupportDirectory();
    return File(
      '${root.path}${Platform.pathSeparator}lms${Platform.pathSeparator}$_previewFileName',
    );
  }
}
