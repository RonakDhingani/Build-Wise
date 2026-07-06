import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permission_dialog.dart';

/// App features that need a runtime permission. Storage and photo-library
/// access are intentionally absent: backup export/import use the Storage
/// Access Framework + app-private dirs, and the gallery picker uses the
/// system photo picker (Android Photo Picker / iOS PHPicker) which runs
/// out-of-process and needs no runtime permission — so neither is requested
/// on any supported OS version.
enum AppPermissionType { camera }

/// Centralised runtime-permission flow. UI never calls permission_handler
/// directly — it calls [ensure] and acts on the boolean result.
///
/// Flow (just-in-time, Play/App Store compliant):
///   granted / limited (iOS) -> true
///   denied                  -> request -> re-evaluate
///   permanently denied      -> rationale dialog + "Open Settings" -> false
///   restricted (iOS)        -> rationale dialog -> false
/// Never throws — a failure resolves to false.
class PermissionService {
  const PermissionService();

  Future<bool> ensureCamera(
    BuildContext context, {
    VoidCallback? onOpenedSettings,
  }) =>
      ensure(context, AppPermissionType.camera,
          onOpenedSettings: onOpenedSettings);

  Future<bool> ensure(
    BuildContext context,
    AppPermissionType type, {
    VoidCallback? onOpenedSettings,
  }) async {
    final permission = _permissionFor(type);
    try {
      var status = await permission.status;

      // Already usable. iOS "limited" photo access is fine for the picker.
      if (status.isGranted || status.isLimited) return true;

      // Blocked at OS level — can only be changed in Settings.
      if (status.isPermanentlyDenied || status.isRestricted) {
        if (context.mounted) {
          final openedSettings = await PermissionDialog.show(context, type);
          if (openedSettings) onOpenedSettings?.call();
        }
        return false;
      }

      // Denied (incl. first-time) — request just-in-time.
      status = await permission.request();
      if (status.isGranted || status.isLimited) return true;

      if ((status.isPermanentlyDenied || status.isRestricted) &&
          context.mounted) {
        final openedSettings = await PermissionDialog.show(context, type);
        if (openedSettings) onOpenedSettings?.call();
      }
      return false;
    } catch (_) {
      // Never crash the feature over a permission hiccup.
      return false;
    }
  }

  Permission _permissionFor(AppPermissionType type) {
    switch (type) {
      case AppPermissionType.camera:
        return Permission.camera;
    }
  }
}

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return const PermissionService();
});
