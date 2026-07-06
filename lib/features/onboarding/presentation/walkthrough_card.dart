import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import 'walkthrough_step.dart';

/// Premium spotlight content card: step counter, title, short description and
/// Skip / Next actions. Used as the [TargetContent] child for every coach
/// step so the tour looks consistent.
class WalkthroughCard extends StatelessWidget {
  const WalkthroughCard({
    super.key,
    required this.step,
    required this.onSkip,
    this.onNext,
    this.nextLabel = 'Next',
    this.hint,
    this.maxHeight,
  });

  final WalkStep step;
  final VoidCallback onSkip;

  /// When null, the Next button is hidden (e.g. a gated step that advances on
  /// the user tapping the highlighted widget instead).
  final VoidCallback? onNext;
  final String nextLabel;

  /// Optional helper line shown in place of the Next button (gated steps).
  final String? hint;

  /// Hard cap on the card height for the current placement. When the content
  /// would exceed it (very small screens / large fonts) the card scrolls
  /// internally instead of overflowing off-screen.
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    // Fit within the viewport width too: full-width on phones, capped on
    // tablets. Leaves room for the coach's own horizontal padding.
    final availWidth = MediaQuery.of(context).size.width - 48;
    final card = Container(
      constraints: BoxConstraints(
        maxWidth: availWidth < 360 ? availWidth : 360,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: LightThemeColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step counter chip.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: LightThemeColors.primaryLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Text(
              '${step.number} of ${WalkStepX.totalSteps}',
              style: AppTextStyles.labelSmall.copyWith(
                color: LightThemeColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(step.title, style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            step.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: LightThemeColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Content-sized tap targets (no Material buttons): the coach lays
          // content out with an unbounded width, which makes ElevatedButton's
          // infinite maximumSize force an invalid infinite-width constraint.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onSkip,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    'Skip',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: LightThemeColors.textSecondary,
                    ),
                  ),
                ),
              ),
              if (onNext != null)
                GestureDetector(
                  onTap: onNext,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: LightThemeColors.primary,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: Text(
                      nextLabel,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                )
              else if (hint != null)
                Text(
                  hint!,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: LightThemeColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    if (maxHeight == null) return card;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight!),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: card,
      ),
    );
  }
}
