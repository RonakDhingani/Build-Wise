import '../../../../core/result/result.dart';
import '../entities/app_settings_entity.dart';

abstract class SettingsRepository {
  Future<Result<AppSettingsEntity>> getSettings();
  Future<Result<AppSettingsEntity>> updateSettings(AppSettingsEntity entity);
}
