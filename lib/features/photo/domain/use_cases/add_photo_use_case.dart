import '../../../../core/result/result.dart';
import '../entities/photo_entity.dart';
import '../repositories/photo_repository.dart';

class AddPhotoUseCase {
  const AddPhotoUseCase(this._repository);
  final PhotoRepository _repository;

  Future<Result<PhotoEntity>> execute(PhotoEntity entity) =>
      _repository.addPhoto(entity);
}
