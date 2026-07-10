import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../navigation/app_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../project/domain/entities/project_entity.dart';
import '../../../project/presentation/actions/project_actions.dart';
import '../../../project/presentation/providers/project_providers.dart';

enum _MoreAction { edit, archive, delete }

/// Dashboard AppBar with a Notion/Slack-style workspace switcher.
///
/// Left: Back → Project Listing. Center: tappable project name + location with a
/// dropdown arrow that opens an animated project switcher. Right: "+ New
/// Project" and a three-dot Edit/Archive/Delete menu. All mutations route
/// through [ProjectActions] so behaviour matches the rest of the app.
class ProjectSwitcherAppBar extends ConsumerWidget
    implements PreferredSizeWidget {
  const ProjectSwitcherAppBar({super.key, required this.project});

  final ProjectEntity project;

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.appBarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      titleSpacing: 0,
      leadingWidth: 44,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'All projects',
        // Back always returns to the Project Listing screen.
        onPressed: () => context.goNamed(AppRouteNames.projects),
      ),
      title: _SwitcherTitle(project: project),
      actions: [
        _NewProjectButton(onTap: () => ProjectActions.create(context)),
        const SizedBox(width: AppSpacing.xs),
        PopupMenuButton<_MoreAction>(
          icon: Icon(Icons.more_vert, color: LightThemeColors.textSecondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          onSelected: (action) => _onMore(context, ref, action),
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: _MoreAction.edit,
              child: _MoreRow(icon: Icons.edit_outlined, label: 'Edit Project'),
            ),
            PopupMenuItem(
              value: _MoreAction.archive,
              child: _MoreRow(
                icon: project.status == ProjectStatus.active
                    ? Icons.archive_outlined
                    : Icons.unarchive_outlined,
                label: project.status == ProjectStatus.active
                    ? 'Archive Project'
                    : 'Unarchive Project',
              ),
            ),
            const PopupMenuItem(
              value: _MoreAction.delete,
              child: _MoreRow(
                icon: Icons.delete_outline,
                label: 'Delete Project',
                color: AppColors.error500,
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: LightThemeColors.border),
      ),
    );
  }

  void _onMore(BuildContext context, WidgetRef ref, _MoreAction action) {
    switch (action) {
      case _MoreAction.edit:
        ProjectActions.edit(context, project);
      case _MoreAction.archive:
        ProjectActions.archive(context, ref, project);
      case _MoreAction.delete:
        // We're viewing this project → deleting it triggers the "active project
        // deleted" flow (leave to Project Listing).
        ProjectActions.delete(context, project, activeProjectId: project.id);
    }
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? LightThemeColors.textPrimary;
    return Row(
      children: [
        Icon(icon, size: AppDimensions.iconSm, color: c),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: c)),
      ],
    );
  }
}

/// "+ New Project" pill on the right of the AppBar.
class _NewProjectButton extends StatelessWidget {
  const _NewProjectButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(color: LightThemeColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 18, color: LightThemeColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'New Project',
                style: AppTextStyles.labelMedium.copyWith(
                  color: LightThemeColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tappable title (name + location + caret) that opens the animated dropdown.
class _SwitcherTitle extends ConsumerStatefulWidget {
  const _SwitcherTitle({required this.project});

  final ProjectEntity project;

  @override
  ConsumerState<_SwitcherTitle> createState() => _SwitcherTitleState();
}

class _SwitcherTitleState extends ConsumerState<_SwitcherTitle>
    with SingleTickerProviderStateMixin {
  final _link = LayerLink();
  final _portal = OverlayPortalController();
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    // Construct eagerly, not via a lazy `late final` initializer: `_anim` is
    // only otherwise touched when the dropdown is opened (_open/_close), so a
    // title that's disposed before ever being tapped (e.g. switching project
    // replaces this widget) would lazily construct it for the first time
    // inside dispose() — needing a vsync/TickerMode lookup on an element
    // that's already being torn down ("deactivated ancestor" crash).
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 140),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _open() {
    _portal.show();
    _anim.forward(from: 0);
  }

  void _close() {
    _anim.reverse().whenComplete(() {
      // If _open() re-triggered forward() before this reverse finished, the
      // cancelled TickerFuture still completes and this stale callback would
      // otherwise hide the freshly-reopened dropdown. Only hide if the
      // animation is still actually at rest (dismissed).
      if (mounted && _anim.status == AnimationStatus.dismissed && _portal.isShowing) {
        _portal.hide();
      }
    });
  }

  /// Remove the dropdown immediately, no exit animation. Used when a selection
  /// triggers navigation — animating the overlay out while the route (and this
  /// State's AnimationController) is being torn down races the two and can build
  /// a disposed element. Instant dismiss sidesteps it.
  void _dismissNow() {
    _anim.value = 0;
    if (_portal.isShowing) _portal.hide();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildOverlay,
      child: CompositedTransformTarget(
        link: _link,
        child: InkWell(
          onTap: _open,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.project.name,
                        style: AppTextStyles.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.project.location.isNotEmpty)
                        Text(
                          widget.project.location,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: LightThemeColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: AppDimensions.iconMd,
                  color: LightThemeColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    // Dropdown width: slightly wider than the title (LayerLink.leaderSize is the
    // measured title size), capped to the screen.
    final titleWidth = _link.leaderSize?.width;
    final screenWidth = MediaQuery.sizeOf(overlayContext).width;
    final width = (((titleWidth ?? 220) + 48).clamp(200.0, screenWidth - 24))
        .toDouble();

    return Stack(
      children: [
        // Tap-outside barrier.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          // Anchor below the title, aligned to its left edge (nudged left so it
          // lines up with the project title rather than centering).
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(-AppSpacing.xs, AppSpacing.sm),
          child: Align(
            alignment: Alignment.topLeft,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, child) {
                final curved = CurvedAnimation(
                  parent: _anim,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                );
                return Opacity(
                  opacity: curved.value,
                  child: Transform.scale(
                    scale: 0.92 + 0.08 * curved.value,
                    alignment: Alignment.topLeft,
                    child: child,
                  ),
                );
              },
              child: _DropdownCard(
                width: width,
                currentId: widget.project.id,
                onSelect: (id) {
                  // Dismiss instantly, then switch. switchTo defers the route
                  // change to post-frame so the page swap stays clean. Use the
                  // stable title context, not the transient overlay one.
                  _dismissNow();
                  if (id != widget.project.id) {
                    ProjectActions.switchTo(context, id);
                  }
                },
                onAddNew: () {
                  _dismissNow();
                  ProjectActions.create(context);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The elevated, rounded dropdown surface listing active projects.
class _DropdownCard extends ConsumerWidget {
  const _DropdownCard({
    required this.width,
    required this.currentId,
    required this.onSelect,
    required this.onAddNew,
  });

  final double width;
  final int currentId;
  final ValueChanged<int> onSelect;
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show every project — active and archived — so an archived project you're
    // viewing can switch to any other, and vice versa.
    final projects =
        ref.watch(projectsNotifierProvider).valueOrNull?.projects ?? const [];

    return Material(
      elevation: 8,
      shadowColor: AppColors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      color: LightThemeColors.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: width,
          maxWidth: width,
          maxHeight: 360,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                children: [
                  for (final p in projects)
                    _ProjectRow(
                      project: p,
                      selected: p.id == currentId,
                      onTap: () => onSelect(p.id),
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: LightThemeColors.border),
            InkWell(
              onTap: onAddNew,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppDimensions.radiusLg),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, size: AppDimensions.iconSm,
                        color: LightThemeColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Add New Project',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: LightThemeColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({
    required this.project,
    required this.selected,
    required this.onTap,
  });

  final ProjectEntity project;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    project.name,
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (project.location.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      project.location,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: LightThemeColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (selected) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.check_rounded,
                  size: AppDimensions.iconSm, color: LightThemeColors.primary),
            ],
          ],
        ),
      ),
    );
  }
}
