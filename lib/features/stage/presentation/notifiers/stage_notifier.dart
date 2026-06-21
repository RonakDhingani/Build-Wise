import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../../project/presentation/providers/project_providers.dart';
import '../../domain/entities/stage_entity.dart';
import '../providers/stage_providers.dart';

class StageState {
  const StageState({
    required this.stages,
    this.searchQuery = '',
    this.statusFilter,
  });

  final List<StageEntity> stages;
  final String searchQuery;
  final StageStatus? statusFilter;

  int get total => stages.length;
  int get completedCount =>
      stages.where((s) => s.status == StageStatus.completed).length;

  List<StageEntity> get filtered {
    var list = [...stages];

    if (statusFilter != null) {
      list = list.where((s) => s.status == statusFilter).toList();
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((s) => s.name.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  StageState copyWith({
    List<StageEntity>? stages,
    String? searchQuery,
    StageStatus? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return StageState(
      stages: stages ?? this.stages,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

class StagesNotifier extends FamilyAsyncNotifier<StageState, int> {
  @override
  Future<StageState> build(int arg) async {
    return _load(arg);
  }

  Future<StageState> _load(int projectId) async {
    final useCase = ref.read(getStagesUseCaseProvider);
    final result = await useCase.execute(projectId);
    final stages = result.when(
      success: (data) => data,
      failure: (f) => throw Exception(f.message),
    );
    return StageState(stages: stages);
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    final newState = await _load(arg);
    state = AsyncData(newState.copyWith(
      searchQuery: current?.searchQuery ?? '',
      statusFilter: current?.statusFilter,
      clearStatusFilter: current?.statusFilter == null,
    ));
  }

  Future<void> addStage(StageEntity entity) async {
    final useCase = ref.read(createStageUseCaseProvider);
    final orderIndex = state.valueOrNull?.stages.length ?? 0;
    final result = await useCase.execute(entity.copyWith(orderIndex: orderIndex));
    result.when(
      success: (created) {
        state.whenData((s) {
          state = AsyncData(s.copyWith(
            stages: [...s.stages, created],
          ));
        });
      },
      failure: (f) => throw Exception(f.message),
    );
    ref.read(projectsNotifierProvider.notifier).refresh();
  }

  Future<void> updateStage(StageEntity entity) async {
    final useCase = ref.read(updateStageUseCaseProvider);
    final result = await useCase.execute(entity);
    result.when(
      success: (updated) {
        state.whenData((s) {
          final list = List<StageEntity>.from(s.stages);
          final idx = list.indexWhere((e) => e.id == updated.id);
          if (idx >= 0) list[idx] = updated;
          state = AsyncData(s.copyWith(stages: list));
        });
      },
      failure: (f) => throw Exception(f.message),
    );
    ref.read(projectsNotifierProvider.notifier).refresh();
  }

  Future<void> deleteStage(int id) async {
    final useCase = ref.read(deleteStageUseCaseProvider);
    final result = await useCase.execute(id);
    result.when(
      success: (_) {
        state.whenData((s) {
          state = AsyncData(s.copyWith(
            stages: s.stages.where((e) => e.id != id).toList(),
          ));
        });
      },
      failure: (f) => throw Exception(f.message),
    );
    ref.read(projectsNotifierProvider.notifier).refresh();
  }

  Future<void> updateProgress(int stageId, int progress) async {
    final stage = state.valueOrNull?.stages.firstWhere((s) => s.id == stageId);
    if (stage == null) return;

    StageStatus newStatus = stage.status;
    if (progress == 100 && stage.status != StageStatus.completed) {
      newStatus = StageStatus.completed;
    } else if (progress > 0 && stage.status == StageStatus.notStarted) {
      newStatus = StageStatus.inProgress;
    }

    await updateStage(stage.copyWith(
      progressPercent: progress,
      status: newStatus,
    ));
  }

  void updateSearch(String query) {
    state.whenData(
        (s) => state = AsyncData(s.copyWith(searchQuery: query)));
  }

  void setStatusFilter(StageStatus? status) {
    state.whenData((s) => state = AsyncData(s.copyWith(
          statusFilter: status,
          clearStatusFilter: status == null,
        )));
  }
}
