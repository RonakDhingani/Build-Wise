import 'package:isar/isar.dart';

part 'app_settings_isar_model.g.dart';

@Collection()
class AppSettingsModel {
  Id id = 0;

  late String currencyCode;
  late String currencySymbol;
  late String dateFormat;
  int? lastActiveProjectId;

  @Enumerated(EnumType.name)
  late AppThemeMode theme;
}

enum AppThemeMode { light, dark }
