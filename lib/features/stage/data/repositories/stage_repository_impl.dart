import 'package:isar/isar.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/stage_entity.dart';
import '../../domain/repositories/stage_repository.dart';
import '../mappers/stage_mapper.dart';
import '../models/stage_isar_model.dart';

class StageRepositoryImpl implements StageRepository {
  const StageRepositoryImpl(this._isar);
  final Isar _isar;

  @override
  Future<Result<StageEntity>> createStage(StageEntity entity) async {
    try {
      final now = DateTime.now();
      final model = StageMapper.toModel(entity.copyWith(
        createdAt: now,
        updatedAt: now,
      ));

      late int newId;
      await _isar.writeTxn(() async {
        newId = await _isar.stageModels.put(model);
      });

      final saved = await _isar.stageModels.get(newId);
      if (saved == null) return const Failure(DatabaseFailure());
      return Success(StageMapper.toEntity(saved));
    } catch (e) {
      return Failure(DatabaseFailure('Failed to create stage: $e'));
    }
  }

  @override
  Future<Result<StageEntity>> updateStage(StageEntity entity) async {
    try {
      final existing = await _isar.stageModels.get(entity.id);
      if (existing == null) return const Failure(NotFoundFailure());

      final model = StageMapper.toModel(entity.copyWith(
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      ));
      model.id = entity.id;

      await _isar.writeTxn(() => _isar.stageModels.put(model));
      final saved = await _isar.stageModels.get(entity.id);
      if (saved == null) return const Failure(DatabaseFailure());
      return Success(StageMapper.toEntity(saved));
    } catch (e) {
      return Failure(DatabaseFailure('Failed to update stage: $e'));
    }
  }

  @override
  Future<Result<void>> deleteStage(int id) async {
    try {
      await _isar.writeTxn(() => _isar.stageModels.delete(id));
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to delete stage: $e'));
    }
  }

  @override
  Future<Result<List<StageEntity>>> getStagesByProject(int projectId) async {
    try {
      final models = await _isar.stageModels
          .where()
          .projectIdEqualTo(projectId)
          .findAll();
      models.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return Success(models.map(StageMapper.toEntity).toList());
    } catch (e) {
      return Failure(DatabaseFailure('Failed to load stages: $e'));
    }
  }

  @override
  Future<Result<StageEntity>> getStageById(int id) async {
    try {
      final model = await _isar.stageModels.get(id);
      if (model == null) return const Failure(NotFoundFailure());
      return Success(StageMapper.toEntity(model));
    } catch (e) {
      return Failure(DatabaseFailure('Failed to load stage: $e'));
    }
  }
}
