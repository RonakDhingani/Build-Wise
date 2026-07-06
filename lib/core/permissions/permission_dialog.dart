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

  /// Returns `true` if the user tapped "Open Settings", `false` otherwise.
  static Future<bool> show(BuildContext context, AppPermissionType type) async {
    final copy = PermissionHelper.rationale(type);
    final result = await showDialog<bool>(
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
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(true);
              // Delay until the dismiss animation completes before switching to
              // Settings. Calling openAppSettings() mid-animation blocks the
              // iOS main thread (mach_msg2_trap) and causes a SIGKILL/freeze on
              // return.
              await Future<void>.delayed(const Duration(milliseconds: 300));
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
    return result == true;
  }
}
