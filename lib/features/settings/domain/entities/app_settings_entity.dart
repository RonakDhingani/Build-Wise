import '../../data/models/app_settings_isar_model.dart' show AppThemeMode;

export '../../data/models/app_settings_isar_model.dart' show AppThemeMode;

class AppSettingsEntity {
  const AppSettingsEntity({
    required this.currencyCode,
    required this.currencySymbol,
    required this.dateFormat,
    required this.theme,
    this.defaultProjectId,
  });

  final String currencyCode;
  final String currencySymbol;
  final String dateFormat;
  final AppThemeMode theme;

  /// Project opened automatically on app launch.
  /// Backed by [AppSettingsModel.lastActiveProjectId].
  final int? defaultProjectId;

  AppSettingsEntity copyWith({
    String? currencyCode,
    String? currencySymbol,
    String? dateFormat,
    AppThemeMode? theme,
    int? defaultProjectId,
    bool clearDefaultProject = false,
  }) {
    return AppSettingsEntity(
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      dateFormat: dateFormat ?? this.dateFormat,
      theme: theme ?? this.theme,
      defaultProjectId:
          clearDefaultProject ? null : (defaultProjectId ?? this.defaultProjectId),
    );
  }
}
