import '../../../../core/result/result.dart';
import '../entities/material_entity.dart';
import '../repositories/material_repository.dart';

class CreateMaterialUseCase {
  const CreateMaterialUseCase(this._repository);
  final MaterialRepository _repository;

  Future<Result<MaterialEntity>> execute(MaterialEntity entity) {
    return _repository.createMaterial(entity);
  }
}
