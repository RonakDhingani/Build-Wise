part of 'app_router.dart';

abstract class AppRoutePaths {
  static const String root = '/';
  static const String projects = '/projects';
  static const String createProject = '/projects/create';
}

abstract class AppRouteNames {
  static const String projects = 'projects';
  static const String createProject = 'create-project';
  static const String editProject = 'edit-project';
  static const String dashboard = 'dashboard';
  static const String expenses = 'expenses';
  static const String addExpense = 'add-expense';
  static const String expenseDetail = 'expense-detail';
  static const String editExpense = 'edit-expense';
  static const String materials = 'materials';
  static const String addMaterial = 'add-material';
  static const String materialDetail = 'material-detail';
  static const String editMaterial = 'edit-material';
  static const String reports = 'reports';
  static const String pdfViewer = 'pdf-viewer';
  static const String projectSettings = 'project-settings';
  static const String stages = 'stages';
  static const String stageDetail = 'stage-detail';
  static const String addStage = 'add-stage';
  static const String editStage = 'edit-stage';
  static const String photos = 'photos';
  static const String photoDetail = 'photo-detail';

  // Settings sub-screens
  static const String manageProjects = 'manage-projects';
  static const String defaultProject = 'default-project';
  static const String expenseCategories = 'expense-categories';
  static const String currency = 'currency';
  static const String dateFormat = 'date-format';
  static const String theme = 'theme';
  static const String about = 'about';
  static const String privacyPolicy = 'privacy-policy';
  static const String terms = 'terms';
  static const String contactSupport = 'contact-support';
}
