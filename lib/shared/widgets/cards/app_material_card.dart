import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class AppMaterialCard extends StatelessWidget {
  const AppMaterialCard({
    super.key,
    required this.name,
    required this.unitLabel,
    required this.quantityPurchased,
    required this.quantityUsed,
    this.totalCost,
    this.formattedCost,
    this.onTap,
  });

  final String name;
  final String unitLabel;
  final double quantityPurchased;
  final double quantityUsed;
  final double? totalCost;
  final String? formattedCost;
  final VoidCallback? onTap;

  double get _usedRatio =>
      quantityPurchased > 0 ? (quantityUsed / quantityPurchased).clamp(0.0, 1.0) : 0.0;

  Color get _statusColor {
    final remaining = quantityPurchased - quantityUsed;
    final ratio = quantityPurchased > 0 ? remaining / quantityPurchased : 1.0;
    if (ratio <= 0) return AppColors.error500;
    if (ratio <= 0.1) return AppColors.warning500;
    return AppColors.success500;
  }

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
          border: Border(
            left: BorderSide(color: _statusColor, width: 3),
          ),
        ),
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
                if (formattedCost != null)
                  Text(formattedCost!, style: AppTextStyles.titleSmall.copyWith(
                    color: LightThemeColors.primary,
                  )),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Used: ${quantityUsed.toStringAsFixed(1)} / ${quantityPurchased.toStringAsFixed(1)} $unitLabel',
              style: AppTextStyles.bodySmall.copyWith(
                color: LightThemeColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              child: LinearProgressIndicator(
                value: _usedRatio,
                minHeight: AppDimensions.progressBarThin,
                backgroundColor: AppColors.neutral200,
                valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
