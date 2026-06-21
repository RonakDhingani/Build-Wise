import 'package:isar/isar.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/material_entity.dart';
import '../../domain/repositories/material_repository.dart';
import '../mappers/material_mapper.dart';
import '../models/material_isar_model.dart';

class MaterialRepositoryImpl implements MaterialRepository {
  const MaterialRepositoryImpl(this._isar);
  final Isar _isar;

  @override
  Future<Result<MaterialEntity>> createMaterial(MaterialEntity entity) async {
    try {
      final now = DateTime.now();
      final model = MaterialMapper.toModel(entity.copyWith(
        createdAt: now,
        updatedAt: now,
      ));

      late int newId;
      await _isar.writeTxn(() async {
        newId = await _isar.materialModels.put(model);
      });

      final saved = await _isar.materialModels.get(newId);
      if (saved == null) return const Failure(DatabaseFailure());
      return Success(MaterialMapper.toEntity(saved));
    } catch (e) {
      return Failure(DatabaseFailure('Failed to create material: $e'));
    }
  }

  @override
  Future<Result<MaterialEntity>> updateMaterial(MaterialEntity entity) async {
    try {
      final existing = await _isar.materialModels.get(entity.id);
      if (existing == null) return const Failure(NotFoundFailure());

      final model = MaterialMapper.toModel(entity.copyWith(
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      ));
      model.id = entity.id;

      await _isar.writeTxn(() => _isar.materialModels.put(model));
      final saved = await _isar.materialModels.get(entity.id);
      if (saved == null) return const Failure(DatabaseFailure());
      return Success(MaterialMapper.toEntity(saved));
    } catch (e) {
      return Failure(DatabaseFailure('Failed to update material: $e'));
    }
  }

  @override
  Future<Result<void>> deleteMaterial(int id) async {
    try {
      await _isar.writeTxn(() => _isar.materialModels.delete(id));
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to delete material: $e'));
    }
  }

  @override
  Future<Result<List<MaterialEntity>>> getMaterialsByProject(int projectId) async {
    try {
      final models = await _isar.materialModels
          .where()
          .projectIdEqualTo(projectId)
          .findAll();
      return Success(models.map(MaterialMapper.toEntity).toList());
    } catch (e) {
      return Failure(DatabaseFailure('Failed to load materials: $e'));
    }
  }

  @override
  Future<Result<MaterialEntity>> getMaterialById(int id) async {
    try {
      final model = await _isar.materialModels.get(id);
      if (model == null) return const Failure(NotFoundFailure());
      return Success(MaterialMapper.toEntity(model));
    } catch (e) {
      return Failure(DatabaseFailure('Failed to load material: $e'));
    }
  }
}
