import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary — Deep Navy
  static const Color navy900 = Color(0xFF0A1628);
  static const Color navy800 = Color(0xFF0D1F3C);
  static const Color navy700 = Color(0xFF112952);
  static const Color navy600 = Color(0xFF1A3A6B);
  static const Color navy500 = Color(0xFF1E4D8C);
  static const Color navy400 = Color(0xFF2E6DB4);
  static const Color navy300 = Color(0xFF5B8FC9);
  static const Color navy200 = Color(0xFF9BBDE0);
  static const Color navy100 = Color(0xFFD4E5F4);
  static const Color navy50 = Color(0xFFEBF3FA);

  // Secondary — Construction Gold
  static const Color gold600 = Color(0xFF8B5E00);
  static const Color gold500 = Color(0xFFB07800);
  static const Color gold400 = Color(0xFFD4920A);
  static const Color gold300 = Color(0xFFE8AE2E);
  static const Color gold200 = Color(0xFFF5CC6E);
  static const Color gold100 = Color(0xFFFAE5A8);
  static const Color gold50 = Color(0xFFFDF5DE);

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
  static const Color neutral50 = Color(0xFFFAFAFC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Semantic
  static const Color success500 = Color(0xFF16A34A);
  static const Color success100 = Color(0xFFDCFCE7);
  static const Color warning500 = Color(0xFFD97706);
  static const Color warning100 = Color(0xFFFEF3C7);
  static const Color error500 = Color(0xFFDC2626);
  static const Color error100 = Color(0xFFFEE2E2);
  static const Color info500 = Color(0xFF0EA5E9);
  static const Color info100 = Color(0xFFE0F2FE);

  // Accent / category palette — distinct hues for category tags, material
  // tints and chart series that have no intrinsic brand color.
  static const Color violet = Color(0xFF8B5CF6);
  static const Color indigo = Color(0xFF5C6BC0);
  static const Color teal = Color(0xFF26A69A);
  static const Color red = Color(0xFFEF5350);
  static const Color orange = Color(0xFFFFA726);
  static const Color green = Color(0xFF66BB6A);
  static const Color blue = Color(0xFF42A5F5);
  static const Color purple = Color(0xFFAB47BC);
  static const Color pink = Color(0xFFEC407A);
  static const Color brown = Color(0xFF8D6E63);
  static const Color blueGrey = Color(0xFF78909C);

  /// Cyclic palette for category color assignment (expense categories).
  static const List<Color> categoryPalette = [
    indigo,
    teal,
    red,
    orange,
    green,
    blue,
    purple,
    pink,
    brown,
    blueGrey,
  ];
}

/// Semantic scrim/overlay colors (black with alpha) for image viewers,
/// gradients and modal scrims — single source for "black tint" usage.
abstract class AppOverlays {
  static const Color scrim = Color(0x8A000000); // black 54%
  static const Color scrimStrong = Color(0xDE000000); // black 87%
  static const Color scrimSoft = Color(0x59000000); // black ~35%
}

abstract class LightThemeColors {
  // Brand
  static const Color primary = AppColors.navy500;
  static const Color primaryDark = AppColors.navy700;
  static const Color primaryLight = AppColors.navy100;
  static const Color secondary = AppColors.gold400;
  static const Color secondaryLight = AppColors.gold100;

  // Background
  static const Color background = AppColors.neutral50;
  static const Color surface = AppColors.white;
  static const Color surfaceElevated = AppColors.white;
  static const Color cardBg = AppColors.white;

  // Text
  static const Color textPrimary = AppColors.neutral900;
  static const Color textSecondary = AppColors.neutral600;
  static const Color textTertiary = AppColors.neutral400;
  static const Color textOnPrimary = AppColors.white;
  static const Color textOnSecondary = AppColors.neutral900;

  // Border
  static const Color border = AppColors.neutral200;
  static const Color borderFocus = AppColors.navy500;

  // Status
  static const Color budgetHealthy = AppColors.success500;
  static const Color budgetWarning = AppColors.warning500;
  static const Color budgetCritical = AppColors.error500;

  // Interactive
  static const Color divider = AppColors.neutral200;
  static const Color shimmer = AppColors.neutral100;
  static const Color shimmerHighlight = AppColors.neutral50;
}
