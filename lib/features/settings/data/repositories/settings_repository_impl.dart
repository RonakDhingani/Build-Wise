import 'package:isar/isar.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../mappers/app_settings_mapper.dart';
import '../models/app_settings_isar_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._isar);
  final Isar _isar;

  @override
  Future<Result<AppSettingsEntity>> getSettings() async {
    try {
      final model =
          await _isar.appSettingsModels.get(AppConstants.appSettingsId);
      if (model == null) {
        return const Success(
          AppSettingsEntity(
            currencyCode: AppConstants.defaultCurrencyCode,
            currencySymbol: AppConstants.defaultCurrencySymbol,
            dateFormat: AppConstants.defaultDateFormat,
            theme: AppThemeMode.light,
          ),
        );
      }
      return Success(AppSettingsMapper.toEntity(model));
    } catch (e) {
      return Failure(DatabaseFailure('Failed to load settings: $e'));
    }
  }

  @override
  Future<Result<AppSettingsEntity>> updateSettings(
    AppSettingsEntity entity,
  ) async {
    try {
      final model = AppSettingsMapper.toModel(entity);
      await _isar.writeTxn(() async {
        await _isar.appSettingsModels.put(model);
      });
      return Success(entity);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to save settings: $e'));
    }
  }
}
