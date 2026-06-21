import '../../../../core/result/result.dart';
import '../entities/material_entity.dart';

abstract class MaterialRepository {
  Future<Result<MaterialEntity>> createMaterial(MaterialEntity entity);
  Future<Result<MaterialEntity>> updateMaterial(MaterialEntity entity);
  Future<Result<void>> deleteMaterial(int id);
  Future<Result<List<MaterialEntity>>> getMaterialsByProject(int projectId);
  Future<Result<MaterialEntity>> getMaterialById(int id);
}
