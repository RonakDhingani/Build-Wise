import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Immutable snapshot of the local backup preferences.
class BackupPrefs {
  const BackupPrefs({required this.reminderShown, this.lastBackupAt});

  /// True once the one-time "Protect Your Project Data" reminder has been
  /// shown (via either dialog button). Never resets unless app data is wiped.
  final bool reminderShown;

  /// Timestamp of the most recent successful backup export, or null if the
  /// user has never created a backup.
  final DateTime? lastBackupAt;

  static const empty = BackupPrefs(reminderShown: false);

  bool get hasBackup => lastBackupAt != null;

  BackupPrefs copyWith({bool? reminderShown, DateTime? lastBackupAt}) {
    return BackupPrefs(
      reminderShown: reminderShown ?? this.reminderShown,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
    );
  }
}

/// Lightweight local persistence for backup-related flags. Kept out of Isar so
/// it needs no schema/codegen — the app is fully offline and this is a single
/// small JSON file, mirroring [WalkthroughStore].
class BackupPrefsStore {
  const BackupPrefsStore();

  static const _fileName = 'backup_prefs.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Reads the stored prefs. Returns [BackupPrefs.empty] (first run) when the
  /// file is missing or unreadable.
  Future<BackupPrefs> read() async {
    try {
      final file = await _file();
      if (!await file.exists()) return BackupPrefs.empty;
      final map = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final ts = map['lastBackupAt'] as String?;
      return BackupPrefs(
        reminderShown: map['reminderShown'] == true,
        lastBackupAt: ts == null ? null : DateTime.tryParse(ts),
      );
    } catch (_) {
      return BackupPrefs.empty;
    }
  }

  /// Persists [prefs]. Best-effort; a failed write is swallowed (the reminder
  /// may show again / the last-backup time may not update, but nothing breaks).
  Future<void> write(BackupPrefs prefs) async {
    try {
      final file = await _file();
      await file.writeAsString(jsonEncode({
        'reminderShown': prefs.reminderShown,
        'lastBackupAt': prefs.lastBackupAt?.toIso8601String(),
      }));
    } catch (_) {
      // Ignored — offline best-effort store.
    }
  }
}
