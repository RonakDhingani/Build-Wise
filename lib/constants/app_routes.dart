abstract class AppRoutes {
  static const String root = '/';
  static const String projects = '/projects';
  static const String createProject = '/projects/create';
  static const String editProject = '/projects/:id/edit';
  static const String dashboard = '/projects/:id/dashboard';
  static const String expenses = '/projects/:id/expenses';
  static const String expenseDetail = '/projects/:id/expenses/:expenseId';
  static const String materials = '/projects/:id/materials';
  static const String materialDetail = '/projects/:id/materials/:materialId';
  static const String reports = '/projects/:id/reports';
  static const String pdfViewer = '/projects/:id/reports/pdf';
  static const String projectSettings = '/projects/:id/settings';
  static const String stages = '/projects/:id/stages';
  static const String stageDetail = '/projects/:id/stages/:stageId';
}
