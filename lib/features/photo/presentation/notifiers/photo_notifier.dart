import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/photo_entity.dart';
import '../providers/photo_providers.dart';

class PhotoState {
  const PhotoState({
    required this.photos,
    this.stageFilter,
  });

  final List<PhotoEntity> photos;
  final int? stageFilter;

  List<PhotoEntity> get filtered => stageFilter == null
      ? photos
      : photos.where((p) => p.stageId == stageFilter).toList();

  int get count => photos.length;

  PhotoState copyWith({
    List<PhotoEntity>? photos,
    int? stageFilter,
    bool clearStageFilter = false,
  }) {
    return PhotoState(
      photos: photos ?? this.photos,
      stageFilter:
          clearStageFilter ? null : (stageFilter ?? this.stageFilter),
    );
  }
}

class PhotosNotifier extends FamilyAsyncNotifier<PhotoState, int> {
  @override
  Future<PhotoState> build(int arg) async {
    return _load(arg);
  }

  Future<PhotoState> _load(int projectId) async {
    final useCase = ref.read(getPhotosUseCaseProvider);
    final result = await useCase.execute(projectId);
    final photos = result.when(
      success: (data) => data,
      failure: (f) => throw Exception(f.message),
    );
    return PhotoState(photos: photos);
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    final newState = await _load(arg);
    state = AsyncData(newState.copyWith(
      stageFilter: current?.stageFilter,
      clearStageFilter: current?.stageFilter == null,
    ));
  }

  Future<void> addPhoto(PhotoEntity entity) async {
    final useCase = ref.read(addPhotoUseCaseProvider);
    final result = await useCase.execute(entity);
    result.when(
      success: (created) {
        state.whenData((s) {
          state = AsyncData(s.copyWith(
            photos: [created, ...s.photos],
          ));
        });
      },
      failure: (f) => throw Exception(f.message),
    );
  }

  Future<void> deletePhoto(int id) async {
    final useCase = ref.read(deletePhotoUseCaseProvider);
    final result = await useCase.execute(id);
    result.when(
      success: (_) {
        state.whenData((s) {
          state = AsyncData(s.copyWith(
            photos: s.photos.where((p) => p.id != id).toList(),
          ));
        });
      },
      failure: (f) => throw Exception(f.message),
    );
  }

  void setStageFilter(int? stageId) {
    state.whenData((s) => state = AsyncData(s.copyWith(
          stageFilter: stageId,
          clearStageFilter: stageId == null,
        )));
  }
}
