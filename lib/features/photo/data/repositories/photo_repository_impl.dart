import 'dart:io';

import 'package:isar/isar.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/photo_entity.dart';
import '../../domain/repositories/photo_repository.dart';
import '../mappers/photo_mapper.dart';
import '../models/photo_isar_model.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  const PhotoRepositoryImpl(this._isar);
  final Isar _isar;

  @override
  Future<Result<PhotoEntity>> addPhoto(PhotoEntity entity) async {
    try {
      final now = DateTime.now();
      final model = PhotoMapper.toModel(entity.copyWith(createdAt: now));

      late int newId;
      await _isar.writeTxn(() async {
        newId = await _isar.photoModels.put(model);
      });

      final saved = await _isar.photoModels.get(newId);
      if (saved == null) return const Failure(DatabaseFailure());
      return Success(PhotoMapper.toEntity(saved));
    } catch (e) {
      return Failure(DatabaseFailure('Failed to save photo: $e'));
    }
  }

  @override
  Future<Result<void>> deletePhoto(int id) async {
    try {
      final model = await _isar.photoModels.get(id);
      if (model != null) {
        _deleteFileIfExists(model.filePath);
        if (model.thumbnailPath != null) {
          _deleteFileIfExists(model.thumbnailPath!);
        }
      }
      await _isar.writeTxn(() => _isar.photoModels.delete(id));
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to delete photo: $e'));
    }
  }

  @override
  Future<Result<List<PhotoEntity>>> getPhotosByProject(int projectId) async {
    try {
      final models = await _isar.photoModels
          .where()
          .projectIdEqualTo(projectId)
          .findAll();
      models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Success(models.map(PhotoMapper.toEntity).toList());
    } catch (e) {
      return Failure(DatabaseFailure('Failed to load photos: $e'));
    }
  }

  void _deleteFileIfExists(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    } catch (_) {}
  }
}
