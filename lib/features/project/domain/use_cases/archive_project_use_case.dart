import '../../../../core/result/result.dart';
import '../repositories/project_repository.dart';

class ArchiveProjectUseCase {
  const ArchiveProjectUseCase(this._repository);
  final ProjectRepository _repository;

  Future<Result<void>> execute(int projectId) {
    return _repository.archiveProject(projectId);
  }
}
