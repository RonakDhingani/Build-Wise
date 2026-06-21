import '../../domain/entities/stage_entity.dart';
import '../models/stage_isar_model.dart';

class StageMapper {
  StageMapper._();

  static StageEntity toEntity(StageModel model) {
    return StageEntity(
      id: model.id,
      projectId: model.projectId,
      name: model.name,
      orderIndex: model.orderIndex,
      status: _mapStatus(model.status),
      startDate: model.startDate,
      endDate: model.endDate,
      progressPercent: model.progressPercent,
      notes: model.notes,
      isDefault: model.isDefault,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static StageModel toModel(StageEntity entity) {
    final model = StageModel()
      ..projectId = entity.projectId
      ..name = entity.name
      ..orderIndex = entity.orderIndex
      ..status = _mapToModelStatus(entity.status)
      ..startDate = entity.startDate
      ..endDate = entity.endDate
      ..progressPercent = entity.progressPercent
      ..notes = entity.notes
      ..isDefault = entity.isDefault
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;

    if (entity.id != 0) model.id = entity.id;
    return model;
  }

  static StageStatus _mapStatus(StageModelStatus status) =>
      switch (status) {
        StageModelStatus.notStarted => StageStatus.notStarted,
        StageModelStatus.inProgress => StageStatus.inProgress,
        StageModelStatus.completed => StageStatus.completed,
        StageModelStatus.onHold => StageStatus.onHold,
      };

  static StageModelStatus _mapToModelStatus(StageStatus status) =>
      switch (status) {
        StageStatus.notStarted => StageModelStatus.notStarted,
        StageStatus.inProgress => StageModelStatus.inProgress,
        StageStatus.completed => StageModelStatus.completed,
        StageStatus.onHold => StageModelStatus.onHold,
      };
}
