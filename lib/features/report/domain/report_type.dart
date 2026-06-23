/// Kinds of report the user can open from the Reports screen.
///
/// [full] is the unified report opened by the "Export Report (PDF)" button;
/// the others are scoped to a single section.
enum ReportType {
  full,
  budget,
  expense,
  material,
  progress;

  /// Stable id used as the `type` query param on the pdf route.
  String get id => name;

  static ReportType fromId(String? id) => ReportType.values.firstWhere(
        (t) => t.id == id,
        orElse: () => ReportType.full,
      );

  /// Title shown in the viewer app bar.
  String get appBarTitle => switch (this) {
        ReportType.full => 'Report',
        ReportType.budget => 'Budget Report',
        ReportType.expense => 'Expense Report',
        ReportType.material => 'Material Report',
        ReportType.progress => 'Progress Report',
      };

  /// Heading printed on the PDF cover.
  String get coverTitle => switch (this) {
        ReportType.full => 'PROJECT REPORT',
        ReportType.budget => 'BUDGET REPORT',
        ReportType.expense => 'EXPENSE REPORT',
        ReportType.material => 'MATERIAL REPORT',
        ReportType.progress => 'PROGRESS REPORT',
      };

  /// Suffix used in the generated file name.
  String get fileSuffix => switch (this) {
        ReportType.full => 'Report',
        ReportType.budget => 'Budget_Report',
        ReportType.expense => 'Expense_Report',
        ReportType.material => 'Material_Report',
        ReportType.progress => 'Progress_Report',
      };
}
