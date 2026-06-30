import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../constants/app_strings.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../providers/about_providers.dart';

/// Premium About screen — brand header, dynamic version + live update status,
/// feature tiles, Rate / Share, footer. Business logic lives in providers.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static const _features = <(IconData, String)>[
    (Icons.cloud_off_rounded, 'Offline First'),
    (Icons.folder_copy_outlined, 'Multi Project'),
    (Icons.savings_outlined, 'Budget Tracking'),
    (Icons.receipt_long_outlined, 'Expenses'),
    (Icons.inventory_2_outlined, 'Materials'),
    (Icons.timeline_outlined, 'Timeline'),
    (Icons.bar_chart_rounded, 'Reports'),
    (Icons.backup_outlined, 'Backup & Restore'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: const AppBarWidget(title: 'About'),
      body: SafeArea(
        bottom: false,
        child: _Entrance(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxxl,
                ),
                children: [
                  const _Header(),
                  const SizedBox(height: AppSpacing.xxl),
                  const _AppInfoCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _Card(
                    title: 'Features',
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final f in _features)
                          _FeatureChip(icon: f.$1, label: f.$2),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Card(
                    title: 'Support',
                    padded: false,
                    child: Column(
                      children: [
                        _ActionTile(
                          icon: Icons.star_rounded,
                          iconColor: AppColors.gold400,
                          title: 'Rate BuildWise',
                          subtitle: 'Tell us how we are doing',
                          onTap: (_) => ref.read(aboutActionsProvider).rate(),
                        ),
                        Divider(height: 1, color: LightThemeColors.border),
                        _ActionTile(
                          icon: Icons.ios_share_rounded,
                          iconColor: LightThemeColors.primary,
                          title: 'Share BuildWise',
                          subtitle: 'Invite others to try it',
                          onTap: (origin) =>
                              ref.read(aboutActionsProvider).share(origin: origin),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const _Footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---- Header ---------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.7, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LightThemeColors.primary, LightThemeColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: LightThemeColors.primary.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(Icons.architecture_rounded,
                color: AppColors.white, size: 44),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(AppStrings.appName, style: AppTextStyles.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Construction Budget & Project Manager',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleSmall
              .copyWith(color: LightThemeColors.primary),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'BuildWise helps homeowners, contractors, and builders manage '
          'construction projects by tracking budgets, expenses, materials, '
          'progress, and reports — all with an offline-first experience.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium
              .copyWith(color: LightThemeColors.textSecondary),
        ),
      ],
    );
  }
}

// ---- App info + update status --------------------------------------------
class _AppInfoCard extends ConsumerWidget {
  const _AppInfoCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(aboutUpdateProvider);
    return _Card(
      title: 'App Information',
      child: Column(
        children: [
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (_, snap) {
              final info = snap.data;
              return Column(
                children: [
                  _InfoRow(label: 'Version', value: info?.version ?? '—'),
                  const SizedBox(height: AppSpacing.md),
                  _InfoRow(
                      label: 'Build Number', value: info?.buildNumber ?? '—'),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          update.when(
            loading: () => const _StatusRow.loading(),
            error: (_, _) => const _StatusRow.upToDate(),
            data: (d) => d.shouldPrompt
                ? _StatusRow.updateAvailable(
                    onUpdate: () => ref.read(aboutActionsProvider).openStore(),
                  )
                : const _StatusRow.upToDate(),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow.loading()
      : _state = 0,
        onUpdate = null;
  const _StatusRow.upToDate()
      : _state = 1,
        onUpdate = null;
  const _StatusRow.updateAvailable({required this.onUpdate}) : _state = 2;

  final int _state; // 0 loading, 1 up-to-date, 2 update
  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Status',
            style: AppTextStyles.bodyMedium
                .copyWith(color: LightThemeColors.textSecondary)),
        const Spacer(),
        if (_state == 0)
          const SizedBox(
              width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
        else if (_state == 1) ...[
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success500, size: AppDimensions.iconSm),
          const SizedBox(width: AppSpacing.xs),
          Text('Up to Date',
              style: AppTextStyles.titleSmall
                  .copyWith(color: AppColors.success500)),
        ] else ...[
          Text('Update Available',
              style: AppTextStyles.titleSmall
                  .copyWith(color: AppColors.gold400)),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            height: 34,
            child: AppPrimaryButton(
              label: 'Update',
              width: 96,
              onPressed: onUpdate,
            ),
          ),
        ],
      ],
    );
  }
}

// ---- Reusable bits --------------------------------------------------------
class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child, this.padded = true});
  final String title;
  final Widget child;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(title.toUpperCase(),
              style: AppTextStyles.labelMedium.copyWith(
                  color: LightThemeColors.textTertiary, letterSpacing: 0.8)),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(padded ? AppSpacing.lg : 0),
          decoration: BoxDecoration(
            color: LightThemeColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: LightThemeColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: LightThemeColors.textSecondary)),
        Text(value, style: AppTextStyles.titleSmall),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: LightThemeColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: LightThemeColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSm, color: LightThemeColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(label,
              style: AppTextStyles.labelLarge
                  .copyWith(color: LightThemeColors.primary)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  // Receives the tile's global rect (needed as the iOS share popover anchor).
  final void Function(Rect origin) onTap;

  Rect _originOf(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return Rect.zero;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(_originOf(context)),

      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: AppDimensions.avatarSm,
              height: AppDimensions.avatarSm,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Icon(icon, color: iconColor, size: AppDimensions.iconSm),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: LightThemeColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: LightThemeColors.textTertiary, size: AppDimensions.iconMd),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('© 2026 BuildWise',
            style: AppTextStyles.bodySmall
                .copyWith(color: LightThemeColors.textSecondary)),
        const SizedBox(height: 2),
        Text('All Rights Reserved.',
            style: AppTextStyles.labelSmall
                .copyWith(color: LightThemeColors.textTertiary)),
      ],
    );
  }
}

// ---- Entrance animation (fade + slide up) ---------------------------------
class _Entrance extends StatelessWidget {
  const _Entrance({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 24), child: child),
      ),
      child: child,
    );
  }
}
