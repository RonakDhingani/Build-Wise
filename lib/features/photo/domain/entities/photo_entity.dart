class PhotoEntity {
  const PhotoEntity({
    required this.id,
    required this.projectId,
    this.stageId,
    required this.filePath,
    this.thumbnailPath,
    this.caption,
    required this.takenAt,
    required this.createdAt,
  });

  final int id;
  final int projectId;
  final int? stageId;
  final String filePath;
  final String? thumbnailPath;
  final String? caption;
  final DateTime takenAt;
  final DateTime createdAt;

  PhotoEntity copyWith({
    int? id,
    int? projectId,
    int? stageId,
    String? filePath,
    String? thumbnailPath,
    String? caption,
    DateTime? takenAt,
    DateTime? createdAt,
  }) {
    return PhotoEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      stageId: stageId ?? this.stageId,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      caption: caption ?? this.caption,
      takenAt: takenAt ?? this.takenAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
