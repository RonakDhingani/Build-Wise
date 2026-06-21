import '../../../../core/result/result.dart';
import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

class GetProjectByIdUseCase {
  const GetProjectByIdUseCase(this._repository);
  final ProjectRepository _repository;

  Future<Result<ProjectEntity>> execute(int id) {
    return _repository.getProjectById(id);
  }
}
