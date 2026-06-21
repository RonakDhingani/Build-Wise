import '../../../../core/result/result.dart';
import '../entities/photo_entity.dart';

abstract class PhotoRepository {
  Future<Result<PhotoEntity>> addPhoto(PhotoEntity entity);
  Future<Result<void>> deletePhoto(int id);
  Future<Result<List<PhotoEntity>>> getPhotosByProject(int projectId);
}
