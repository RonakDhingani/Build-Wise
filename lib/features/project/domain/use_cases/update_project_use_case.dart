import '../../../../core/result/result.dart';
import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

class UpdateProjectUseCase {
  const UpdateProjectUseCase(this._repository);
  final ProjectRepository _repository;

  Future<Result<ProjectEntity>> execute(ProjectEntity entity) {
    return _repository.updateProject(entity);
  }
}
