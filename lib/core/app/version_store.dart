import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Persists the installed app version across launches so the exact upgrade path
/// is captured (e.g. support requests record `appOldVersion` -> `currentVersion`).
///
/// File-based (no extra dependency). On [record], if the running version
/// differs from the stored one, the stored value becomes [previousVersion].
class VersionStore {
  String _current = '0.0.0';
  String _previous = '0.0.0';
  bool _loaded = false;

  String get currentVersion => _current;
  String get previousVersion => _previous;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/build_wise/app_version.json');
  }

  /// Read the running version, fold in the persisted history, and save.
  Future<void> record() async {
    try {
      final pkg = await PackageInfo.fromPlatform();
      final running = pkg.version;
      final file = await _file();

      String storedCurrent = running;
      String storedPrevious = running;
      if (file.existsSync()) {
        final json = jsonDecode(await file.readAsString()) as Map;
        storedCurrent = (json['current'] as String?) ?? running;
        storedPrevious = (json['previous'] as String?) ?? storedCurrent;
      }

      // Upgrade detected: last-known current becomes previous.
      _previous = (storedCurrent != running) ? storedCurrent : storedPrevious;
      _current = running;

      await file.parent.create(recursive: true);
      await file.writeAsString(
        jsonEncode({'current': _current, 'previous': _previous}),
      );
      _loaded = true;
    } catch (e) {
      debugPrint('VersionStore.record failed: $e');
    }
  }

  /// Ensure values are available even if [record] hasn't run yet.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    await record();
  }
}

/// Single shared instance for the app lifetime.
final versionStoreProvider = Provider<VersionStore>((ref) => VersionStore());
