import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_strings.dart';

class AppSuccessDialog extends StatelessWidget {
  const AppSuccessDialog({
    super.key,
    required this.title,
    this.message,
    this.onDone,
  });

  final String title;
  final String? message;
  final VoidCallback? onDone;

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    VoidCallback? onDone,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AppSuccessDialog(
        title: title,
        message: message,
        onDone: onDone,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      const Duration(milliseconds: AppConstants.successDialogDuration),
      () {
        if (context.mounted) {
          Navigator.of(context).pop();
          onDone?.call();
        }
      },
    );

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          Icon(
            Icons.check_circle,
            size: AppDimensions.iconXl,
            color: AppColors.success500,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: LightThemeColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDone?.call();
          },
          child: Text(AppStrings.done),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md,
      ),
    );
  }
}
