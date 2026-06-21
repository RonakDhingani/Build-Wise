import '../../../../core/result/result.dart';
import '../repositories/photo_repository.dart';

class DeletePhotoUseCase {
  const DeletePhotoUseCase(this._repository);
  final PhotoRepository _repository;

  Future<Result<void>> execute(int id) => _repository.deletePhoto(id);
}
