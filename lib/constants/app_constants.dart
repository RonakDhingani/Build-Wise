abstract class AppConstants {
  // Database
  static const int dbSchemaVersion = 1;
  static const int appSettingsId = 0;

  // Defaults
  static const String defaultCurrencyCode = 'INR';
  static const String defaultCurrencySymbol = '₹';
  static const String defaultDateFormat = 'dd/MM/yyyy';

  // Stage defaults
  static const List<String> defaultStageNames = [
    'Foundation',
    'Structure',
    'Brick Work',
    'Plaster',
    'Flooring',
    'Electrical',
    'Plumbing',
    'Painting',
    'Interior',
    'Exterior',
  ];

  // Expense category defaults
  static const List<String> defaultCategoryNames = [
    'Materials',
    'Labor',
    'Electrical',
    'Plumbing',
    'Interior',
    'Exterior',
    'Transportation',
    'Equipment',
    'Government Fees',
    'Other',
  ];

  // Budget health thresholds
  static const double budgetWarningThreshold = 0.75;
  static const double budgetCriticalThreshold = 0.90;

  // Image compression
  static const int imageMaxSizeKb = 1024;
  static const int thumbnailSizeKb = 100;
  static const int imageQuality = 80;
  static const int thumbnailSize = 200;

  // UI
  static const int recentExpensesCount = 5;
  static const double lowStockThreshold = 0.1;

  // Animation durations (ms)
  static const int animationFast = 150;
  static const int animationNormal = 300;
  static const int animationSlow = 500;

  // Success dialog auto-dismiss (ms)
  static const int successDialogDuration = 2000;
}
