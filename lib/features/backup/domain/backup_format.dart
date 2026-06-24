/// Offline backup format definitions for BuildWise.
///
/// A backup is a single `.zip` archive containing JSON data files plus a
/// `files/` folder holding every referenced image (photos, thumbnails, bill
/// images and project cover images). The structure is intentionally simple and
/// versioned so future versions (and future cloud/Drive/Dropbox backends) can
/// read older archives.
///
/// Archive layout:
/// ```
/// buildwise_project_backup.zip
/// ├── manifest.json      (version, scope, counts, createdAt)
/// ├── project.json       (single object for current-project, list for all)
/// ├── stages.json
/// ├── expenses.json
/// ├── materials.json
/// ├── categories.json
/// └── files/             (referenced images, namespaced per project)
/// ```
abstract class BackupFormat {
  /// Bumped only on breaking changes to the archive layout / field shapes.
  static const int formatVersion = 1;

  /// Lowest [formatVersion] this build can still import.
  static const int minSupportedFormatVersion = 1;

  /// Identifies the archive as a BuildWise backup (guards against importing
  /// arbitrary zips).
  static const String magic = 'buildwise.backup';

  // Entry names inside the archive.
  static const String manifestFile = 'manifest.json';
  static const String projectFile = 'project.json';
  static const String stagesFile = 'stages.json';
  static const String expensesFile = 'expenses.json';
  static const String materialsFile = 'materials.json';
  static const String categoriesFile = 'categories.json';
  static const String photosFile = 'photos.json';

  /// Root folder for image payloads inside the archive.
  static const String filesDir = 'files';

  // Sub-folders under `files/<projectId>/` — also used to route a file back to
  // the correct destination directory on import.
  static const String subPhotos = 'photos';
  static const String subThumbs = 'thumbs';
  static const String subBills = 'bills';
  static const String subCover = 'cover';

  /// Default file name suggested when sharing / saving.
  static const String defaultFileName = 'buildwise_project_backup.zip';
}

/// What a backup covers.
enum BackupScope { currentProject, allProjects }

/// How an import is applied. Merge / partial imports are deliberately
/// unsupported — they create duplicate records and data inconsistency.
enum ImportMode { createNew, replaceExisting }

/// User-facing failure reasons for the backup pipeline.
enum BackupErrorType {
  invalidFile,
  corruptedArchive,
  missingData,
  versionMismatch,
  noProjects,
  unknown,
}

/// Thrown by the export/import services; carries a message safe to show.
class BackupException implements Exception {
  const BackupException(this.type, this.message);

  final BackupErrorType type;
  final String message;

  @override
  String toString() => 'BackupException($type): $message';
}
