import 'permission_service.dart';

/// Metadata for each app permission — labels + user-facing rationale, in one
/// place so the service, dialog, and any future UI stay consistent.
///
/// Note on storage: BuildWise deliberately declares NO storage permission.
/// Backup export writes to the app's private documents directory and shares via
/// the OS share sheet / Storage Access Framework; import reads via the SAF
/// document picker. None of these need a runtime storage permission on any
/// supported Android or iOS version — so none is requested.
abstract class PermissionHelper {
  static String label(AppPermissionType type) {
    switch (type) {
      case AppPermissionType.camera:
        return 'Camera';
      case AppPermissionType.photos:
        return 'Photos';
    }
  }

  static ({String title, String message}) rationale(AppPermissionType type) {
    switch (type) {
      case AppPermissionType.camera:
        return (
          title: 'Camera Access Needed',
          message:
              'BuildWise needs camera access to capture progress photos. '
              'Enable Camera for BuildWise in Settings to continue.',
        );
      case AppPermissionType.photos:
        return (
          title: 'Photo Access Needed',
          message:
              'BuildWise needs photo access to attach images from your gallery. '
              'Enable Photos for BuildWise in Settings to continue.',
        );
    }
  }
}
