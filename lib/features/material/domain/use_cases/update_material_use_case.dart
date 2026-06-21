import '../../../../core/result/result.dart';
import '../entities/material_entity.dart';
import '../repositories/material_repository.dart';

class UpdateMaterialUseCase {
  const UpdateMaterialUseCase(this._repository);
  final MaterialRepository _repository;

  Future<Result<MaterialEntity>> execute(MaterialEntity entity) {
    return _repository.updateMaterial(entity);
  }
}
