import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/backup_prefs_store.dart';

final backupPrefsStoreProvider =
    Provider<BackupPrefsStore>((_) => const BackupPrefsStore());

/// Reactive backup preferences. Screens watch this to show the Backup Status
/// card; the export flow calls [BackupPrefsNotifier.recordBackup] to update it.
final backupPrefsProvider =
    AsyncNotifierProvider<BackupPrefsNotifier, BackupPrefs>(
  BackupPrefsNotifier.new,
);

class BackupPrefsNotifier extends AsyncNotifier<BackupPrefs> {
  BackupPrefsStore get _store => ref.read(backupPrefsStoreProvider);

  @override
  Future<BackupPrefs> build() => _store.read();

  BackupPrefs get _current => state.valueOrNull ?? BackupPrefs.empty;

  /// Marks the one-time reminder as shown and persists it.
  Future<void> markReminderShown() async {
    final next = _current.copyWith(reminderShown: true);
    state = AsyncData(next);
    await _store.write(next);
  }

  /// Records a successful backup at [at] and persists it. Called after every
  /// successful export so the Backup Status card stays current.
  Future<void> recordBackup(DateTime at) async {
    final next = _current.copyWith(lastBackupAt: at);
    state = AsyncData(next);
    await _store.write(next);
  }
}
