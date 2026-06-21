import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/material_repository_impl.dart';
import '../../domain/repositories/material_repository.dart';
import '../../domain/use_cases/create_material_use_case.dart';
import '../../domain/use_cases/delete_material_use_case.dart';
import '../../domain/use_cases/get_material_by_id_use_case.dart';
import '../../domain/use_cases/get_materials_use_case.dart';
import '../../domain/use_cases/update_material_use_case.dart';
import '../notifiers/material_notifier.dart';

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return MaterialRepositoryImpl(ref.read(isarProvider));
});

final createMaterialUseCaseProvider = Provider<CreateMaterialUseCase>((ref) {
  return CreateMaterialUseCase(ref.read(materialRepositoryProvider));
});

final updateMaterialUseCaseProvider = Provider<UpdateMaterialUseCase>((ref) {
  return UpdateMaterialUseCase(ref.read(materialRepositoryProvider));
});

final deleteMaterialUseCaseProvider = Provider<DeleteMaterialUseCase>((ref) {
  return DeleteMaterialUseCase(ref.read(materialRepositoryProvider));
});

final getMaterialsUseCaseProvider = Provider<GetMaterialsUseCase>((ref) {
  return GetMaterialsUseCase(ref.read(materialRepositoryProvider));
});

final getMaterialByIdUseCaseProvider = Provider<GetMaterialByIdUseCase>((ref) {
  return GetMaterialByIdUseCase(ref.read(materialRepositoryProvider));
});

final materialsNotifierProvider =
    AsyncNotifierProvider.family<MaterialsNotifier, MaterialsState, int>(
  MaterialsNotifier.new,
);
