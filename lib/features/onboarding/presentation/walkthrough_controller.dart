import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../navigation/app_router.dart';
import '../../../theme/app_colors.dart';
import '../data/walkthrough_store.dart';
import 'walkthrough_card.dart';
import 'walkthrough_step.dart';

final walkthroughStoreProvider =
    Provider<WalkthroughStore>((_) => const WalkthroughStore());

/// First-run check: false once the tour has been completed/skipped.
final walkthroughCompletedProvider = FutureProvider<bool>(
  (ref) => ref.read(walkthroughStoreProvider).isCompleted(),
);

final walkthroughControllerProvider =
    NotifierProvider<WalkthroughController, WalkStep>(WalkthroughController.new);

/// Owns the cross-screen product tour. Screens watch [state] (the current
/// [WalkStep]) and call [maybeShowCoach] in a post-frame callback so each
/// spotlight appears when its target is mounted — robust to tab navigation.
class WalkthroughController extends Notifier<WalkStep> {
  bool _firstRun = false;
  bool _hasEverStarted = false;
  int? _projectId;
  TutorialCoachMark? _coach;
  WalkStep? _shown;

  @override
  WalkStep build() => WalkStep.idle;

  BuildContext? get _ctx => rootNavigatorKey.currentContext;

  // ---- Entry points ----

  void beginFirstRun() {
    if (state != WalkStep.idle || _hasEverStarted) return;
    _hasEverStarted = true;
    _firstRun = true;
    _projectId = null;
    // Persist immediately so dialog shows at most once per install,
    // even if the app is killed while the tour is in progress.
    ref.read(walkthroughStoreProvider).setCompleted(true);
    _go(WalkStep.welcome);
  }

  void beginReplay(int projectId) {
    _firstRun = false;
    _projectId = projectId;
    _dismissCoach();
    _go(WalkStep.welcome);
  }

  /// Called by the dashboard once it is built with a real project. Advances
  /// past the create-project step on first run and records the project id.
  void onDashboardReady(int projectId) {
    if (state == WalkStep.idle) return;
    _projectId = projectId;
    if (state == WalkStep.createProject && _firstRun) {
      _go(WalkStep.budget);
    }
  }

  // ---- Step transitions ----

  void _go(WalkStep s) {
    _dismissCoach();
    _shown = null;
    state = s;
    if (s == WalkStep.welcome) {
      _showInfoDialog(s, nextLabel: 'Start Tour');
    } else if (s == WalkStep.finish) {
      _showInfoDialog(s, nextLabel: 'Finish', isFinish: true);
    }
    // Coach steps are shown by their screens via [maybeShowCoach].
  }

  /// Advances from the current step (Next button / welcome dialog).
  void advance() {
    switch (state) {
      case WalkStep.welcome:
        if (_firstRun) {
          _go(WalkStep.createProject);
        } else {
          _navDashboard();
          _go(WalkStep.budget);
        }
      case WalkStep.budget:
        _go(WalkStep.expensesTab);
      case WalkStep.expensesTab:
        _navTab(AppRouteNames.expenses);
        _go(WalkStep.addExpense);
      case WalkStep.addExpense:
        _go(WalkStep.materialsTab);
      case WalkStep.materialsTab:
        _navDashboard();
        _go(WalkStep.photos);
      case WalkStep.photos:
        _go(WalkStep.reportsTab);
      case WalkStep.reportsTab:
        _navTab(AppRouteNames.reports);
        _go(WalkStep.finish);
      case WalkStep.finish:
        _complete();
      case WalkStep.createProject:
      case WalkStep.idle:
        break;
    }
  }

  /// Skip ends the tour and marks it completed so it won't auto-show again.
  void skip() => _complete();

  void _complete() {
    _dismissCoach();
    _shown = null;
    state = WalkStep.idle;
    ref.read(walkthroughStoreProvider).setCompleted(true);
    ref.invalidate(walkthroughCompletedProvider);
  }

  // ---- Navigation (via root navigator) ----

  void _navDashboard() => _navTab(AppRouteNames.dashboard);

  void _navTab(String routeName) {
    final ctx = _ctx;
    final id = _projectId;
    if (ctx == null || id == null) return;
    ctx.goNamed(routeName, pathParameters: {'id': id.toString()});
  }

  void _onCreateTap() {
    _dismissCoach();
    final ctx = _ctx;
    if (ctx == null) return;
    ctx.pushNamed(AppRouteNames.createProject);
    // Tour resumes when the dashboard mounts (onDashboardReady).
  }

  // ---- Coach + dialog rendering ----

  /// Shows the spotlight for [step] if it is the active step, its target is
  /// mounted, and it isn't already showing. Safe to call every build.
  ///
  /// Either [key] (a mounted widget) or [targetPosition] (an explicit screen
  /// rect, e.g. a computed bottom-nav cell) must be provided. The content card
  /// is placed on whichever side of the target has more room and is capped to
  /// the space available there, so it is never clipped off-screen on any
  /// device / notch / status-bar combination.
  void maybeShowCoach(
    BuildContext context,
    WalkStep step, {
    GlobalKey? key,
    TargetPosition? targetPosition,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
    double radius = 12,
    double focusPadding = 10,
  }) {
    assert(key != null || targetPosition != null);
    if (state != step || _shown == step) return;

    final rect = _targetRect(key, targetPosition);
    if (rect == null) return; // target not laid out yet — retried next build
    _shown = step;

    final media = MediaQuery.of(context);
    final screenH = media.size.height;
    final safeTop = media.padding.top;
    final safeBottom = media.padding.bottom;
    const gap = 14.0; // space between the focus ring and the card

    // Pick the side with more vertical room, then cap the card to it so the
    // package (which anchors content by a single edge inside a clipping Stack)
    // can never push it past a screen edge.
    final spaceAbove = rect.top - safeTop - focusPadding;
    final spaceBelow = screenH - safeBottom - rect.bottom - focusPadding;
    final placeBelow = spaceBelow >= spaceAbove;
    final rawSpace = placeBelow ? spaceBelow : spaceAbove;
    final maxCardH = (rawSpace - gap - 16).clamp(96.0, screenH * 0.6);

    final position = placeBelow
        ? CustomTargetContentPosition(
            top: rect.bottom + focusPadding + gap,
            left: 0,
            right: 0,
          )
        : CustomTargetContentPosition(
            bottom: (screenH - rect.top) + focusPadding + gap,
            left: 0,
            right: 0,
          );

    final gated = step == WalkStep.createProject;
    final content = TargetContent(
      align: ContentAlign.custom,
      customPosition: position,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      builder: (_, _) => WalkthroughCard(
        step: step,
        onSkip: skip,
        onNext: gated ? null : advance,
        hint: gated ? 'Tap + to continue' : null,
        maxHeight: maxCardH,
      ),
    );

    _coach = TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: step.name,
          keyTarget: key,
          targetPosition: key == null ? targetPosition : null,
          shape: shape,
          radius: radius,
          paddingFocus: focusPadding,
          enableTargetTab: gated,
          enableOverlayTab: false,
          // Gentle breathe (subtle scale) instead of the package's snappy
          // default so the create-project highlight pulses smoothly.
          pulseVariation: gated ? Tween(begin: 1.0, end: 0.965) : null,
          contents: [content],
        ),
      ],
      colorShadow: AppColors.black,
      opacityShadow: 0.82,
      hideSkip: true,
      pulseEnable: gated,
      // Slow the pulse down from the 500ms default — the fast throb looked
      // jittery, especially over a large target like the New Project card.
      pulseAnimationDuration: const Duration(milliseconds: 500),
      onClickTarget: gated ? (_) => _onCreateTap() : null,
    );
    _coach!.show(context: context, rootOverlay: true);
  }

  /// Global (root-overlay) screen rect of the target, or null if not yet laid
  /// out. Matches the coordinate space the coach uses (`rootOverlay: true`).
  Rect? _targetRect(GlobalKey? key, TargetPosition? targetPosition) {
    if (key != null) {
      final ctx = key.currentContext;
      final box = ctx?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return null;
      return box.localToGlobal(Offset.zero) & box.size;
    }
    if (targetPosition != null) {
      return targetPosition.offset & targetPosition.size;
    }
    return null;
  }

  void _showInfoDialog(
    WalkStep step, {
    required String nextLabel,
    bool isFinish = false,
  }) {
    final ctx = _ctx;
    if (ctx == null) return;
    showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(step.title),
        content: Text(step.description),
        actions: [
          if (!isFinish)
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                skip();
              },
              child: const Text('Skip'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              advance();
            },
            child: Text(nextLabel),
          ),
        ],
      ),
    );
  }

  void _dismissCoach() {
    _coach?.finish();
    _coach = null;
  }
}
