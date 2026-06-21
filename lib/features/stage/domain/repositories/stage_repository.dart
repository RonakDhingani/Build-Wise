import '../../../../core/result/result.dart';
import '../entities/stage_entity.dart';

abstract class StageRepository {
  Future<Result<StageEntity>> createStage(StageEntity entity);
  Future<Result<StageEntity>> updateStage(StageEntity entity);
  Future<Result<void>> deleteStage(int id);
  Future<Result<List<StageEntity>>> getStagesByProject(int projectId);
  Future<Result<StageEntity>> getStageById(int id);
}
