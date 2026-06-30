abstract class AppConstants {
  // Database
  static const int dbSchemaVersion = 1;
  static const int appSettingsId = 0;

  // App info. Version + build number are NOT hardcoded — read live from
  // package_info_plus (single source: pubspec `version:`). Used in About screen,
  // update checks and backup manifest.
  static const String supportEmail = 'support.ronaklabs@gmail.com';

  // Website URLs (opened in-app via WebView)
  static const String websiteBase =
      'https://ronakdhingani.github.io/Build-Wise/website';
  static const String aboutUrl = '$websiteBase/index.html';
  static const String privacyPolicyUrl = '$websiteBase/privacy-policy.html';
  static const String termsUrl = '$websiteBase/terms-and-conditions.html';
  static const String contactSupportUrl = '$websiteBase/contact.html';

  // Currency options (Settings → Currency)
  static const List<({String code, String symbol, String label})>
      currencyOptions = [
    (code: 'INR', symbol: '₹', label: 'Indian Rupee'),
    (code: 'USD', symbol: '\$', label: 'US Dollar'),
    (code: 'EUR', symbol: '€', label: 'Euro'),
    (code: 'GBP', symbol: '£', label: 'British Pound'),
  ];

  // Date format options (Settings → Date Format)
  static const List<({String pattern, String label})> dateFormatOptions = [
    (pattern: 'dd/MM/yyyy', label: 'DD/MM/YYYY'),
    (pattern: 'MM/dd/yyyy', label: 'MM/DD/YYYY'),
  ];

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
