import '../../../../core/result/result.dart';
import '../entities/app_settings_entity.dart';
import '../repositories/settings_repository.dart';

class UpdateSettingsUseCase {
  const UpdateSettingsUseCase(this._repository);
  final SettingsRepository _repository;

  Future<Result<AppSettingsEntity>> execute(AppSettingsEntity entity) {
    return _repository.updateSettings(entity);
  }
}
