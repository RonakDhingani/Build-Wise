import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permission_dialog.dart';

/// App features that need a runtime permission. Storage is intentionally absent:
/// backup export/import use the Storage Access Framework + app-private dirs, so
/// no storage permission is required on any supported OS version.
enum AppPermissionType { camera, photos }

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

  Future<bool> ensureCamera(BuildContext context) =>
      ensure(context, AppPermissionType.camera);

  Future<bool> ensureGallery(BuildContext context) =>
      ensure(context, AppPermissionType.photos);

  Future<bool> ensure(BuildContext context, AppPermissionType type) async {
    final permission = _permissionFor(type);
    try {
      var status = await permission.status;

      // Already usable. iOS "limited" photo access is fine for the picker.
      if (status.isGranted || status.isLimited) return true;

      // Blocked at OS level — can only be changed in Settings.
      if (status.isPermanentlyDenied || status.isRestricted) {
        if (context.mounted) await PermissionDialog.show(context, type);
        return false;
      }

      // Denied (incl. first-time) — request just-in-time.
      status = await permission.request();
      if (status.isGranted || status.isLimited) return true;

      if ((status.isPermanentlyDenied || status.isRestricted) &&
          context.mounted) {
        await PermissionDialog.show(context, type);
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
      case AppPermissionType.photos:
        // permission_handler maps this to READ_MEDIA_IMAGES on Android 13+,
        // READ_EXTERNAL_STORAGE on Android ≤12, and Photos on iOS.
        return Permission.photos;
    }
  }
}

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return const PermissionService();
});
