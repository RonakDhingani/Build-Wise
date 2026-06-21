import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../../../constants/app_strings.dart';

class AppSuccessState extends StatelessWidget {
  const AppSuccessState({
    super.key,
    required this.message,
    this.onDone,
  });

  final String message;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (_, scale, child) => Transform.scale(
                scale: scale,
                child: child,
              ),
              child: Icon(
                Icons.check_circle,
                size: AppDimensions.iconXl,
                color: AppColors.success500,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (onDone != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              TextButton(
                onPressed: onDone,
                child: Text(AppStrings.done),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
