import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.light(
          primary: LightThemeColors.primary,
          onPrimary: LightThemeColors.textOnPrimary,
          secondary: LightThemeColors.secondary,
          onSecondary: LightThemeColors.textOnSecondary,
          surface: LightThemeColors.surface,
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
        cardTheme: CardThemeData(
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
            borderSide: const BorderSide(color: LightThemeColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: LightThemeColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: LightThemeColors.borderFocus, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.error500),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.error500, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
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
            minimumSize: const Size(double.infinity, AppDimensions.buttonHeightLg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            textStyle: AppTextStyles.labelLarge,
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: LightThemeColors.primary,
            minimumSize: const Size(double.infinity, AppDimensions.buttonHeightLg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            side: const BorderSide(color: LightThemeColors.primary, width: 1.5),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: LightThemeColors.primary,
            textStyle: AppTextStyles.labelLarge,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: LightThemeColors.surface,
          selectedItemColor: LightThemeColors.primary,
          unselectedItemColor: LightThemeColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        dividerTheme: const DividerThemeData(
          color: LightThemeColors.divider,
          thickness: 1,
          space: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: LightThemeColors.primary,
          foregroundColor: LightThemeColors.textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.neutral100,
          labelStyle: AppTextStyles.labelSmall,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
        ),
        // Popup / overflow menus open directly under their trigger, rounded.
        popupMenuTheme: PopupMenuThemeData(
          color: LightThemeColors.surface,
          elevation: 3,
          position: PopupMenuPosition.under,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTextStyles.bodyMedium,
        ),
        // MenuAnchor menus (AppDropdownField) — rounded surface, opens below.
        menuTheme: MenuThemeData(
          style: MenuStyle(
            elevation: const WidgetStatePropertyAll(3),
            backgroundColor:
                const WidgetStatePropertyAll(LightThemeColors.surface),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: AppSpacing.xs),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
          ),
        ),
        // Material 3 DropdownMenu (where used) opens below + matches field width.
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            elevation: const WidgetStatePropertyAll(3),
            backgroundColor:
                const WidgetStatePropertyAll(LightThemeColors.surface),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
          ),
        ),
      );

  static ThemeData get dark => light;
}
