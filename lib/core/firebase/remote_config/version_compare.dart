/// Semantic-version comparison. Compares numerically, segment by segment —
/// never with `String.compareTo` (which would rank "1.2.5" above "1.12.0").
///
/// Lenient by design: a build suffix (`1.0.0+3`), pre-release tag (`1.0.0-rc`)
/// or any non-numeric junk is stripped/treated as 0 so malformed values never
/// throw. Missing trailing segments are treated as 0 (`1.2` == `1.2.0`).
abstract class VersionCompare {
  /// Returns -1 if [a] < [b], 0 if equal, 1 if [a] > [b].
  static int compare(String a, String b) {
    final pa = _parts(a);
    final pb = _parts(b);
    final len = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < len; i++) {
      final x = i < pa.length ? pa[i] : 0;
      final y = i < pb.length ? pb[i] : 0;
      if (x != y) return x < y ? -1 : 1;
    }
    return 0;
  }

  /// True when [version] is strictly older than [target].
  static bool isOlder(String version, String target) =>
      compare(version, target) < 0;

  /// True when [version] is the same as or newer than [target].
  static bool isAtLeast(String version, String target) =>
      compare(version, target) >= 0;

  static List<int> _parts(String v) {
    // Drop build metadata / pre-release tags: "1.2.3+4-beta" -> "1.2.3".
    final core = v.trim().split(RegExp(r'[+\-\s]')).first;
    return core.split('.').map((seg) {
      final digits = seg.replaceAll(RegExp(r'[^0-9]'), '');
      return digits.isEmpty ? 0 : (int.tryParse(digits) ?? 0);
    }).toList(growable: false);
  }
}
