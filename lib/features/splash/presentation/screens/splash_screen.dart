import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../navigation/app_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) context.goNamed(AppRouteNames.projects);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy800,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/images/splash.png',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _Fallback(),
        ),
      ),
    );
  }
}

/// Shown if the splash asset is missing — keeps the brand look.
class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy800,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.architecture_rounded,
              size: 72, color: AppColors.gold400),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: AppTextStyles.displaySmall.copyWith(color: Colors.white),
              children: [
                const TextSpan(text: 'Build'),
                TextSpan(
                    text: 'Wise',
                    style: TextStyle(color: AppColors.gold400)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PLAN • TRACK • BUILD WISE',
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
