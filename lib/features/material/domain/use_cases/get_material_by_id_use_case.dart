import '../../../../core/result/result.dart';
import '../entities/material_entity.dart';
import '../repositories/material_repository.dart';

class GetMaterialByIdUseCase {
  const GetMaterialByIdUseCase(this._repository);
  final MaterialRepository _repository;

  Future<Result<MaterialEntity>> execute(int id) {
    return _repository.getMaterialById(id);
  }
}
