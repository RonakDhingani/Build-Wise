import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/models/backup_bundle.dart';
import '../../data/services/backup_export_service.dart';
import '../../data/services/backup_import_service.dart';

final backupExportServiceProvider = Provider<BackupExportService>((ref) {
  return BackupExportService(ref.read(isarProvider));
});

final backupImportServiceProvider = Provider<BackupImportService>((ref) {
  return BackupImportService(ref.read(isarProvider));
});

/// Opens and validates a picked backup file for the import preview screen.
/// Throws [BackupException] (caught by the screen) on any validation problem.
final backupBundleProvider =
    FutureProvider.family<BackupBundle, String>((ref, zipPath) async {
  return ref.read(backupImportServiceProvider).open(zipPath);
});
