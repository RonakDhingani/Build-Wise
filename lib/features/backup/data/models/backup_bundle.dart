import 'package:archive/archive.dart';

import 'backup_manifest.dart';

/// A decoded, validated backup archive held in memory between the preview and
/// the actual import. Carries the parsed JSON records plus the raw archive so
/// image payloads can be extracted during import.
class BackupBundle {
  BackupBundle({
    required this.sourcePath,
    required this.manifest,
    required this.projects,
    required this.stages,
    required this.expenses,
    required this.materials,
    required this.categories,
    required this.photos,
    required this.files,
  });

  final String sourcePath;
  final BackupManifest manifest;

  final List<Map<String, dynamic>> projects;
  final List<Map<String, dynamic>> stages;
  final List<Map<String, dynamic>> expenses;
  final List<Map<String, dynamic>> materials;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> photos;

  /// Archive entries keyed by their in-archive name (`files/...`).
  final Map<String, ArchiveFile> files;

  /// Photo records belonging to the given backup-local project id.
  List<Map<String, dynamic>> photosForProject(int oldProjectId) => photos
      .where((p) => (p['projectId'] as num).toInt() == oldProjectId)
      .toList();

  /// True for single-project archives — the only shape eligible for the
  /// "Replace Existing Project" import mode.
  bool get isSingleProject => projects.length == 1;
}

/// What an import actually wrote to the database.
class ImportSummary {
  const ImportSummary({
    required this.projectsCreated,
    required this.stages,
    required this.expenses,
    required this.materials,
    required this.photosRestored,
    required this.photosMissing,
    this.replacedProjectName,
  });

  final int projectsCreated;
  final int stages;
  final int expenses;
  final int materials;
  final int photosRestored;
  final int photosMissing;
  final String? replacedProjectName;
}
