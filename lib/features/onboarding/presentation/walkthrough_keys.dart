import 'package:flutter/widgets.dart';

/// Global keys for every widget the walkthrough spotlights. They live in one
/// place so the [WalkthroughController] (which owns the tour) and the screens
/// that render the targets can share the same key instances.
class WalkthroughKeys {
  WalkthroughKeys._();

  /// Create-project FAB on the project selection screen.
  static final GlobalKey createProject = GlobalKey(debugLabel: 'wt_createProject');

  /// Budget overview card on the dashboard.
  static final GlobalKey budgetCard = GlobalKey(debugLabel: 'wt_budgetCard');

  /// Photos / timeline quick action on the dashboard.
  static final GlobalKey photosAction = GlobalKey(debugLabel: 'wt_photosAction');

  /// Add-expense button on the expense screen.
  static final GlobalKey addExpense = GlobalKey(debugLabel: 'wt_addExpense');

  /// Bottom-navigation tab icons.
  static final GlobalKey navExpenses = GlobalKey(debugLabel: 'wt_navExpenses');
  static final GlobalKey navMaterials = GlobalKey(debugLabel: 'wt_navMaterials');
  static final GlobalKey navReports = GlobalKey(debugLabel: 'wt_navReports');
}
