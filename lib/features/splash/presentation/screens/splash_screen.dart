import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/result/result.dart';
import '../../../../navigation/app_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../project/presentation/providers/project_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), _route);
  }

  /// Launch routing based on the Default Project setting:
  /// * none -> Project Listing
  /// * set & exists -> Project Listing in the stack, then open its Dashboard
  ///   (so Back returns to the list)
  /// * set & deleted -> reset to none -> Project Listing
  Future<void> _route() async {
    if (!mounted) return;
    int? defaultId;
    try {
      final settings = await ref.read(settingsNotifierProvider.future);
      defaultId = settings.defaultProjectId;
    } catch (_) {
      defaultId = null;
    }
    if (!mounted) return;

    if (defaultId == null) {
      context.goNamed(AppRouteNames.projects);
      return;
    }

    // Confirm the default project still exists.
    final result =
        await ref.read(getProjectByIdUseCaseProvider).execute(defaultId);
    if (!mounted) return;
    final exists = result.when(success: (_) => true, failure: (_) => false);

    if (!exists) {
      // Stale default — reset and fall back to the list.
      await ref.read(settingsNotifierProvider.notifier).setDefaultProject(null);
      if (!mounted) return;
      context.goNamed(AppRouteNames.projects);
      return;
    }

    // Project list first (back stack), then straight into its dashboard.
    context.goNamed(AppRouteNames.projects);
    context.pushNamed(
      AppRouteNames.dashboard,
      pathParameters: {'id': defaultId.toString()},
    );
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
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.white),
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
              color: AppColors.white.withValues(alpha: 0.7),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
