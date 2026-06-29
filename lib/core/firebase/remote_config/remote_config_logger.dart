import 'package:flutter/foundation.dart';

/// Centralised, debug-only logger for the Remote Config module. One tag,
/// one place — replaces scattered `debugPrint` calls. No-op in release.
abstract class RcLog {
  static const String _tag = '[RemoteConfig]';

  static void info(String event, [Object? detail]) {
    if (!kDebugMode) return;
    debugPrint('🔵 $_tag $event${detail != null ? ' → $detail' : ''}');
  }

  static void success(String event, [Object? detail]) {
    if (!kDebugMode) return;
    debugPrint('🟢 $_tag $event${detail != null ? ' → $detail' : ''}');
  }

  static void error(String event, [Object? error]) {
    if (!kDebugMode) return;
    debugPrint('🔴 $_tag $event${error != null ? ' → $error' : ''}');
  }
}
