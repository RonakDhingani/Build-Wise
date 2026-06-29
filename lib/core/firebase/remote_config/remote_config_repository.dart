import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'remote_config_constants.dart';
import 'remote_config_logger.dart';
import 'remote_config_model.dart';
import 'remote_config_service.dart';
import 'version_checker.dart';

/// Orchestrates Remote Config: init, cache, version checks, store redirection,
/// future feature flags. Never throws — failures fall back to cache/defaults.
///
/// Startup is non-blocking: [initialize] does NO network (settings + defaults +
/// package info + read cached values). Network happens later via [refresh],
/// which is throttled so resume events don't spam fetches.
class RemoteConfigRepository {
  RemoteConfigRepository({
    required RemoteConfigService service,
    VersionChecker checker = const VersionChecker(),
  })  : _service = service,
        _checker = checker;

  final RemoteConfigService _service;
  final VersionChecker _checker;

  RemoteConfigModel _cached = RemoteConfigModel.fallback();
  String _installedVersion = '0.0.0';
  String _buildNumber = '0';
  DateTime? _lastFetch;
  bool _pkgLoaded = false;

  // ---- Exposed state -------------------------------------------------------
  RemoteConfigModel getCurrentConfig() => _cached;
  String get installedVersion => _installedVersion;
  String get buildNumber => _buildNumber;
  DateTime? get lastFetchTime => _lastFetch;
  bool isMaintenanceMode() => _cached.maintenanceEnabled;

  // ---- Future feature flags (no architecture change to add new keys) -------
  bool getFlag(String key) => _service.getBool(key);
  String getStringValue(String key) => _service.getString(key);
  int getIntValue(String key) => _service.getInt(key);
  double getDoubleValue(String key) => _service.getDouble(key);

  /// Non-blocking startup: package info + settings/defaults + read cached
  /// (last-activated or default) values. No fetch here.
  Future<void> initialize() async {
    await _loadPackageInfo();
    try {
      await _service.initialize();
    } catch (e) {
      RcLog.error('init', e);
    }
    _cached = _service.getModel();
    RcLog.info('Cache Used', 'startup snapshot loaded');
  }

  /// Decide using the CURRENT cache — instant, no network. Use at startup so
  /// the UI never waits.
  UpdateDecision currentDecision() {
    final d = _checker.check(currentVersion: _installedVersion, config: _cached);
    RcLog.info('Version Compared',
        'installed=$_installedVersion latest=${_cached.latestVersion} min=${_cached.minRequiredVersion} => ${d.status.name}');
    return d;
  }

  /// Background fetch + cache update. Throttled to [appThrottle] unless [force].
  /// Returns true if values were refreshed from the network.
  Future<bool> refresh({bool force = false}) async {
    if (!force &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < RemoteConfigTuning.appThrottle) {
      RcLog.info('Refresh throttled', 'last fetch <15m ago');
      return false;
    }
    try {
      await _service.fetchAndActivate();
      _cached = _service.getModel();
      _lastFetch = DateTime.now();
      return true;
    } catch (e) {
      RcLog.error('Fetch Failed, using cache', e);
      return false;
    }
  }

  /// Refresh (throttled) then decide. Convenience for resume checks.
  Future<UpdateDecision> checkForUpdates({bool force = false}) async {
    await refresh(force: force);
    return currentDecision();
  }

  /// Open the platform store from Remote Config. Never throws.
  Future<bool> openStore() async {
    final url = _cached.storeUrl.trim();
    if (url.isEmpty) {
      RcLog.error('Store URL missing');
      return false;
    }
    try {
      final ok = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
      RcLog.success('Store Opened', url);
      return ok;
    } catch (e) {
      RcLog.error('Store open failed', e);
      return false;
    }
  }

  Future<void> _loadPackageInfo() async {
    if (_pkgLoaded) return;
    try {
      final info = await PackageInfo.fromPlatform();
      _installedVersion = info.version;
      _buildNumber = info.buildNumber;
    } catch (e) {
      RcLog.error('package_info failed', e);
    }
    _pkgLoaded = true;
  }
}
