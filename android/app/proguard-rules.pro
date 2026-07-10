# ============================================================================
# BuildWise — R8 keep rules (release: shrink + resource-shrink + obfuscation)
# ----------------------------------------------------------------------------
# Scope is deliberately minimal. The following are ALREADY handled and are NOT
# duplicated here:
#   - io.flutter.**            : Flutter tool auto-applies flutter_proguard_rules.pro
#                                (keeps FlutterPlugin impls, -dontwarn io.flutter.plugin.**,
#                                 -dontwarn android.**).
#   - Firebase (core/firestore/remote_config/analytics) : each AAR ships its own
#                                consumer ProGuard rules — no manual keeps required.
#   - file_picker              : ships consumerProguardFiles (Apache Tika rules) —
#                                auto-merged, do not re-declare.
#   - All other plugins (isar, printing, webview_flutter, image_picker,
#     permission_handler, share_plus, url_launcher, path_provider,
#     package_info_plus, device_info_plus, in_app_review,
#     flutter_image_compress) are platform-channel / FFI based with no Java
#     reflection surface, so they need no keep rules.
#   - Pure-Dart packages (riverpod, go_router, syncfusion_charts, pdf, archive,
#     intl, uuid, tutorial_coach_mark) never reach R8.
# ============================================================================

# ---------------------------------------------------------------------------
# Google Play Core (Play Feature Delivery / deferred components)
# ---------------------------------------------------------------------------
# The Flutter embedding contains PlayStore*/deferred-component classes that
# reference com.google.android.play.core.**. This app does NOT use deferred
# components, so that library is absent at build time. Without this rule R8
# aborts release builds with "Missing classes detected while running R8".
# -dontwarn only (not -keep): the classes are genuinely unused, just silence them.
-dontwarn com.google.android.play.core.**
