import '../../domain/backup_format.dart';

/// Record counts inside a backup — shown on the import preview screen and
/// written into `manifest.json`.
class BackupCounts {
  const BackupCounts({
    this.projects = 0,
    this.stages = 0,
    this.expenses = 0,
    this.materials = 0,
    this.categories = 0,
    this.photos = 0,
  });

  final int projects;
  final int stages;
  final int expenses;
  final int materials;
  final int categories;
  final int photos;

  Map<String, dynamic> toJson() => {
        'projects': projects,
        'stages': stages,
        'expenses': expenses,
        'materials': materials,
        'categories': categories,
        'photos': photos,
      };

  factory BackupCounts.fromJson(Map<String, dynamic> json) => BackupCounts(
        projects: (json['projects'] as num?)?.toInt() ?? 0,
        stages: (json['stages'] as num?)?.toInt() ?? 0,
        expenses: (json['expenses'] as num?)?.toInt() ?? 0,
        materials: (json['materials'] as num?)?.toInt() ?? 0,
        categories: (json['categories'] as num?)?.toInt() ?? 0,
        photos: (json['photos'] as num?)?.toInt() ?? 0,
      );
}

/// Header describing a backup archive. Read first on import to validate the
/// file and render the preview before touching any data.
class BackupManifest {
  const BackupManifest({
    required this.magic,
    required this.formatVersion,
    required this.appVersion,
    required this.createdAt,
    required this.scope,
    required this.counts,
  });

  final String magic;
  final int formatVersion;
  final String appVersion;
  final DateTime createdAt;
  final BackupScope scope;
  final BackupCounts counts;

  /// True when this build knows how to read the archive.
  bool get isFormatSupported =>
      formatVersion >= BackupFormat.minSupportedFormatVersion &&
      formatVersion <= BackupFormat.formatVersion;

  /// True when the file actually is a BuildWise backup.
  bool get isValidMagic => magic == BackupFormat.magic;

  Map<String, dynamic> toJson() => {
        'magic': magic,
        'formatVersion': formatVersion,
        'appVersion': appVersion,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'scope': scope.name,
        'counts': counts.toJson(),
      };

  factory BackupManifest.fromJson(Map<String, dynamic> json) => BackupManifest(
        magic: json['magic'] as String? ?? '',
        formatVersion: (json['formatVersion'] as num?)?.toInt() ?? 0,
        appVersion: json['appVersion'] as String? ?? 'unknown',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          (json['createdAt'] as num?)?.toInt() ?? 0,
        ),
        scope: BackupScope.values.firstWhere(
          (s) => s.name == json['scope'],
          orElse: () => BackupScope.currentProject,
        ),
        counts: BackupCounts.fromJson(
          (json['counts'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      );
}
