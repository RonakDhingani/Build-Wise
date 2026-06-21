import '../../domain/entities/project_entity.dart';
import '../models/project_isar_model.dart';

class ProjectMapper {
  ProjectMapper._();

  static ProjectEntity toEntity(
    ProjectModel model, {
    double totalSpent = 0.0,
    double completionPercentage = 0.0,
  }) {
    return ProjectEntity(
      id: model.id,
      name: model.name,
      location: model.location,
      plotSize: model.plotSize,
      builtUpArea: model.builtUpArea,
      numberOfFloors: model.numberOfFloors,
      budget: model.budget,
      startDate: model.startDate,
      expectedCompletionDate: model.expectedCompletionDate,
      notes: model.notes,
      coverImagePath: model.coverImagePath,
      status: _mapStatus(model.status),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      totalSpent: totalSpent,
      completionPercentage: completionPercentage,
    );
  }

  static ProjectModel toModel(ProjectEntity entity) {
    final model = ProjectModel()
      ..name = entity.name
      ..location = entity.location
      ..plotSize = entity.plotSize
      ..builtUpArea = entity.builtUpArea
      ..numberOfFloors = entity.numberOfFloors
      ..budget = entity.budget
      ..startDate = entity.startDate
      ..expectedCompletionDate = entity.expectedCompletionDate
      ..notes = entity.notes
      ..coverImagePath = entity.coverImagePath
      ..status = _mapToModelStatus(entity.status)
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;

    if (entity.id != 0) model.id = entity.id;
    return model;
  }

  static ProjectStatus _mapStatus(ProjectModelStatus status) =>
      switch (status) {
        ProjectModelStatus.active => ProjectStatus.active,
        ProjectModelStatus.archived => ProjectStatus.archived,
      };

  static ProjectModelStatus _mapToModelStatus(ProjectStatus status) =>
      switch (status) {
        ProjectStatus.active => ProjectModelStatus.active,
        ProjectStatus.archived => ProjectModelStatus.archived,
      };
}
