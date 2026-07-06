import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../navigation/app_router.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../expense/presentation/providers/expense_providers.dart';
import '../../../material/presentation/providers/material_providers.dart';
import '../../../report/presentation/providers/report_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../stage/presentation/providers/stage_providers.dart';
import '../../domain/entities/project_entity.dart';
import '../providers/project_providers.dart';

/// Single shared implementation of every project mutation (select / create-flow
/// entry / edit / archive / delete) so the Dashboard AppBar menu, Project
/// Listing screen and Settings → Manage Projects all behave identically.
///
/// The router's `:id` path parameter drives every screen's family provider,
/// so switching projects refreshes Dashboard/Expenses/Materials/Reports with no
/// manual refresh and no duplicate state. The *default* project (what the app
/// reopens on next launch) is a separate, persisted `defaultProjectId` in
/// settings — it is only ever set from Settings → Default Project. Opening,
/// switching, creating, or deleting a project here never touches it (deleting
/// the current default does clear it to `null`, since it would otherwise
/// point at nothing).
class ProjectActions {
  ProjectActions._();

  /// Open the Create Project screen.
  static void create(BuildContext context) {
    context.pushNamed(AppRouteNames.createProject);
  }

  /// Open the Edit Project screen for [project].
  static void edit(BuildContext context, ProjectEntity project) {
    context.pushNamed(
      AppRouteNames.editProject,
      pathParameters: {'id': project.id.toString()},
    );
  }

  /// Open [projectId]'s Dashboard. Every project-scoped provider re-keys on
  /// the new `:id`, so all tabs refresh. This does NOT persist [projectId] as
  /// the default project — that's only ever set from Settings → Default
  /// Project, so opening/switching projects here never changes what the app
  /// reopens on next launch.
  ///
  /// Navigates immediately/synchronously. This used to defer to a post-frame
  /// callback because it also wrote `setDefaultProject` (a watched provider)
  /// in the same call, and navigating synchronously alongside that write
  /// could leave the outgoing page marked-dirty as it's removed. Now that
  /// this no longer writes any provider, there's nothing to collide with —
  /// deferring only added a spurious frame of latency (visible as "the first
  /// tap does nothing, needs a second tap or a scroll to register").
  static void switchTo(BuildContext context, int projectId) {
    context.goNamed(
      AppRouteNames.dashboard,
      pathParameters: {'id': projectId.toString()},
    );
  }

  /// Archive/unarchive [project]. Returns true if the user confirmed.
  static Future<bool> archive(
    BuildContext context,
    WidgetRef ref,
    ProjectEntity project,
  ) async {
    final isArchiving = project.status == ProjectStatus.active;
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(projectsNotifierProvider.notifier);
    final confirm = await AppConfirmationDialog.show(
      context,
      title: isArchiving
          ? 'Archive ${project.name}?'
          : 'Unarchive ${project.name}?',
      message: isArchiving
          ? 'Project will be hidden from your active list.'
          : 'Project will be restored to your active list.',
      confirmLabel: isArchiving ? 'Archive' : 'Unarchive',
      onConfirm: () => notifier.archiveProject(project.id),
    );
    if (confirm == true) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isArchiving
                ? '${project.name} archived'
                : '${project.name} unarchived',
          ),
        ),
      );
    }
    return confirm == true;
  }

  /// Delete [project], handling both scenarios in one place:
  ///
  /// * Case 1 — the deleted project is NOT the one currently in view
  ///   ([activeProjectId] != project.id): delete + refresh lists, stay put.
  /// * Case 2 — the deleted project IS the one in view: delete, drop the active
  ///   project, leave its `:id` context (back to Project Listing) in the SAME
  ///   frame so no screen ever rebuilds against deleted data, and dispose the
  ///   old project's providers.
  ///
  /// Pass [activeProjectId] = the project whose data context the caller is bound
  /// to (the route `:id`), or null when called from a screen with no active
  /// project (e.g. the Project Listing).
  static Future<void> delete(
    BuildContext context,
    ProjectEntity project, {
    int? activeProjectId,
  }) async {
    // Root container survives navigation, so reads/writes below stay valid even
    // after we leave the deleted project's widget subtree.
    final container = ProviderScope.containerOf(context, listen: false);

    // Dialog only confirms — we run the work afterwards so ordering is ours to
    // control (delete → navigate away in the same frame).
    final confirm = await AppDeleteDialog.show(
      context,
      itemName: project.name,
      onDelete: () {},
    );
    if (confirm != true) return;

    final isActive = activeProjectId != null && activeProjectId == project.id;
    final wasDefault =
        container
            .read(settingsNotifierProvider)
            .valueOrNull
            ?.defaultProjectId ==
        project.id;

    // Cascade delete (stages/expenses/materials/photos) + drop from global list.
    await container
        .read(projectsNotifierProvider.notifier)
        .deleteProject(project.id);

    if (isActive && context.mounted) {
      // Leave the project context immediately. goNamed here runs before the next
      // frame paints, so the now-orphaned Dashboard never rebuilds → no empty
      // data, no "Try Again" screen. User lands on the Project Listing to pick
      // another project (empty-state list if none remain).
      context.goNamed(AppRouteNames.projects);
    }
    if (wasDefault) {
      await container
          .read(settingsNotifierProvider.notifier)
          .setDefaultProject(null);
    }
    _disposeProjectState(container, project.id);

    // Resolve the messenger post-frame, off the root context, instead of a
    // ScaffoldMessenger captured before the goNamed above: by the time this
    // runs, the caller's own context (and any messenger resolved from it) may
    // already be torn down by the navigation, causing "Looking up a
    // deactivated widget's ancestor is unsafe" when the SnackBar's
    // AnimationController is created.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rootContext = rootNavigatorKey.currentContext;
      if (rootContext == null) return;
      ScaffoldMessenger.of(rootContext).showSnackBar(
        SnackBar(
          content: Text('${project.name} deleted'),
          backgroundColor: AppColors.error500,
        ),
      );
    });
  }

  /// Cancel/dispose every provider keyed to the deleted project after the tree
  /// has settled, so no listener holds stale state for a project that no longer
  /// exists. Runs post-frame to guarantee the old screens are unmounted first.
  static void _disposeProjectState(ProviderContainer container, int projectId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      container.invalidate(dashboardProvider(projectId));
      container.invalidate(expensesNotifierProvider(projectId));
      container.invalidate(materialsNotifierProvider(projectId));
      container.invalidate(stagesNotifierProvider(projectId));
      container.invalidate(reportDataProvider(projectId));
    });
  }
}
