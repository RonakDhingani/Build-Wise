import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Lightweight local persistence for the onboarding walkthrough completion
/// flag. Kept out of Isar so it needs no schema/codegen — it is a single
/// boolean and the app is fully offline.
class WalkthroughStore {
  const WalkthroughStore();

  static const _fileName = 'walkthrough.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// True once the user has finished or skipped the tour. Defaults to false
  /// (first run) when the file is missing or unreadable.
  Future<bool> isCompleted() async {
    try {
      final file = await _file();
      if (!await file.exists()) return false;
      final map = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return map['completed'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> setCompleted(bool value) async {
    try {
      final file = await _file();
      await file.writeAsString(jsonEncode({'completed': value}));
    } catch (_) {
      // Best-effort; a failed write just means the tour may show again.
    }
  }
}
