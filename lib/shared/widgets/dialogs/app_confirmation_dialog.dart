import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../../../constants/app_strings.dart';

class AppConfirmationDialog extends StatelessWidget {
  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = AppStrings.confirm,
    this.cancelLabel = AppStrings.cancel,
    required this.onConfirm,
    this.isDangerous = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final bool isDangerous;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = AppStrings.confirm,
    String cancelLabel = AppStrings.cancel,
    required VoidCallback onConfirm,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AppConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        isDangerous: isDangerous,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTextStyles.titleLarge),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: LightThemeColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          style: TextButton.styleFrom(
            foregroundColor: isDangerous ? AppColors.error500 : LightThemeColors.primary,
          ),
          child: Text(confirmLabel, style: AppTextStyles.labelLarge.copyWith(
            color: isDangerous ? AppColors.error500 : LightThemeColors.primary,
            fontWeight: FontWeight.w700,
          )),
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md,
      ),
    );
  }
}
