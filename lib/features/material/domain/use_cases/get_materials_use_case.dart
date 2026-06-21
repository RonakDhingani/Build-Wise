import '../../../../core/result/result.dart';
import '../entities/material_entity.dart';
import '../repositories/material_repository.dart';

class GetMaterialsUseCase {
  const GetMaterialsUseCase(this._repository);
  final MaterialRepository _repository;

  Future<Result<List<MaterialEntity>>> execute(int projectId) {
    return _repository.getMaterialsByProject(projectId);
  }
}
