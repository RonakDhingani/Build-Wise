/// Ordered steps of the product tour. [idle] = tour not running.
///
/// Visible steps are numbered 1..[totalSteps] for the "X of N" counter.
enum WalkStep {
  idle,
  welcome,
  createProject,
  budget,
  expensesTab,
  addExpense,
  materialsTab,
  photos,
  reportsTab,
  finish,
}

extension WalkStepX on WalkStep {
  /// Total number of user-visible steps (welcome..finish).
  static const int totalSteps = 9;

  /// 1-based number for the step counter (0 for idle).
  int get number => this == WalkStep.idle ? 0 : index;

  String get title => switch (this) {
        WalkStep.welcome => 'Welcome to Build Wise',
        WalkStep.createProject => 'Create Your First Project',
        WalkStep.budget => 'Project Dashboard',
        WalkStep.expensesTab => 'Track Expenses',
        WalkStep.addExpense => 'Add Expense',
        WalkStep.materialsTab => 'Manage Materials',
        WalkStep.photos => 'Project Timeline',
        WalkStep.reportsTab => 'Reports & Analytics',
        WalkStep.finish => "You're Ready",
        WalkStep.idle => '',
      };

  String get description => switch (this) {
        WalkStep.welcome =>
          'Track your construction budget, expenses, materials, progress and project journey in one place.',
        WalkStep.createProject =>
          'Start by creating a construction project and adding basic project details.',
        WalkStep.budget =>
          'Quickly view budget, spending and overall project progress.',
        WalkStep.expensesTab =>
          'Record labor, material, electrical, plumbing and other construction costs.',
        WalkStep.addExpense =>
          'Keep your budget accurate by recording every project expense.',
        WalkStep.materialsTab =>
          'Track purchased materials, costs, quantities and remaining stock.',
        WalkStep.photos =>
          'Capture site photos and build a visual history of your construction journey.',
        WalkStep.reportsTab =>
          'View spending trends, stage progress and project insights through charts and reports.',
        WalkStep.finish =>
          'Your project is ready to be managed with Build Wise.',
        WalkStep.idle => '',
      };
}
