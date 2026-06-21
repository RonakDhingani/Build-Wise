# BuildWise — Design System

All values centralized. No hardcoded colors, sizes, strings, or fonts in widgets.

---

## 1. Color System

### AppColors (Raw Palette)

```dart
// lib/theme/app_colors.dart

abstract class AppColors {
  // Primary — Deep Navy
  static const Color navy900 = Color(0xFF0A1628);
  static const Color navy800 = Color(0xFF0D1F3C);
  static const Color navy700 = Color(0xFF112952);
  static const Color navy600 = Color(0xFF1A3A6B);
  static const Color navy500 = Color(0xFF1E4D8C);  // primary brand
  static const Color navy400 = Color(0xFF2E6DB4);
  static const Color navy300 = Color(0xFF5B8FC9);
  static const Color navy200 = Color(0xFF9BBDE0);
  static const Color navy100 = Color(0xFFD4E5F4);
  static const Color navy50  = Color(0xFFEBF3FA);

  // Secondary — Construction Gold
  static const Color gold600 = Color(0xFF8B5E00);
  static const Color gold500 = Color(0xFFB07800);
  static const Color gold400 = Color(0xFFD4920A);  // secondary brand
  static const Color gold300 = Color(0xFFE8AE2E);
  static const Color gold200 = Color(0xFFF5CC6E);
  static const Color gold100 = Color(0xFFFAE5A8);
  static const Color gold50  = Color(0xFFFDF5DE);

  // Neutral
  static const Color neutral900 = Color(0xFF1A1A2E);
  static const Color neutral800 = Color(0xFF2D2D44);
  static const Color neutral700 = Color(0xFF4A4A6A);
  static const Color neutral600 = Color(0xFF6B6B8A);
  static const Color neutral500 = Color(0xFF8E8EA8);
  static const Color neutral400 = Color(0xFFB2B2C8);
  static const Color neutral300 = Color(0xFFD1D1E0);
  static const Color neutral200 = Color(0xFFE8E8F0);
  static const Color neutral100 = Color(0xFFF4F4F8);
  static const Color neutral50  = Color(0xFFFAFAFC);
  static const Color white      = Color(0xFFFFFFFF);

  // Semantic
  static const Color success500 = Color(0xFF16A34A);
  static const Color success100 = Color(0xFFDCFCE7);
  static const Color warning500 = Color(0xFFD97706);
  static const Color warning100 = Color(0xFFFEF3C7);
  static const Color error500   = Color(0xFFDC2626);
  static const Color error100   = Color(0xFFFEE2E2);
  static const Color info500    = Color(0xFF0EA5E9);
  static const Color info100    = Color(0xFFE0F2FE);
}
```

### LightThemeColors (Semantic Tokens)

```dart
// lib/theme/app_colors.dart (continued)

abstract class LightThemeColors {
  // Brand
  static const Color primary      = AppColors.navy500;
  static const Color primaryDark  = AppColors.navy700;
  static const Color primaryLight = AppColors.navy100;
  static const Color secondary    = AppColors.gold400;
  static const Color secondaryLight = AppColors.gold100;

  // Background
  static const Color background   = AppColors.neutral50;   // #FAFAFC
  static const Color surface      = AppColors.white;
  static const Color surfaceElevated = AppColors.white;
  static const Color cardBg       = AppColors.white;

  // Text
  static const Color textPrimary  = AppColors.neutral900;
  static const Color textSecondary = AppColors.neutral600;
  static const Color textTertiary = AppColors.neutral400;
  static const Color textOnPrimary = AppColors.white;
  static const Color textOnSecondary = AppColors.neutral900;

  // Border
  static const Color border       = AppColors.neutral200;
  static const Color borderFocus  = AppColors.navy500;

  // Status
  static const Color budgetHealthy  = AppColors.success500;
  static const Color budgetWarning  = AppColors.warning500;
  static const Color budgetCritical = AppColors.error500;

  // Interactive
  static const Color divider      = AppColors.neutral200;
  static const Color shimmer      = AppColors.neutral100;
  static const Color shimmerHighlight = AppColors.neutral50;
}
```

---

## 2. Typography System

```dart
// lib/theme/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // or bundled Inter

abstract class AppTextStyles {
  static TextStyle get _base => const TextStyle(
    fontFamily: 'Inter',
    color: LightThemeColors.textPrimary,
    letterSpacing: -0.1,
  );

  // Display — hero numbers (budget amounts)
  static TextStyle get displayLarge => _base.copyWith(
    fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -1.5);
  static TextStyle get displayMedium => _base.copyWith(
    fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -1.0);
  static TextStyle get displaySmall => _base.copyWith(
    fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -0.5);

  // Headline — screen titles
  static TextStyle get headlineLarge => _base.copyWith(
    fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5);
  static TextStyle get headlineMedium => _base.copyWith(
    fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.3);
  static TextStyle get headlineSmall => _base.copyWith(
    fontSize: 20, fontWeight: FontWeight.w600);

  // Title — card headers, section headers
  static TextStyle get titleLarge => _base.copyWith(
    fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle get titleMedium => _base.copyWith(
    fontSize: 16, fontWeight: FontWeight.w600);
  static TextStyle get titleSmall => _base.copyWith(
    fontSize: 14, fontWeight: FontWeight.w600);

  // Body — general content
  static TextStyle get bodyLarge => _base.copyWith(
    fontSize: 16, fontWeight: FontWeight.w400);
  static TextStyle get bodyMedium => _base.copyWith(
    fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle get bodySmall => _base.copyWith(
    fontSize: 12, fontWeight: FontWeight.w400);

  // Label — chips, badges, buttons
  static TextStyle get labelLarge => _base.copyWith(
    fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1);
  static TextStyle get labelMedium => _base.copyWith(
    fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5);
  static TextStyle get labelSmall => _base.copyWith(
    fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5);

  // Mono — amounts, percentages
  static TextStyle get monoLarge => _base.copyWith(
    fontFamily: 'RobotoMono', fontSize: 20, fontWeight: FontWeight.w600);
  static TextStyle get monoMedium => _base.copyWith(
    fontFamily: 'RobotoMono', fontSize: 16, fontWeight: FontWeight.w500);
}
```

---

## 3. Spacing System

```dart
// lib/theme/app_spacing.dart

abstract class AppSpacing {
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
  static const double giant = 64.0;

  // Page margins
  static const double pageHorizontal = 16.0;
  static const double pageVertical   = 20.0;

  // Card
  static const double cardPadding  = 16.0;
  static const double cardGap      = 12.0;

  // Section
  static const double sectionGap    = 24.0;
  static const double itemGap       = 8.0;
}

abstract class AppDimensions {
  // Border radius
  static const double radiusXs  = 4.0;
  static const double radiusSm  = 8.0;
  static const double radiusMd  = 12.0;
  static const double radiusLg  = 16.0;
  static const double radiusXl  = 20.0;
  static const double radiusFull = 100.0;   // pill/chip shape

  // Icons
  static const double iconXs  = 16.0;
  static const double iconSm  = 20.0;
  static const double iconMd  = 24.0;
  static const double iconLg  = 32.0;
  static const double iconXl  = 48.0;

  // Touch targets
  static const double minTouchTarget = 48.0;

  // App bar
  static const double appBarHeight = 56.0;

  // Bottom nav
  static const double bottomNavHeight = 64.0;

  // Button heights
  static const double buttonHeightLg = 52.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightSm = 36.0;

  // Avatar
  static const double avatarSm  = 32.0;
  static const double avatarMd  = 48.0;
  static const double avatarLg  = 64.0;

  // Progress bar
  static const double progressBarHeight = 8.0;
  static const double progressBarThin = 4.0;

  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationCard = 2.0;
  static const double elevationSheet = 8.0;
  static const double elevationModal = 16.0;
}
```

---

## 4. Shadow System

```dart
// lib/theme/app_shadows.dart

abstract class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.navy900.withOpacity(0.06),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: AppColors.navy900.withOpacity(0.04),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get sheet => [
    BoxShadow(
      color: AppColors.navy900.withOpacity(0.12),
      blurRadius: 24,
      offset: Offset(0, -4),
    ),
  ];

  static List<BoxShadow> get button => [
    BoxShadow(
      color: LightThemeColors.primary.withOpacity(0.3),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
}
```

---

## 5. Material 3 Theme Configuration

```dart
// lib/theme/app_theme.dart

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.light(
      primary: LightThemeColors.primary,
      onPrimary: LightThemeColors.textOnPrimary,
      secondary: LightThemeColors.secondary,
      onSecondary: LightThemeColors.textOnSecondary,
      surface: LightThemeColors.surface,
      background: LightThemeColors.background,
      error: AppColors.error500,
      outline: LightThemeColors.border,
    ),
    scaffoldBackgroundColor: LightThemeColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: LightThemeColors.surface,
      foregroundColor: LightThemeColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.titleLarge,
    ),
    cardTheme: CardTheme(
      color: LightThemeColors.cardBg,
      elevation: AppDimensions.elevationCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LightThemeColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: LightThemeColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: LightThemeColors.borderFocus, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: LightThemeColors.textSecondary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LightThemeColors.primary,
        foregroundColor: LightThemeColors.textOnPrimary,
        minimumSize: Size(double.infinity, AppDimensions.buttonHeightLg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        textStyle: AppTextStyles.labelLarge,
        elevation: 0,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: LightThemeColors.surface,
      selectedItemColor: LightThemeColors.primary,
      unselectedItemColor: LightThemeColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  // Future dark theme placeholder
  static ThemeData get dark => light; // implement in V2
}
```

---

## 6. Stage Status Colors

```dart
abstract class StageStatusColors {
  static Color background(StageStatus status) => switch (status) {
    StageStatus.notStarted => AppColors.neutral100,
    StageStatus.inProgress => AppColors.navy50,
    StageStatus.completed  => AppColors.success100,
    StageStatus.onHold     => AppColors.warning100,
  };

  static Color foreground(StageStatus status) => switch (status) {
    StageStatus.notStarted => AppColors.neutral600,
    StageStatus.inProgress => AppColors.navy500,
    StageStatus.completed  => AppColors.success500,
    StageStatus.onHold     => AppColors.warning500,
  };
}
```

---

## 7. Budget Health Colors

```dart
abstract class BudgetHealthColors {
  static Color color(double spentPercent) {
    if (spentPercent < 0.75) return AppColors.success500;
    if (spentPercent < 0.90) return AppColors.warning500;
    return AppColors.error500;
  }

  static Color background(double spentPercent) {
    if (spentPercent < 0.75) return AppColors.success100;
    if (spentPercent < 0.90) return AppColors.warning100;
    return AppColors.error100;
  }
}
```

---

## 8. Category Colors

```dart
abstract class CategoryColors {
  static const Map<String, Color> _map = {
    'Materials':        Color(0xFF6366F1),
    'Labor':            Color(0xFFEC4899),
    'Electrical':       Color(0xFFF59E0B),
    'Plumbing':         Color(0xFF06B6D4),
    'Interior':         Color(0xFF8B5CF6),
    'Exterior':         Color(0xFF10B981),
    'Transportation':   Color(0xFFF97316),
    'Equipment':        Color(0xFF64748B),
    'Government Fees':  Color(0xFFEF4444),
    'Other':            Color(0xFF94A3B8),
  };

  static Color forCategory(String name) =>
      _map[name] ?? AppColors.neutral500;
}
```
