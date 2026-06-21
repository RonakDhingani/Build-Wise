import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.navy900.withValues(alpha:0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: AppColors.navy900.withValues(alpha:0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get sheet => [
        BoxShadow(
          color: AppColors.navy900.withValues(alpha:0.12),
          blurRadius: 24,
          offset: const Offset(0, -4),
        ),
      ];

  static List<BoxShadow> get button => [
        BoxShadow(
          color: LightThemeColors.primary.withValues(alpha:0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
}
