import '../../../../core/result/result.dart';
import '../entities/app_settings_entity.dart';
import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  const GetSettingsUseCase(this._repository);
  final SettingsRepository _repository;

  Future<Result<AppSettingsEntity>> execute() {
    return _repository.getSettings();
  }
}
