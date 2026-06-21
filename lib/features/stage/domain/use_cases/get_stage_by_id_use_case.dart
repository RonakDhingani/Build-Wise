import '../../../../core/result/result.dart';
import '../entities/stage_entity.dart';
import '../repositories/stage_repository.dart';

class GetStageByIdUseCase {
  const GetStageByIdUseCase(this._repository);
  final StageRepository _repository;

  Future<Result<StageEntity>> execute(int id) =>
      _repository.getStageById(id);
}
