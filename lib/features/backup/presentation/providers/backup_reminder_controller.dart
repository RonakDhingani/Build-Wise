import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../navigation/app_router.dart';
import '../../../../shared/widgets/dialogs/backup_reminder_dialog.dart';
// Isar collection getter extensions (projectModels/expenseModels/materialModels).
import '../../../expense/data/models/expense_isar_model.dart';
import '../../../material/data/models/material_isar_model.dart';
import '../../../project/data/models/project_isar_model.dart';
import '../../../onboarding/presentation/walkthrough_controller.dart';
import '../../../onboarding/presentation/walkthrough_step.dart';
import 'backup_prefs_providers.dart';

final backupReminderControllerProvider =
    NotifierProvider<BackupReminderController, bool>(
  BackupReminderController.new,
);

/// Decides whether to surface the one-time backup reminder and drives its
/// outcome. Invoked from the dashboard once per build via a post-frame
/// callback (like the onboarding walkthrough), it self-guards so the dialog is
/// evaluated at most once per session and shown at most once per install.
///
/// State (`bool`) = handled this session — prevents re-evaluation after a
/// decision has been made.
class BackupReminderController extends Notifier<bool> {
  bool _busy = false;

  @override
  bool build() => false;

  /// Shows the reminder if every trigger condition is met:
  /// * the reminder has never been shown before,
  /// * at least one project exists,
  /// * at least one expense OR one material has been added.
  ///
  /// Deferred while the onboarding walkthrough is running so the two flows
  /// never overlap. Safe to call on every dashboard build.
  Future<void> maybeShow(BuildContext context, int projectId) async {
    if (state || _busy) return;

    // Don't compete with the onboarding tour — retry on a later build.
    if (ref.read(walkthroughControllerProvider) != WalkStep.idle) return;

    _busy = true;
    try {
      final store = ref.read(backupPrefsStoreProvider);
      final prefs = await store.read();
      if (prefs.reminderShown) {
        state = true; // already shown on a previous run — never again
        return;
      }

      final isar = ref.read(isarProvider);
      if (await isar.projectModels.count() < 1) return;
      final expenses = await isar.expenseModels.count();
      final materials = await isar.materialModels.count();
      if (expenses < 1 && materials < 1) return;

      if (!context.mounted) return;
      state = true; // committing to show — don't re-evaluate this session

      final choice = await BackupReminderDialog.show(context);
      // Either button persists the flag so it can never appear again.
      await ref.read(backupPrefsProvider.notifier).markReminderShown();

      if (choice == BackupReminderChoice.backupNow && context.mounted) {
        context.pushNamed(
          AppRouteNames.dataManagement,
          pathParameters: {'id': projectId.toString()},
          queryParameters: {'highlight': 'export'},
        );
      }
    } finally {
      _busy = false;
    }
  }
}
