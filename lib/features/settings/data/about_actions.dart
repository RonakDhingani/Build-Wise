import 'package:flutter/foundation.dart';
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
  ///
  /// NOTE: the in-app review card only renders for Play-Store-delivered builds
  /// (internal app sharing / closed testing / production), and Google throttles
  /// it hard — a `flutter run`/debug build always no-ops silently even though
  /// the plugin logs "Successfully requested review flow". In debug we skip
  /// straight to the store so the URL + flow are verifiable during development.
  Future<void> rate() async {
    if (kDebugMode) {
      await _remoteConfig.openStore();
      return;
    }
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
