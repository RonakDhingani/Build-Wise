import 'package:isar/isar.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../../expense/data/models/expense_isar_model.dart';
import '../../../material/data/models/material_isar_model.dart';
import '../../../photo/data/models/photo_isar_model.dart';
import '../../../stage/data/models/stage_isar_model.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../mappers/project_mapper.dart';
import '../models/project_isar_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  const ProjectRepositoryImpl(this._isar);
  final Isar _isar;

  @override
  Future<Result<ProjectEntity>> createProject(ProjectEntity entity) async {
    try {
      final now = DateTime.now();
      final model = ProjectMapper.toModel(entity.copyWith(
        createdAt: now,
        updatedAt: now,
      ));

      late int newId;
      await _isar.writeTxn(() async {
        newId = await _isar.projectModels.put(model);
        await _isar.stageModels.putAll(_buildDefaultStages(newId, now));
      });

      final saved = await _isar.projectModels.get(newId);
      if (saved == null) return const Failure(DatabaseFailure());
      return Success(ProjectMapper.toEntity(saved));
    } catch (e) {
      return Failure(DatabaseFailure('Failed to create project: $e'));
    }
  }

  @override
  Future<Result<ProjectEntity>> updateProject(ProjectEntity entity) async {
    try {
      final existing = await _isar.projectModels.get(entity.id);
      if (existing == null) return const Failure(NotFoundFailure());

      final model = ProjectMapper.toModel(entity.copyWith(
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      ));
      model.id = entity.id;

      await _isar.writeTxn(() => _isar.projectModels.put(model));
      final saved = await _isar.projectModels.get(entity.id);
      if (saved == null) return const Failure(DatabaseFailure());
      return Success(ProjectMapper.toEntity(saved));
    } catch (e) {
      return Failure(DatabaseFailure('Failed to update project: $e'));
    }
  }

  @override
  Future<Result<void>> deleteProject(int id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.projectModels.delete(id);

        final stageIds = await _isar.stageModels
            .filter()
            .projectIdEqualTo(id)
            .idProperty()
            .findAll();
        await _isar.stageModels.deleteAll(stageIds);

        final expenseIds = await _isar.expenseModels
            .filter()
            .projectIdEqualTo(id)
            .idProperty()
            .findAll();
        await _isar.expenseModels.deleteAll(expenseIds);

        final materialIds = await _isar.materialModels
            .filter()
            .projectIdEqualTo(id)
            .idProperty()
            .findAll();
        await _isar.materialModels.deleteAll(materialIds);

        final photoIds = await _isar.photoModels
            .filter()
            .projectIdEqualTo(id)
            .idProperty()
            .findAll();
        await _isar.photoModels.deleteAll(photoIds);
      });
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to delete project: $e'));
    }
  }

  @override
  Future<Result<void>> archiveProject(int id) async {
    try {
      final model = await _isar.projectModels.get(id);
      if (model == null) return const Failure(NotFoundFailure());

      model.status = model.status == ProjectModelStatus.archived
          ? ProjectModelStatus.active
          : ProjectModelStatus.archived;
      model.updatedAt = DateTime.now();
      await _isar.writeTxn(() => _isar.projectModels.put(model));
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to toggle archive project: $e'));
    }
  }

  @override
  Future<Result<List<ProjectEntity>>> getProjects({ProjectStatus? status}) async {
    try {
      List<ProjectModel> models;

      if (status == null) {
        models = await _isar.projectModels
            .where()
            .sortByCreatedAtDesc()
            .findAll();
      } else {
        final modelStatus = status == ProjectStatus.active
            ? ProjectModelStatus.active
            : ProjectModelStatus.archived;
        models = await _isar.projectModels
            .filter()
            .statusEqualTo(modelStatus)
            .sortByCreatedAtDesc()
            .findAll();
      }

      final entities = await Future.wait(
        models.map((m) => _toEntityWithComputed(m)),
      );
      return Success(entities);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to load projects: $e'));
    }
  }

  @override
  Future<Result<ProjectEntity>> getProjectById(int id) async {
    try {
      final model = await _isar.projectModels.get(id);
      if (model == null) return const Failure(NotFoundFailure());
      final entity = await _toEntityWithComputed(model);
      return Success(entity);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to load project: $e'));
    }
  }

  Future<ProjectEntity> _toEntityWithComputed(ProjectModel model) async {
    double totalSpent = 0.0;
    try {
      final expenses = await _isar.expenseModels
          .filter()
          .projectIdEqualTo(model.id)
          .findAll();
      totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
    } catch (_) {}

    // Material purchases also count toward spent. totalCost mirrors
    // MaterialEntity.totalCost: quantityPurchased * costPerUnit (0 if no cost).
    try {
      final materials = await _isar.materialModels
          .filter()
          .projectIdEqualTo(model.id)
          .findAll();
      totalSpent += materials.fold(
        0.0,
        (sum, m) => sum + (m.costPerUnit != null
            ? m.quantityPurchased * m.costPerUnit!
            : 0.0),
      );
    } catch (_) {}

    double completionPct = 0.0;
    try {
      final stages = await _isar.stageModels
          .filter()
          .projectIdEqualTo(model.id)
          .findAll();
      if (stages.isNotEmpty) {
        final total = stages.fold<int>(0, (sum, s) => sum + s.progressPercent);
        completionPct = total / stages.length;
      }
    } catch (_) {}

    return ProjectMapper.toEntity(
      model,
      totalSpent: totalSpent,
      completionPercentage: completionPct,
    );
  }

  List<StageModel> _buildDefaultStages(int projectId, DateTime now) {
    return List.generate(
      AppConstants.defaultStageNames.length,
      (i) => StageModel()
        ..projectId = projectId
        ..name = AppConstants.defaultStageNames[i]
        ..orderIndex = i
        ..status = StageModelStatus.notStarted
        ..progressPercent = 0
        ..isDefault = true
        ..createdAt = now
        ..updatedAt = now,
    );
  }
}
