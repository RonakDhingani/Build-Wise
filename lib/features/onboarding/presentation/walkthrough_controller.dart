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
  int? _projectId;
  TutorialCoachMark? _coach;
  WalkStep? _shown;

  @override
  WalkStep build() => WalkStep.idle;

  BuildContext? get _ctx => rootNavigatorKey.currentContext;

  // ---- Entry points ----

  void beginFirstRun() {
    if (state != WalkStep.idle) return;
    _firstRun = true;
    _projectId = null;
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
  void maybeShowCoach(
    BuildContext context,
    WalkStep step, {
    required GlobalKey key,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
    ContentAlign align = ContentAlign.bottom,
  }) {
    if (state != step || _shown == step) return;
    if (key.currentContext == null) return; // target not laid out yet
    _shown = step;

    final gated = step == WalkStep.createProject;
    final content = TargetContent(
      align: align,
      builder: (_, _) => WalkthroughCard(
        step: step,
        onSkip: skip,
        onNext: gated ? null : advance,
        hint: gated ? 'Tap + to continue' : null,
      ),
    );

    _coach = TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: step.name,
          keyTarget: key,
          shape: shape,
          radius: 12,
          enableTargetTab: gated,
          enableOverlayTab: false,
          contents: [content],
        ),
      ],
      colorShadow: AppColors.black,
      opacityShadow: 0.82,
      hideSkip: true,
      pulseEnable: !gated ? false : true,
      onClickTarget: gated ? (_) => _onCreateTap() : null,
    );
    _coach!.show(context: context, rootOverlay: true);
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
