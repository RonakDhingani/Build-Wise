import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../domain/use_cases/add_photo_use_case.dart';
import '../../domain/use_cases/delete_photo_use_case.dart';
import '../../domain/use_cases/get_photos_use_case.dart';
import '../notifiers/photo_notifier.dart';
import '../services/photo_picker_service.dart';

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepositoryImpl(ref.read(isarProvider));
});

final addPhotoUseCaseProvider = Provider<AddPhotoUseCase>((ref) {
  return AddPhotoUseCase(ref.read(photoRepositoryProvider));
});

final deletePhotoUseCaseProvider = Provider<DeletePhotoUseCase>((ref) {
  return DeletePhotoUseCase(ref.read(photoRepositoryProvider));
});

final getPhotosUseCaseProvider = Provider<GetPhotosUseCase>((ref) {
  return GetPhotosUseCase(ref.read(photoRepositoryProvider));
});

final photoPickerServiceProvider = Provider<PhotoPickerService>((_) {
  return const PhotoPickerService();
});

final photosNotifierProvider =
    AsyncNotifierProvider.family<PhotosNotifier, PhotoState, int>(
  PhotosNotifier.new,
);
