import 'backup_manifest.dart';

/// Outcome of a successful export — where the archive landed plus what went in.
class BackupResult {
  const BackupResult({
    required this.filePath,
    required this.fileName,
    required this.sizeBytes,
    required this.manifest,
    this.skippedPhotos = 0,
  });

  final String filePath;
  final String fileName;
  final int sizeBytes;
  final BackupManifest manifest;

  /// Photos whose image file was missing on disk and therefore left out.
  final int skippedPhotos;
}
