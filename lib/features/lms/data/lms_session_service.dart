import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/lms_types.dart';

class LmsSessionService {
  static const _eeclassPreviewFileName = 'eeclass_preview.json';
  static const _elearnPreviewFileName = 'elearn_preview.json';

  WebViewEnvironment? _webViewEnvironment;
  InAppWebViewKeepAlive _eeclassKeepAlive = InAppWebViewKeepAlive();
  InAppWebViewKeepAlive _elearnKeepAlive = InAppWebViewKeepAlive();
  InAppWebViewController? _eeclassController;
  InAppWebViewController? _elearnController;
  bool _initialized = false;

  WebViewEnvironment? get webViewEnvironment => _webViewEnvironment;

  InAppWebViewKeepAlive get eeclassKeepAlive => _eeclassKeepAlive;
  InAppWebViewKeepAlive get elearnKeepAlive => _elearnKeepAlive;

  InAppWebViewController? get eeclassController => _eeclassController;
  InAppWebViewController? get elearnController => _elearnController;

  CookieManager get _cookieManager =>
      CookieManager.instance(webViewEnvironment: _webViewEnvironment);

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (!Platform.isWindows && !Platform.isAndroid) {
      throw const LmsUnsupportedException(
        'NTHU LMS sync currently supports Windows and Android only.',
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
      // Keep the original profile path so existing eeclass sessions survive
      // this update. eLearn uses a second keep-alive WebView inside the same
      // browser profile, which also allows normal NTHU SSO behavior.
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

  void attachEeclassController(InAppWebViewController controller) {
    _eeclassController = controller;
  }

  void attachElearnController(InAppWebViewController controller) {
    _elearnController = controller;
  }

  Future<LmsPreviewSnapshot?> loadPreview(LmsProvider provider) async {
    try {
      final file = await _previewFile(provider);
      if (!await file.exists()) return null;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return null;
      return LmsPreviewSnapshot.fromJson(decoded.cast<String, Object?>());
    } on Object {
      return null;
    }
  }

  Future<void> savePreview(
    LmsProvider provider,
    LmsPreviewSnapshot snapshot,
  ) async {
    final file = await _previewFile(provider);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(snapshot.toJson()), flush: true);
  }

  Future<void> clearPreview(LmsProvider provider) async {
    final file = await _previewFile(provider);
    if (await file.exists()) await file.delete();
  }

  Future<void> disconnect(LmsProvider provider) async {
    await ensureInitialized();

    // Do not clear the other LMS provider's cookies when disconnecting one.
    final origin = switch (provider) {
      LmsProvider.eeclass => 'https://eeclass.nthu.edu.tw/',
      LmsProvider.elearn => 'https://elearn.nthu.edu.tw/',
    };
    await _cookieManager.deleteCookies(url: WebUri(origin));
    await _disposeProviderWebView(provider);
    await clearPreview(provider);
  }

  Future<void> dispose() async {
    await _disposeProviderWebView(LmsProvider.eeclass);
    await _disposeProviderWebView(LmsProvider.elearn);
    final environment = _webViewEnvironment;
    _webViewEnvironment = null;
    _initialized = false;
    if (environment != null) await environment.dispose();
  }

  Future<void> _disposeProviderWebView(LmsProvider provider) async {
    switch (provider) {
      case LmsProvider.eeclass:
        final hadController = _eeclassController != null;
        _eeclassController = null;
        if (hadController) {
          try {
            await InAppWebViewController.disposeKeepAlive(_eeclassKeepAlive);
          } on Object {
            // The native view may already have been disposed by the platform.
          }
        }
        _eeclassKeepAlive = InAppWebViewKeepAlive();
        return;
      case LmsProvider.elearn:
        final hadController = _elearnController != null;
        _elearnController = null;
        if (hadController) {
          try {
            await InAppWebViewController.disposeKeepAlive(_elearnKeepAlive);
          } on Object {
            // The native view may already have been disposed by the platform.
          }
        }
        _elearnKeepAlive = InAppWebViewKeepAlive();
        return;
    }
  }

  Future<File> _previewFile(LmsProvider provider) async {
    final root = await getApplicationSupportDirectory();
    final fileName = switch (provider) {
      LmsProvider.eeclass => _eeclassPreviewFileName,
      LmsProvider.elearn => _elearnPreviewFileName,
    };
    return File(
      '${root.path}${Platform.pathSeparator}lms${Platform.pathSeparator}$fileName',
    );
  }
}
