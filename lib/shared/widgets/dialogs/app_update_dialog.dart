import 'package:flutter/material.dart';

import '../../../core/firebase/remote_config/version_checker.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../buttons/app_outline_button.dart';
import '../buttons/app_primary_button.dart';

/// Premium Material 3 update dialog.
/// * Optional update -> dismissible, "Later" + "Update".
/// * Force update -> non-dismissible (no back / outside tap / swipe), "Update Now".
///
/// Pure UI: it calls [onUpdate] / [onLater]; analytics + store logic live in the
/// caller. Self-guards duplicates via [_isVisible].
class AppUpdateDialog {
  AppUpdateDialog._();

  static bool _isVisible = false;
  static bool get isVisible => _isVisible;
  static BuildContext? _dialogCtx;

  /// Programmatically close the dialog (e.g. a resume re-check found the user
  /// is now up to date). Works even for the non-dismissible forced dialog.
  static void dismiss() {
    if (_isVisible && _dialogCtx != null && _dialogCtx!.mounted) {
      Navigator.of(_dialogCtx!).pop();
    }
  }

  static Future<void> show(
    BuildContext context, {
    required UpdateDecision decision,
    required VoidCallback onUpdate,
    VoidCallback? onLater,
  }) async {
    if (_isVisible) return;
    _isVisible = true;

    final force = decision.isForced;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: !force,
        builder: (ctx) {
          _dialogCtx = ctx;
          return PopScope(
          canPop: !force,
          child: _UpdateDialogBody(
            decision: decision,
            onLater: force
                ? null
                : () {
                    onLater?.call();
                    Navigator.of(ctx).pop();
                  },
            onUpdate: () {
              onUpdate();
              if (!force && Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
            },
          ),
          );
        },
      );
    } finally {
      _isVisible = false;
      _dialogCtx = null;
    }
  }
}

class _UpdateDialogBody extends StatelessWidget {
  const _UpdateDialogBody({
    required this.decision,
    required this.onUpdate,
    this.onLater,
  });

  final UpdateDecision decision;
  final VoidCallback onUpdate;
  final VoidCallback? onLater;

  @override
  Widget build(BuildContext context) {
    final config = decision.config;
    final force = decision.isForced;
    final title = config.updateTitle.trim().isNotEmpty
        ? config.updateTitle
        : 'New Version Available';
    final message = config.updateMessage.trim().isNotEmpty
        ? config.updateMessage
        : 'A new version of BuildWise is available.';
    final notes = config.releaseNoteLines;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      insetPadding: const EdgeInsets.all(AppSpacing.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
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
                      colors: [LightThemeColors.primary, LightThemeColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  child: const Icon(Icons.system_update_rounded,
                      color: AppColors.white, size: AppDimensions.iconLg),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Text(title,
                    style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: LightThemeColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Version comparison: Current -> Latest, plus minimum required.
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _VersionCell(label: 'Current', value: decision.currentVersion),
                        Icon(Icons.arrow_forward_rounded,
                            color: LightThemeColors.textTertiary,
                            size: AppDimensions.iconSm),
                        _VersionCell(
                            label: 'Latest',
                            value: decision.targetVersion,
                            highlight: true),
                      ],
                    ),
                    if (force) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Minimum required: ${decision.minRequiredVersion}',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.error500),
                      ),
                    ],
                  ],
                ),
              ),

              if (notes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text("What's New", style: AppTextStyles.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                ...notes.map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•  ',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: LightThemeColors.primary)),
                        Expanded(
                          child: Text(l,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: LightThemeColors.textSecondary)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              if (force)
                AppPrimaryButton(label: 'Update Now', onPressed: onUpdate)
              else
                Row(
                  children: [
                    Expanded(
                      child: AppOutlineButton(label: 'Later', onPressed: onLater),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppPrimaryButton(label: 'Update', onPressed: onUpdate),
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

class _VersionCell extends StatelessWidget {
  const _VersionCell({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: LightThemeColors.textTertiary)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              color: highlight ? LightThemeColors.primary : LightThemeColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
