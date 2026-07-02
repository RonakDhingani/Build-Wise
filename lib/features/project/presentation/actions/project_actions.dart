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
/// The active/selected project is a single source of truth: the persisted
/// `defaultProjectId` in settings. Selecting or creating a project writes it,
/// and the router's `:id` path parameter drives every screen's family provider,
/// so switching projects refreshes Dashboard/Expenses/Materials/Reports with no
/// manual refresh and no duplicate state.
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

  /// Make [projectId] the active project and open its Dashboard. Persisting the
  /// selection means the app reopens on this project after restart. Every
  /// project-scoped provider re-keys on the new `:id`, so all tabs refresh.
  static Future<void> switchTo(
    BuildContext context,
    WidgetRef ref,
    int projectId,
  ) async {
    await ref.read(settingsNotifierProvider.notifier).setDefaultProject(projectId);
    if (!context.mounted) return;
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
            isArchiving ? '${project.name} archived' : '${project.name} unarchived',
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
    final messenger = ScaffoldMessenger.of(context);
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
        container.read(settingsNotifierProvider).valueOrNull?.defaultProjectId ==
            project.id;

    // Cascade delete (stages/expenses/materials/photos) + drop from global list.
    await container.read(projectsNotifierProvider.notifier).deleteProject(project.id);

    if (isActive && context.mounted) {
      // Leave the project context immediately. goNamed here runs before the next
      // frame paints, so the now-orphaned Dashboard never rebuilds → no empty
      // data, no "Try Again" screen. User lands on the Project Listing to pick
      // another project (empty-state list if none remain).
      context.goNamed(AppRouteNames.projects);
    }
    if (wasDefault) {
      await container.read(settingsNotifierProvider.notifier).setDefaultProject(null);
    }
    _disposeProjectState(container, project.id);

    messenger.showSnackBar(
      SnackBar(
        content: Text('${project.name} deleted'),
        backgroundColor: AppColors.error500,
      ),
    );
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
