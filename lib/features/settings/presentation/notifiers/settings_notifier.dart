import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../providers/settings_providers.dart';

class SettingsNotifier extends AsyncNotifier<AppSettingsEntity> {
  @override
  Future<AppSettingsEntity> build() async {
    return _load();
  }

  Future<AppSettingsEntity> _load() async {
    final useCase = ref.read(getSettingsUseCaseProvider);
    final result = await useCase.execute();
    return result.when(
      success: (data) => data,
      failure: (f) => throw Exception(f.message),
    );
  }

  Future<void> _save(AppSettingsEntity entity) async {
    final useCase = ref.read(updateSettingsUseCaseProvider);
    final result = await useCase.execute(entity);
    result.when(
      success: (saved) => state = AsyncData(saved),
      failure: (f) => throw Exception(f.message),
    );
  }

  Future<void> updateCurrency(String code, String symbol) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _save(current.copyWith(currencyCode: code, currencySymbol: symbol));
  }

  Future<void> updateDateFormat(String pattern) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _save(current.copyWith(dateFormat: pattern));
  }

  Future<void> updateTheme(AppThemeMode theme) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _save(current.copyWith(theme: theme));
  }

  Future<void> setDefaultProject(int? projectId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _save(current.copyWith(
      defaultProjectId: projectId,
      clearDefaultProject: projectId == null,
    ));
  }
}
