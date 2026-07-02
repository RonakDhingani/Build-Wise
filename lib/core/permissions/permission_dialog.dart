import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'permission_helper.dart';
import 'permission_service.dart';

/// Shown when a permission is permanently denied / restricted. Explains why the
/// permission is needed and offers a jump to system Settings.
class PermissionDialog {
  PermissionDialog._();

  static Future<void> show(BuildContext context, AppPermissionType type) {
    final copy = PermissionHelper.rationale(type);
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(copy.title, style: AppTextStyles.titleLarge),
        content: Text(
          copy.message,
          style: AppTextStyles.bodyMedium
              .copyWith(color: LightThemeColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            style: TextButton.styleFrom(foregroundColor: LightThemeColors.primary),
            child: Text('Open Settings',
                style: AppTextStyles.labelLarge.copyWith(
                    color: LightThemeColors.primary,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
