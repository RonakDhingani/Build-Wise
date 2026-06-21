import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class AppExpenseCard extends StatelessWidget {
  const AppExpenseCard({
    super.key,
    required this.categoryName,
    required this.categoryColor,
    required this.amount,
    required this.formattedAmount,
    this.description,
    this.vendorName,
    this.formattedDate,
    this.paymentTypeLabel,
    this.onTap,
    this.onDelete,
  });

  final String categoryName;
  final Color categoryColor;
  final double amount;
  final String formattedAmount;
  final String? description;
  final String? vendorName;
  final String? formattedDate;
  final String? paymentTypeLabel;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: LightThemeColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description?.isNotEmpty == true ? description! : categoryName,
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      if (vendorName != null) ...[
                        Text(vendorName!, style: AppTextStyles.bodySmall.copyWith(
                          color: LightThemeColors.textSecondary,
                        )),
                        Text(' · ', style: AppTextStyles.bodySmall.copyWith(
                          color: LightThemeColors.textTertiary,
                        )),
                      ],
                      if (formattedDate != null)
                        Text(formattedDate!, style: AppTextStyles.bodySmall.copyWith(
                          color: LightThemeColors.textTertiary,
                        )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formattedAmount, style: AppTextStyles.titleSmall.copyWith(
                  color: LightThemeColors.primary,
                )),
                if (paymentTypeLabel != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      paymentTypeLabel!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: LightThemeColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
