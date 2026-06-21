import '../../domain/entities/photo_entity.dart';
import '../models/photo_isar_model.dart';

class PhotoMapper {
  PhotoMapper._();

  static PhotoEntity toEntity(PhotoModel model) {
    return PhotoEntity(
      id: model.id,
      projectId: model.projectId,
      stageId: model.stageId,
      filePath: model.filePath,
      thumbnailPath: model.thumbnailPath,
      caption: model.caption,
      takenAt: model.takenAt,
      createdAt: model.createdAt,
    );
  }

  static PhotoModel toModel(PhotoEntity entity) {
    final model = PhotoModel()
      ..projectId = entity.projectId
      ..stageId = entity.stageId
      ..filePath = entity.filePath
      ..thumbnailPath = entity.thumbnailPath
      ..caption = entity.caption
      ..takenAt = entity.takenAt
      ..createdAt = entity.createdAt;

    if (entity.id != 0) model.id = entity.id;
    return model;
  }
}
