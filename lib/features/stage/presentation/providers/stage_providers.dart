import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/stage_repository_impl.dart';
import '../../domain/repositories/stage_repository.dart';
import '../../domain/use_cases/create_stage_use_case.dart';
import '../../domain/use_cases/delete_stage_use_case.dart';
import '../../domain/use_cases/get_stage_by_id_use_case.dart';
import '../../domain/use_cases/get_stages_use_case.dart';
import '../../domain/use_cases/update_stage_use_case.dart';
import '../notifiers/stage_notifier.dart';

final stageRepositoryProvider = Provider<StageRepository>((ref) {
  return StageRepositoryImpl(ref.read(isarProvider));
});

final createStageUseCaseProvider = Provider<CreateStageUseCase>((ref) {
  return CreateStageUseCase(ref.read(stageRepositoryProvider));
});

final updateStageUseCaseProvider = Provider<UpdateStageUseCase>((ref) {
  return UpdateStageUseCase(ref.read(stageRepositoryProvider));
});

final deleteStageUseCaseProvider = Provider<DeleteStageUseCase>((ref) {
  return DeleteStageUseCase(ref.read(stageRepositoryProvider));
});

final getStagesUseCaseProvider = Provider<GetStagesUseCase>((ref) {
  return GetStagesUseCase(ref.read(stageRepositoryProvider));
});

final getStageByIdUseCaseProvider = Provider<GetStageByIdUseCase>((ref) {
  return GetStageByIdUseCase(ref.read(stageRepositoryProvider));
});

final stagesNotifierProvider =
    AsyncNotifierProvider.family<StagesNotifier, StageState, int>(
  StagesNotifier.new,
);
