import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.maxHeightFraction = 0.85,
    this.isScrollable = true,
    this.isDismissible = true,
  });

  final Widget child;
  final String? title;
  final double maxHeightFraction;
  final bool isScrollable;
  final bool isDismissible;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    double maxHeightFraction = 0.85,
    bool isScrollable = true,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppBottomSheet(
        title: title,
        maxHeightFraction: maxHeightFraction,
        isScrollable: isScrollable,
        isDismissible: isDismissible,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * maxHeightFraction),
      decoration: BoxDecoration(
        color: LightThemeColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
        boxShadow: AppShadows.sheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title!, style: AppTextStyles.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(color: LightThemeColors.border),
          ] else
            const SizedBox(height: AppSpacing.sm),
          Flexible(
            child: isScrollable
                ? SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: child,
                  )
                : Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: child,
                  ),
          ),
        ],
      ),
    );
  }
}
