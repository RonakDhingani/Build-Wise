import '../../../../core/result/result.dart';
import '../repositories/material_repository.dart';

class DeleteMaterialUseCase {
  const DeleteMaterialUseCase(this._repository);
  final MaterialRepository _repository;

  Future<Result<void>> execute(int id) {
    return _repository.deleteMaterial(id);
  }
}
