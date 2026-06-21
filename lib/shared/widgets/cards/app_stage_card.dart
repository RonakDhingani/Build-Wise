import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

enum StageCardStatus { notStarted, inProgress, completed, onHold }

class AppStageCard extends StatelessWidget {
  const AppStageCard({
    super.key,
    required this.orderIndex,
    required this.name,
    required this.status,
    required this.progressPercent,
    this.startDate,
    this.endDate,
    this.onTap,
  });

  final int orderIndex;
  final String name;
  final StageCardStatus status;
  final int progressPercent;
  final String? startDate;
  final String? endDate;
  final VoidCallback? onTap;

  Color get _statusColor => switch (status) {
        StageCardStatus.notStarted => AppColors.neutral400,
        StageCardStatus.inProgress => AppColors.navy500,
        StageCardStatus.completed => AppColors.success500,
        StageCardStatus.onHold => AppColors.warning500,
      };

  String get _statusLabel => switch (status) {
        StageCardStatus.notStarted => 'Not Started',
        StageCardStatus.inProgress => 'In Progress',
        StageCardStatus.completed => 'Completed',
        StageCardStatus.onHold => 'On Hold',
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: LightThemeColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha:0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${orderIndex + 1}',
                  style: AppTextStyles.labelSmall.copyWith(color: _statusColor),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Text(
                          _statusLabel,
                          style: AppTextStyles.labelSmall.copyWith(color: _statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (startDate != null || endDate != null)
                    Text(
                      [startDate, endDate].whereType<String>().join(' → '),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: LightThemeColors.textTertiary,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          child: LinearProgressIndicator(
                            value: progressPercent / 100,
                            minHeight: AppDimensions.progressBarThin,
                            backgroundColor: AppColors.neutral200,
                            valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '$progressPercent%',
                        style: AppTextStyles.labelSmall.copyWith(color: _statusColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.drag_handle,
              color: AppColors.neutral300,
              size: AppDimensions.iconSm,
            ),
          ],
        ),
      ),
    );
  }
}
