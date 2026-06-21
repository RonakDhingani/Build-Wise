import '../../../../core/result/result.dart';
import '../entities/stage_entity.dart';
import '../repositories/stage_repository.dart';

class GetStagesUseCase {
  const GetStagesUseCase(this._repository);
  final StageRepository _repository;

  Future<Result<List<StageEntity>>> execute(int projectId) =>
      _repository.getStagesByProject(projectId);
}
