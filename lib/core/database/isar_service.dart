import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/project/data/models/project_isar_model.dart';
import '../../features/stage/data/models/stage_isar_model.dart';
import '../../features/expense/data/models/expense_isar_model.dart';
import '../../features/expense/data/models/expense_category_isar_model.dart';
import '../../features/material/data/models/material_isar_model.dart';
import '../../features/photo/data/models/photo_isar_model.dart';
import '../../features/settings/data/models/app_settings_isar_model.dart';
import '../../constants/app_constants.dart';

class IsarService {
  IsarService._();

  static Isar? _instance;

  static Isar get instance {
    assert(_instance != null, 'IsarService not initialized. Call init() first.');
    return _instance!;
  }

  static Future<Isar> init() async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationDocumentsDirectory();

    _instance = await Isar.open(
      [
        ProjectModelSchema,
        StageModelSchema,
        ExpenseModelSchema,
        ExpenseCategoryModelSchema,
        MaterialModelSchema,
        PhotoModelSchema,
        AppSettingsModelSchema,
      ],
      directory: dir.path,
      name: 'build_wise',
      inspector: false,
    );

    await _seedInitialData(_instance!);

    return _instance!;
  }

  static Future<void> _seedInitialData(Isar isar) async {
    final settings = await isar.appSettingsModels.get(AppConstants.appSettingsId);

    if (settings != null) return;

    await isar.writeTxn(() async {
      // Seed app settings
      final defaultSettings = AppSettingsModel()
        ..id = AppConstants.appSettingsId
        ..currencyCode = AppConstants.defaultCurrencyCode
        ..currencySymbol = AppConstants.defaultCurrencySymbol
        ..dateFormat = AppConstants.defaultDateFormat
        ..theme = AppThemeMode.light;

      await isar.appSettingsModels.put(defaultSettings);

      // Seed default expense categories
      final now = DateTime.now();
      final categories = AppConstants.defaultCategoryNames.map((name) {
        return ExpenseCategoryModel()
          ..name = name
          ..isDefault = true
          ..createdAt = now;
      }).toList();

      await isar.expenseCategoryModels.putAll(categories);
    });
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
