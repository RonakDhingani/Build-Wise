abstract class AppStrings {
  // App
  static const String appName = 'BuildWise';
  static const String tagline = 'Track your construction, control your costs.';

  // Navigation
  static const String navDashboard = 'Dashboard';
  static const String navExpenses = 'Expenses';
  static const String navMaterials = 'Materials';
  static const String navReports = 'Reports';
  static const String navSettings = 'Settings';

  // Projects
  static const String projects = 'Projects';
  static const String createProject = 'Create Project';
  static const String editProject = 'Edit Project';
  static const String noProjects = 'No projects yet';
  static const String noProjectsSubtitle = 'Create your first construction project to get started.';
  static const String projectName = 'Project Name';
  static const String projectNameExists =
      'A project with this name already exists';
  static const String projectLocation = 'Location';
  static const String projectBudget = 'Total Budget';
  static const String startDate = 'Start Date';
  static const String expectedCompletion = 'Expected Completion';
  static const String plotSize = 'Plot Size';
  static const String builtUpArea = 'Built-up Area';
  static const String numberOfFloors = 'Number of Floors';
  static const String notes = 'Notes';

  // Dashboard
  static const String totalBudget = 'Total Budget';
  static const String totalSpent = 'Total Spent';
  static const String remaining = 'Remaining';
  static const String recentExpenses = 'Recent Expenses';
  static const String overallProgress = 'Overall Progress';
  static const String quickActions = 'Quick Actions';
  static const String addExpense = '+ Expense';
  static const String addMaterial = '+ Material';
  static const String generateReport = 'Report';

  // Expenses
  static const String expenses = 'Expenses';
  static const String addExpenseTitle = 'Add Expense';
  static const String editExpenseTitle = 'Edit Expense';
  static const String amount = 'Amount';
  static const String category = 'Category';
  static const String date = 'Date';
  static const String description = 'Description (Optional)';
  static const String vendor = 'Vendor (Optional)';
  static const String paymentType = 'Payment Type';
  static const String stageLink = 'Link to Stage (Optional)';
  static const String billImage = 'Bill Image';
  static const String noExpenses = 'No expenses recorded';
  static const String noExpensesSubtitle = 'Tap + to add your first expense.';

  // Materials
  static const String materials = 'Materials';
  static const String addMaterialTitle = 'Add Material';
  static const String editMaterialTitle = 'Edit Material';
  static const String materialName = 'Material Name';
  static const String unit = 'Unit';
  static const String quantityPurchased = 'Quantity Purchased';
  static const String quantityUsed = 'Quantity Used';
  static const String costPerUnit = 'Cost per Unit (Optional)';
  static const String noMaterials = 'No materials added';
  static const String noMaterialsSubtitle = 'Start tracking materials for this project.';

  // Stages
  static const String stages = 'Stages';
  static const String addStage = 'Add Stage';
  static const String addStageTitle = 'Add Stage';
  static const String editStageTitle = 'Edit Stage';
  static const String stageName = 'Stage Name';
  static const String stageStatus = 'Status';
  static const String markComplete = 'Mark Complete';
  static const String progress = 'Progress';

  // Reports
  static const String reports = 'Reports';
  static const String budgetReport = 'Budget Report';
  static const String expenseReport = 'Expense Report';
  static const String materialReport = 'Material Report';
  static const String progressReport = 'Project Progress Report';
  static const String generatePdf = 'Generate PDF';
  static const String share = 'Share';
  static const String download = 'Download';

  // Settings
  static const String settings = 'Settings';
  static const String currency = 'Currency';
  static const String dateFormat = 'Date Format';
  static const String exportData = 'Export Data';
  static const String importData = 'Import Data';
  static const String manageCategories = 'Manage Categories';
  static const String about = 'About';

  // Common
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String confirm = 'Confirm';
  static const String seeAll = 'See all';
  static const String loading = 'Loading...';
  static const String retry = 'Try Again';
  static const String done = 'Done';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String archive = 'Archive';
  static const String active = 'Active';
  static const String archived = 'Archived';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String saveError = 'Failed to save. Try again.';
  static const String deleteError = 'Failed to delete. Try again.';
  static const String deleteConfirmTitle = 'Delete?';
  static const String deleteConfirmMessage = 'This action cannot be undone.';

  // Validation
  static const String requiredField = 'This field is required';
  static const String invalidAmount = 'Enter a valid amount';
  static const String positiveAmount = 'Amount must be greater than 0';
}
