import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/firebase/remote_config/remote_config_repository.dart';

/// Business logic for the About screen (kept out of the UI). Rate + Share +
/// store redirection, reusing the Remote Config store URL.
class AboutActions {
  AboutActions(this._remoteConfig);

  final RemoteConfigRepository _remoteConfig;

  static const String _shareText =
      'Manage your construction budget with BuildWise — track expenses, '
      'materials, stages and reports, fully offline.';

  /// Native in-app review first; fall back to the store listing.
  Future<void> rate() async {
    final review = InAppReview.instance;
    try {
      if (await review.isAvailable()) {
        await review.requestReview();
        return;
      }
    } catch (_) {/* fall through to store */}
    await _remoteConfig.openStore();
  }

  /// Native share sheet with the app store link.
  /// [origin] is the source rect of the tapped widget — REQUIRED on iOS/iPad
  /// so the share popover has an anchor (otherwise share_plus throws
  /// `sharePositionOrigin: argument must be set`).
  Future<void> share({Rect? origin}) async {
    final url = _remoteConfig.getCurrentConfig().storeUrl.trim();
    final text = url.isEmpty ? _shareText : '$_shareText\n$url';
    await Share.share(text, subject: 'BuildWise', sharePositionOrigin: origin);
  }

  Future<bool> openStore() => _remoteConfig.openStore();
}
