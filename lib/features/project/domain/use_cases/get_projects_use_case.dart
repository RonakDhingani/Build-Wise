import '../../../../core/result/result.dart';
import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

class GetProjectsUseCase {
  const GetProjectsUseCase(this._repository);
  final ProjectRepository _repository;

  Future<Result<List<ProjectEntity>>> execute({ProjectStatus? status}) {
    return _repository.getProjects(status: status);
  }
}
