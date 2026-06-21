import '../../../../core/result/result.dart';
import '../repositories/stage_repository.dart';

class DeleteStageUseCase {
  const DeleteStageUseCase(this._repository);
  final StageRepository _repository;

  Future<Result<void>> execute(int id) => _repository.deleteStage(id);
}
