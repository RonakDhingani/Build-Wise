import '../../../../constants/app_constants.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../models/app_settings_isar_model.dart';

class AppSettingsMapper {
  AppSettingsMapper._();

  static AppSettingsEntity toEntity(AppSettingsModel model) {
    return AppSettingsEntity(
      currencyCode: model.currencyCode,
      currencySymbol: model.currencySymbol,
      dateFormat: model.dateFormat,
      theme: model.theme,
      defaultProjectId: model.lastActiveProjectId,
    );
  }

  static AppSettingsModel toModel(AppSettingsEntity entity) {
    return AppSettingsModel()
      ..id = AppConstants.appSettingsId
      ..currencyCode = entity.currencyCode
      ..currencySymbol = entity.currencySymbol
      ..dateFormat = entity.dateFormat
      ..theme = entity.theme
      ..lastActiveProjectId = entity.defaultProjectId;
  }
}
