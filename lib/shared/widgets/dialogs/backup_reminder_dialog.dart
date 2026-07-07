import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../buttons/app_outline_button.dart';
import '../buttons/app_primary_button.dart';

/// User's choice from the one-time backup reminder dialog.
enum BackupReminderChoice { later, backupNow }

/// Premium Material 3 one-time reminder nudging the user to back up their
/// offline data. Non-dismissible (a choice must be made) so the flag is always
/// persisted and the dialog can never re-appear. Pure UI — the caller handles
/// persistence and navigation based on the returned [BackupReminderChoice].
class BackupReminderDialog {
  BackupReminderDialog._();

  static bool _isVisible = false;

  static Future<BackupReminderChoice?> show(BuildContext context) async {
    if (_isVisible) return null;
    _isVisible = true;
    try {
      return await showDialog<BackupReminderChoice>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const PopScope(
          canPop: false,
          child: _BackupReminderBody(),
        ),
      );
    } finally {
      _isVisible = false;
    }
  }
}

class _BackupReminderBody extends StatelessWidget {
  const _BackupReminderBody();

  static const _message =
      'BuildWise stores all your project data only on this device.\n\n'
      'If you uninstall the app, reset your device, or switch to another '
      'phone, your data cannot be recovered unless you\'ve created a backup.\n\n'
      'We recommend creating regular backups to keep your projects safe.';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        LightThemeColors.primary,
                        LightThemeColors.primaryDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.white,
                    size: AppDimensions.iconLg,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Text(
                  'Protect Your Project Data',
                  style: AppTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: LightThemeColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: AppOutlineButton(
                      label: 'Later',
                      onPressed: () => Navigator.of(context)
                          .pop(BackupReminderChoice.later),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppPrimaryButton(
                      label: 'Backup Now',
                      icon: Icons.archive_outlined,
                      onPressed: () => Navigator.of(context)
                          .pop(BackupReminderChoice.backupNow),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
