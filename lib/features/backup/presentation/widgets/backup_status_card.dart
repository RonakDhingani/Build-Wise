import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_shadows.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../providers/backup_prefs_providers.dart';

/// Backup Status card shown at the top of Settings → Backup & Restore.
///
/// * Before any backup: "Last Backup: Never" with a warning tone and a
///   Create Backup call to action.
/// * After a successful backup: the last backup date & time plus an
///   "up to date" success indicator. Updates automatically after each export.
class BackupStatusCard extends ConsumerWidget {
  const BackupStatusCard({
    super.key,
    required this.onCreateBackup,
    this.highlighted = false,
  });

  /// Triggered by the Create Backup button (before any backup exists).
  final VoidCallback onCreateBackup;

  /// Briefly emphasised when the user arrived here via the reminder's
  /// "Backup Now" action.
  final bool highlighted;

  static final _dateTimeFormat = DateFormat('dd MMM yyyy • hh:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(backupPrefsProvider).valueOrNull;
    final lastBackupAt = prefs?.lastBackupAt;
    final hasBackup = lastBackupAt != null;

    final accent = hasBackup ? AppColors.success500 : AppColors.gold400;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: LightThemeColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: AppShadows.card,
        border: Border.all(
          color: highlighted ? accent : Colors.transparent,
          width: highlighted ? 2 : 0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(
                  hasBackup
                      ? Icons.verified_outlined
                      : Icons.shield_outlined,
                  color: accent,
                  size: AppDimensions.iconMd,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Backup Status', style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            hasBackup
                                ? 'Last backup: '
                                    '${_dateTimeFormat.format(lastBackupAt)}'
                                : 'Last backup: Never',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: LightThemeColors.textSecondary,
                            ),
                          ),
                        ),
                        if (!hasBackup) ...[
                          const SizedBox(width: AppSpacing.xs),
                          const Text('⚠️', style: TextStyle(fontSize: 13)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (hasBackup)
            _SuccessIndicator()
          else ...[
            Text(
              'Keep your projects safe by creating regular backups.',
              style: AppTextStyles.bodySmall.copyWith(
                color: LightThemeColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              label: 'Create Backup',
              icon: Icons.archive_outlined,
              onPressed: onCreateBackup,
            ),
          ],
        ],
      ),
    );
  }
}

class _SuccessIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.success500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success500,
            size: AppDimensions.iconSm,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Backup is up to date',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.success500,
            ),
          ),
        ],
      ),
    );
  }
}
