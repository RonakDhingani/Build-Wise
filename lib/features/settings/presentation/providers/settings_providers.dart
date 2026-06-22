import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/use_cases/get_settings_use_case.dart';
import '../../domain/use_cases/update_settings_use_case.dart';
import '../notifiers/settings_notifier.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.read(isarProvider));
});

final getSettingsUseCaseProvider = Provider<GetSettingsUseCase>((ref) {
  return GetSettingsUseCase(ref.read(settingsRepositoryProvider));
});

final updateSettingsUseCaseProvider = Provider<UpdateSettingsUseCase>((ref) {
  return UpdateSettingsUseCase(ref.read(settingsRepositoryProvider));
});

final settingsNotifierProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettingsEntity>(
  SettingsNotifier.new,
);
