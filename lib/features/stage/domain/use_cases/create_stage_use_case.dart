import '../../../../core/result/result.dart';
import '../entities/stage_entity.dart';
import '../repositories/stage_repository.dart';

class CreateStageUseCase {
  const CreateStageUseCase(this._repository);
  final StageRepository _repository;

  Future<Result<StageEntity>> execute(StageEntity entity) =>
      _repository.createStage(entity);
}
