import '../../../../core/result/result.dart';
import '../entities/photo_entity.dart';
import '../repositories/photo_repository.dart';

class GetPhotosUseCase {
  const GetPhotosUseCase(this._repository);
  final PhotoRepository _repository;

  Future<Result<List<PhotoEntity>>> execute(int projectId) =>
      _repository.getPhotosByProject(projectId);
}
