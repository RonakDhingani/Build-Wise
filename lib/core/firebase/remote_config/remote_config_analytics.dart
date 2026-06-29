import 'package:firebase_analytics/firebase_analytics.dart';

import 'remote_config_logger.dart';

/// Isolated Firebase Analytics logging for the update/maintenance flow.
/// Kept out of UI and repository so analytics can be swapped/mocked freely.
/// All calls are fire-and-forget and never throw.
class RemoteConfigAnalytics {
  RemoteConfigAnalytics(this._analytics);

  final FirebaseAnalytics _analytics;

  Future<void> _log(String name, [Map<String, Object>? params]) async {
    try {
      await _analytics.logEvent(name: name, parameters: params);
    } catch (e) {
      RcLog.error('Analytics log failed ($name)', e);
    }
  }

  void updateDialogShown({required bool forced, required String latest}) {
    _log('update_dialog_shown', {'forced': forced.toString(), 'latest': latest});
    _log(forced ? 'forced_update' : 'optional_update', {'latest': latest});
  }

  void updateClicked(String latest) => _log('update_clicked', {'latest': latest});
  void updateLater(String latest) => _log('update_later', {'latest': latest});
  void maintenanceMode() => _log('maintenance_mode');
}
