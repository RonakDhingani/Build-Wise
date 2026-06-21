# BuildWise — Feature Breakdown

Detailed breakdown by feature, implementation order, and dependencies.

---

## 1. Feature Priority Matrix

| Feature | Priority | Complexity | Dependencies |
|---------|----------|------------|-------------|
| Core Setup (DB, DI, Router, Theme) | P0 | Medium | None |
| Shared Design System | P0 | Medium | None |
| Shared Widget Library | P0 | High | Design System |
| Project Management | P1 | Medium | Core, Shared |
| Dashboard | P1 | Medium | Project, Expense, Stage |
| Construction Stages | P1 | Medium | Project |
| Expense Tracking | P1 | Medium | Project, Stage |
| Material Management | P2 | Medium | Project, Stage |
| Photo Management | P2 | Low | Stage |
| Reports (PDF) | P2 | High | All features |
| Settings | P3 | Low | Core |

---

## 2. Feature 0: Core Infrastructure

### 2.1 Database Setup
- [ ] Isar initialization service (`IsarService`)
- [ ] Database provider (global singleton)
- [ ] Schema models for all collections
- [ ] Isar code generation setup

### 2.2 Dependency Injection
- [ ] Global provider file (`core/di/providers.dart`)
- [ ] Repository providers
- [ ] Use case providers
- [ ] Service providers

### 2.3 Navigation
- [ ] go_router configuration
- [ ] Route names constants
- [ ] Shell route with bottom navigation
- [ ] Redirect logic (no projects → create)

### 2.4 App Entry
- [ ] `main.dart` with ProviderScope
- [ ] MaterialApp with AppTheme.light
- [ ] Font loading (Inter)

### 2.5 Error Handling
- [ ] `Result<T>` sealed class
- [ ] `AppFailure` sealed classes
- [ ] Global error boundary

---

## 3. Feature 1: Design System Implementation

### 3.1 Constants
- [ ] `AppColors` class
- [ ] `LightThemeColors` class
- [ ] `AppTextStyles` class
- [ ] `AppSpacing` class
- [ ] `AppDimensions` class
- [ ] `AppShadows` class
- [ ] `AppStrings` class
- [ ] `AppAssets` class
- [ ] `AppTheme.light`

### 3.2 Utilities
- [ ] `DateFormatter`
- [ ] `CurrencyFormatter`
- [ ] `Validators`
- [ ] `ImageHelpers`
- [ ] `FileHelpers`
- [ ] `PdfHelpers`

---

## 4. Feature 2: Shared Widget Library

### 4.1 Buttons (4 widgets)
- [ ] AppPrimaryButton
- [ ] AppSecondaryButton
- [ ] AppOutlineButton
- [ ] AppIconButton

### 4.2 Inputs (5 widgets)
- [ ] AppTextField
- [ ] AppSearchField
- [ ] AppDropdownField
- [ ] AppDatePickerField
- [ ] AppCurrencyField

### 4.3 Cards (4 widgets)
- [ ] AppSummaryCard
- [ ] AppExpenseCard
- [ ] AppMaterialCard
- [ ] AppStageCard

### 4.4 Feedback (4 widgets)
- [ ] AppLoadingWidget
- [ ] AppEmptyState
- [ ] AppErrorState
- [ ] AppSuccessState

### 4.5 Dialogs (3 widgets)
- [ ] AppConfirmationDialog
- [ ] AppDeleteDialog
- [ ] AppSuccessDialog

### 4.6 Layout (4 widgets)
- [ ] AppScaffold
- [ ] AppBarWidget
- [ ] SectionHeader
- [ ] AppBottomSheet

### 4.7 Specialized (5 widgets)
- [ ] BudgetProgressBar
- [ ] StageStatusChip
- [ ] AmountText
- [ ] PhotoGridWidget
- [ ] CategoryColorDot

### 4.8 Barrel export file
- [ ] `lib/shared/widgets/index.dart`

---

## 5. Feature 3: Project Management

### 5.1 Data Layer
- [ ] `ProjectIsarModel` schema
- [ ] `ProjectMapper` (Isar ↔ Entity)
- [ ] `ProjectRepositoryImpl`
  - createProject(entity) → Result
  - updateProject(entity) → Result
  - deleteProject(id) → Result (cascade)
  - archiveProject(id) → Result
  - getProjects(status) → Result<List>
  - getProjectById(id) → Result

### 5.2 Domain Layer
- [ ] `ProjectEntity` (pure Dart)
- [ ] `ProjectRepository` (abstract)
- [ ] Use cases (6): Create, Update, Delete, Archive, GetAll, GetById

### 5.3 Presentation Layer
- [ ] `ProjectProvider` (repository DI)
- [ ] `ProjectsNotifier` (AsyncNotifier<List<ProjectEntity>>)
  - State: loading, data, error
  - Actions: create, update, delete, archive
- [ ] `ActiveProjectProvider` (StateProvider<int?> — selected project ID)

### 5.4 Screens
- [ ] ProjectSelectionScreen
  - Empty state (illustration)
  - Project cards list
  - Search + filter
  - FAB: "+ New Project"
- [ ] CreateProjectScreen
  - Form with all fields
  - Validation
  - Cover photo picker (optional)
  - Save → navigate to dashboard
- [ ] EditProjectScreen
  - Pre-populated form
  - Archive/Delete actions

### 5.5 Seeding
- [ ] Seed 10 default stages on project create
- [ ] Seed in transaction (atomic)

---

## 6. Feature 4: Dashboard

### 6.1 Domain Layer
- [ ] `DashboardSummary` entity (computed data aggregate)
- [ ] `GetDashboardSummaryUseCase`
  - Inputs: projectId
  - Outputs: budget, spent, remaining, completionPercent, activeStage, recentExpenses(5), materialCount

### 6.2 Presentation Layer
- [ ] `DashboardSummaryProvider` (FutureProvider, watches activeProject)
- [ ] `DashboardNotifier` (refresh actions)

### 6.3 Dashboard Screen
- [ ] Header: project name + switch project tap
- [ ] BudgetSummaryCard (hero widget)
  - Total budget
  - Amount spent
  - Remaining (color-coded)
  - BudgetProgressBar
- [ ] StageProgressWidget
  - Active stage chip
  - Overall progress %
- [ ] RecentExpensesList
  - Last 5 expenses
  - "View all" link
- [ ] QuickActionsBar
  - [+ Expense] [+ Material] [Report]
- [ ] MaterialAlertWidget (if low stock)

### 6.4 Dashboard Feature Widgets
- [ ] `BudgetSummaryCard`
- [ ] `StageProgressWidget`
- [ ] `RecentExpensesList`
- [ ] `QuickActionsBar`
- [ ] `MaterialAlertBanner`

---

## 7. Feature 5: Construction Stages

### 7.1 Data Layer
- [ ] `StageIsarModel`
- [ ] `StageMapper`
- [ ] `StageRepositoryImpl`
  - getStagesByProject(projectId)
  - createStage(entity)
  - updateStage(entity)
  - deleteStage(id)
  - reorderStages(projectId, orderedIds)

### 7.2 Domain Layer
- [ ] `StageEntity`
- [ ] `StageRepository` (abstract)
- [ ] Use cases (5): GetByProject, Create, Update, Delete, Reorder

### 7.3 Presentation Layer
- [ ] `StageNotifier` (AsyncNotifier)
- [ ] `StageProvider`

### 7.4 Screens
- [ ] StagesScreen
  - ReorderableListView of stage cards
  - Stage status badges
  - Progress bars
  - FAB: "+ Custom Stage"
- [ ] StageDetailScreen
  - Status picker
  - Date fields
  - Progress slider (0–100)
  - Notes field
  - PhotoGridWidget
  - [Mark Complete] button

### 7.5 Business Rules
- [ ] Mark complete: set status=completed, record endDate
- [ ] Reorder: update all orderIndex values in batch transaction
- [ ] Cannot delete default stages (isDefault=true) — only custom

---

## 8. Feature 6: Expense Tracking

### 8.1 Data Layer
- [ ] `ExpenseIsarModel`
- [ ] `ExpenseCategoryIsarModel`
- [ ] `ExpenseMapper`
- [ ] `ExpenseRepositoryImpl`
  - getExpensesByProject(projectId, filters)
  - addExpense(entity)
  - updateExpense(entity)
  - deleteExpense(id)
  - getTotalSpent(projectId) → double
  - getExpensesByCategory(projectId) → Map<String, double>
  - getCategories() → List
  - createCategory(name)

### 8.2 Domain Layer
- [ ] `ExpenseEntity`
- [ ] `ExpenseCategoryEntity`
- [ ] `ExpenseRepository` (abstract)
- [ ] `ExpenseFilters` value object
- [ ] Use cases (5): Add, Update, Delete, GetFiltered, GetSummary

### 8.3 Presentation Layer
- [ ] `ExpenseNotifier`
- [ ] `ExpenseFilterProvider` (StateProvider<ExpenseFilters>)

### 8.4 Screens + Sheets
- [ ] ExpenseScreen
  - Total bar at top
  - Filter chips (category, stage, date)
  - Expense list (date-grouped)
  - FAB + Quick add from dashboard
- [ ] AddExpenseBottomSheet (≤ 10 second flow)
  - Amount (auto-focus)
  - Category chips (horizontal scroll)
  - Date quick-pick (Today/Yesterday/Custom)
  - "+ More" expander for optional fields
  - Sticky save button
- [ ] ExpenseDetailScreen
  - Full expense view
  - Bill image (fullscreen tap)
  - Edit / Delete actions
- [ ] CategoryManagementScreen (in Settings)

### 8.5 Seeding
- [ ] Seed 10 default categories on first app launch

---

## 9. Feature 7: Material Management

### 9.1 Data Layer
- [ ] `MaterialIsarModel`
- [ ] `MaterialMapper`
- [ ] `MaterialRepositoryImpl`
  - getMaterialsByProject(projectId)
  - addMaterial(entity)
  - updateMaterial(entity)
  - deleteMaterial(id)
  - updateQuantityUsed(id, quantity)
  - getLowStockMaterials(projectId) → List

### 9.2 Domain Layer
- [ ] `MaterialEntity`
- [ ] `MaterialRepository` (abstract)
- [ ] Use cases (5): Add, Update, Delete, GetByProject, GetLowStock

### 9.3 Presentation Layer
- [ ] `MaterialNotifier`
- [ ] `MaterialFilterProvider`

### 9.4 Screens
- [ ] MaterialScreen
  - Material cost summary card
  - Filter: by stage, low stock only
  - Material list (AppMaterialCard)
  - FAB: "+ Material"
- [ ] AddMaterialBottomSheet
  - Name (autocomplete from defaults list)
  - Unit dropdown
  - Qty purchased
  - Optional: qty used, cost, vendor, stage
- [ ] MaterialDetailScreen
  - All fields view
  - "Update Usage" button (quick qty used update)
  - Edit / Delete

### 9.5 Default Materials
- [ ] In-memory constant list of 19 default material names
- [ ] Autocomplete from this list in name field

---

## 10. Feature 8: Photo Management

### 10.1 Data Layer
- [ ] `PhotoIsarModel`
- [ ] `PhotoMapper`
- [ ] `PhotoRepositoryImpl`
  - getPhotosByStage(stageId)
  - getPhotosByProject(projectId)
  - addPhoto(entity)
  - deletePhoto(id)

### 10.2 Services
- [ ] `ImageHelpers.captureFromCamera()` → compressed path
- [ ] `ImageHelpers.pickFromGallery()` → compressed path
- [ ] `ImageHelpers.compress(path)` → Result<String> (saves to app dir)

### 10.3 Screens
- [ ] Integrated in StageDetailScreen (PhotoGridWidget)
- [ ] FullscreenPhotoViewer
  - Swipe between photos
  - Delete button
  - Share button

---

## 11. Feature 9: Reports (PDF)

### 11.1 Services
- [ ] `PdfReportService`
  - generateBudgetReport(projectId) → Result<Uint8List>
  - generateExpenseReport(projectId, filters) → Result<Uint8List>
  - generateMaterialReport(projectId) → Result<Uint8List>
  - generateProgressReport(projectId) → Result<Uint8List>

### 11.2 PDF Template Components
- [ ] `PdfHeader` (BuildWise logo, project name, date)
- [ ] `PdfFooter` (page number, generated timestamp)
- [ ] `PdfSummaryTable`
- [ ] `PdfExpenseTable`
- [ ] `PdfMaterialTable`
- [ ] `PdfStageTimeline`

### 11.3 Domain Layer
- [ ] 4 use cases (one per report type)

### 11.4 Screens
- [ ] ReportsScreen (4 report type cards)
- [ ] ReportFilterSheet (date range, optional filters)
- [ ] PdfViewerScreen
  - Embedded PDF view (`printing` package)
  - Share action (system share sheet)
  - Download action (save to Downloads)

---

## 12. Feature 10: Settings

### 12.1 Data Layer
- [ ] `AppSettingsIsarModel`
- [ ] `SettingsRepositoryImpl`
  - getSettings() → AppSettingsEntity
  - updateSettings(entity)

### 12.2 Screens
- [ ] SettingsScreen
  - Currency selector (INR default)
  - Date format picker
  - "Manage Categories" link
  - "Export Data" action
  - "Import Data" action
  - App version
  - BuildWise branding footer

---

## 13. Constants & Strings

### AppStrings (excerpt)
```dart
abstract class AppStrings {
  // Navigation
  static const String dashboard   = 'Dashboard';
  static const String expenses    = 'Expenses';
  static const String materials   = 'Materials';
  static const String reports     = 'Reports';
  static const String settings    = 'Settings';

  // Projects
  static const String newProject       = 'New Project';
  static const String projectName      = 'Project Name';
  static const String location         = 'Location';
  static const String budget           = 'Budget';
  static const String createProject    = 'Create Project';
  static const String noProjectsTitle  = 'No projects yet';
  static const String noProjectsSub    = 'Create your first project to get started';

  // Expenses
  static const String addExpense   = 'Add Expense';
  static const String amount       = 'Amount';
  static const String category     = 'Category';
  static const String date         = 'Date';
  static const String vendor       = 'Vendor';
  static const String description  = 'Description';

  // Actions
  static const String save         = 'Save';
  static const String cancel       = 'Cancel';
  static const String delete       = 'Delete';
  static const String edit         = 'Edit';
  static const String confirm      = 'Confirm';
  static const String undo         = 'Undo';

  // Errors
  static const String genericError   = 'Something went wrong. Please try again.';
  static const String required       = 'This field is required';
  static const String invalidAmount  = 'Enter a valid amount';

  // ... all other strings
}
```

### AppAssets
```dart
abstract class AppAssets {
  static const String _base = 'assets/';
  static const String logo           = '${_base}images/buildwise_logo.png';
  static const String logoWhite      = '${_base}images/buildwise_logo_white.png';
  static const String emptyProjects  = '${_base}illustrations/empty_projects.svg';
  static const String emptyExpenses  = '${_base}illustrations/empty_expenses.svg';
  static const String emptyMaterials = '${_base}illustrations/empty_materials.svg';
}
```
