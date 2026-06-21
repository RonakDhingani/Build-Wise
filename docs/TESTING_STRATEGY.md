# BuildWise — Testing Strategy

---

## 1. Testing Philosophy

- Test behavior, not implementation
- Test at the lowest possible level (unit > widget > integration)
- Each test has one clear assertion
- Tests must be fast and deterministic
- No test depends on another test's side effects
- 80% coverage target on domain + data layers

---

## 2. Test Pyramid

```
         ┌────────────────┐
         │  Integration   │  ~10% — slow, high value
         │  Tests (E2E)   │
         ├────────────────┤
         │ Widget Tests   │  ~30% — medium speed
         │                │
         ├────────────────┤
         │  Unit Tests    │  ~60% — fast, numerous
         │                │
         └────────────────┘
```

---

## 3. Unit Testing

### 3.1 Tools

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.x         # mocking
  fake_async: ^1.x       # timer/async testing
```

### 3.2 Use Cases

Test file pattern: `test/features/{feature}/domain/use_cases/{name}_test.dart`

**CreateProjectUseCaseTest**
```
✓ creates project when all valid fields provided
✓ returns ValidationFailure when name is empty
✓ returns ValidationFailure when budget is 0
✓ returns ValidationFailure when budget is negative
✓ returns DatabaseFailure when repository throws
✓ seeds 10 default stages after project creation
```

**UpdateProjectUseCaseTest**
```
✓ updates project successfully
✓ returns NotFoundFailure for non-existent id
✓ preserves unchanged fields
✓ updates updatedAt timestamp
```

**DeleteProjectUseCaseTest**
```
✓ deletes project and cascades stages, expenses, materials, photos
✓ returns NotFoundFailure for non-existent id
✓ cascade is atomic (all or nothing)
```

**AddExpenseUseCaseTest**
```
✓ adds expense for valid project
✓ returns ValidationFailure for zero amount
✓ returns ValidationFailure for future date (if enforced)
✓ updates project totalSpent
```

**GetDashboardSummaryUseCaseTest**
```
✓ returns correct totalBudget from project
✓ returns correct totalSpent (sum of all expenses)
✓ returns correct remainingBudget
✓ returns correct completionPercent
✓ returns empty recentExpenses for new project
✓ returns last 5 expenses sorted by date desc
✓ returns active stage (in-progress status)
```

**ReorderStagesUseCaseTest**
```
✓ reorders stages correctly
✓ all stages get correct orderIndex after reorder
✓ reorder is atomic
```

---

### 3.3 Repositories (with mocked Isar)

Use `mocktail` to mock `IsarService`.

**ProjectRepositoryImplTest**
```
✓ getProjects returns only active projects
✓ getProjects returns only archived when filtered
✓ createProject writes to Isar and returns entity
✓ updateProject updates correct record
✓ deleteProject removes from Isar
✓ getProjectById returns correct entity
✓ getProjectById returns NotFoundFailure for missing id
✓ mapper correctly converts Isar model to entity
✓ mapper correctly converts entity to Isar model
```

**ExpenseRepositoryImplTest**
```
✓ getExpensesByProject filters by projectId
✓ getExpensesByProject applies date range filter
✓ getExpensesByProject applies category filter
✓ getTotalSpent returns correct sum
✓ getExpensesByCategory returns correct map
✓ addExpense with billImage saves image path
✓ deleteExpense removes bill image file
```

**MaterialRepositoryImplTest**
```
✓ getLowStockMaterials returns items with remaining < 10%
✓ updateQuantityUsed enforces quantityUsed ≤ quantityPurchased
✓ quantityRemaining auto-calculated correctly
```

---

### 3.4 Utilities

**DateFormatterTest**
```
✓ formats today as "Today"
✓ formats yesterday as "Yesterday"
✓ formats other dates as "dd MMM yyyy"
✓ formatShort returns "dd/MM/yyyy"
✓ handles null date gracefully
```

**CurrencyFormatterTest**
```
✓ formats 1000 as "₹1,000"
✓ formats 100000 as "₹1,00,000"
✓ formats 1000000 as "₹10,00,000"
✓ formats 10000000 as "₹1.0 Cr"
✓ formats 100000 as "₹1.0 L" (compact form)
✓ handles 0 correctly
✓ handles negative correctly (budget overrun)
```

**ValidatorsTest**
```
✓ validateRequired returns error for empty string
✓ validateRequired returns null for valid string
✓ validateAmount returns error for "abc"
✓ validateAmount returns error for "-5"
✓ validateAmount returns error for "0"
✓ validateAmount returns null for "100.50"
✓ validateProjectName returns error for >100 chars
✓ validateNotes returns error for >1000 chars
```

---

## 4. Widget Testing

Test file pattern: `test/shared/widgets/{name}_test.dart`

### 4.1 Tools

```dart
// Standard flutter_test + WidgetTester
// pump() for single frame, pumpAndSettle() for animations
```

### 4.2 Shared Widget Tests

**AppPrimaryButtonTest**
```
✓ renders label text correctly
✓ triggers onPressed when tapped
✓ shows loading indicator when isLoading=true
✓ does not trigger onPressed when isLoading=true
✓ appears disabled (opacity) when onPressed=null
✓ does not trigger onPressed when disabled
✓ shows icon when icon prop provided
```

**AppTextFieldTest**
```
✓ renders label
✓ shows hint text
✓ updates on text change
✓ shows error text when validator fails
✓ does not show error before interaction
✓ shows error on form submit
✓ disabled state: no input allowed
```

**AppCurrencyFieldTest**
```
✓ shows currency symbol prefix
✓ formats value with commas on focus lost
✓ rejects non-numeric input
✓ rejects negative values
```

**AppEmptyStateTest**
```
✓ renders title
✓ renders subtitle when provided
✓ hides subtitle when null
✓ shows action button when action provided
✓ hides action button when null
✓ triggers action when button tapped
```

**AppConfirmationDialogTest**
```
✓ renders title and message
✓ calls onConfirm when confirm tapped
✓ dismisses on cancel tap
✓ confirm button is red when isDangerous=true
✓ confirm button is primary color when isDangerous=false
```

**BudgetProgressBarTest**
```
✓ renders with correct width ratio (spent/budget)
✓ color is green when spent < 75%
✓ color is amber when spent 75–90%
✓ color is red when spent > 90%
✓ bar width does not exceed 100% (clamp)
```

### 4.3 Feature Widget Tests

**AddExpenseBottomSheetTest**
```
✓ amount field auto-focused on open
✓ category chips rendered for all default categories
✓ date defaults to today
✓ save button disabled when amount empty
✓ save button enabled when amount filled and category selected
✓ calls onSaved with correct expense data
✓ "+ More" expander shows optional fields
✓ optional fields hidden by default
```

**DashboardScreenTest** (with mocked providers)
```
✓ shows loading state while fetching summary
✓ shows budget, spent, remaining when data loaded
✓ shows empty recent expenses when no expenses
✓ shows last 5 expenses when expenses exist
✓ quick action buttons navigate correctly
✓ shows error state when summary fetch fails
```

---

## 5. Integration Testing

Test file pattern: `integration_test/{feature}_flow_test.dart`

### 5.1 Tools

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

### 5.2 Project Creation Flow

```
test: "User creates first project in under 60 seconds"

Steps:
1. App launches → ProjectSelectionScreen (empty state)
2. Tap "Create Project"
3. Enter project name: "My House"
4. Enter location: "Bangalore"
5. Enter budget: 5000000
6. Enter start date: today
7. Tap "Create Project"
Expected:
  - Dashboard shows "My House"
  - Budget shown as ₹50,00,000
  - 10 default stages created
  - Remaining = ₹50,00,000
```

### 5.3 Expense Flow

```
test: "User adds expense in under 10 seconds"

Setup: Project "My House" exists

Steps:
1. Dashboard → Tap "+ Expense"
2. Enter amount: 25000
3. Select category: "Labor"
4. Tap "Save"
Expected:
  - Expense appears in recent list
  - Total spent updated to ₹25,000
  - Remaining updated to budget - 25000
```

```
test: "User filters expenses by category"

Steps:
1. Navigate to Expense screen
2. Tap category filter: "Labor"
Expected:
  - Only Labor expenses shown
  - Total reflects filtered amount
```

### 5.4 Material Flow

```
test: "User adds and tracks cement usage"

Steps:
1. Materials screen → "+ Material"
2. Name: "Cement" (autocomplete)
3. Unit: bags
4. Qty purchased: 100
5. Cost per unit: 350
6. Save
Expected:
  - Cement appears in list
  - Total cost: ₹35,000
  - Remaining: 100 bags
  - No low stock alert

Then:
6. Tap cement → "Update Usage"
7. Set used to 95
Expected:
  - Remaining: 5 bags
  - Low stock alert appears (5% remaining)
  - Dashboard shows low stock banner
```

### 5.5 Report Generation Flow

```
test: "User generates Budget Report PDF in under 15 seconds"

Setup: Project with 3 expenses, 2 materials

Steps:
1. Navigate to Reports tab
2. Tap "Budget Report"
3. Tap "Generate PDF"
Expected:
  - PDF viewer opens within 5 seconds
  - PDF contains project name
  - PDF contains correct budget figures
  - Share button visible
```

---

## 6. Database Testing

Test file pattern: `test/core/database/{name}_test.dart`

Uses in-memory Isar (Isar.open with in-memory option).

### 6.1 CRUD Tests

```
ProjectRepository CRUD:
✓ create → read returns same data
✓ update → read returns updated data
✓ delete → read returns null
✓ list returns correct count

ExpenseRepository:
✓ cascade: delete project → expenses deleted
✓ filter by date range returns correct subset
✓ sum returns correct total
```

### 6.2 Data Integrity Tests

```
✓ Stage orderIndex unique per project (enforced in code)
✓ AppSettings id always 0 — only one settings record
✓ quantityUsed cannot exceed quantityPurchased (repository enforced)
✓ default categories not deletable if expenses reference them
✓ project delete cascades: stages, expenses, materials, photos deleted in transaction
```

### 6.3 Migration Tests

```
✓ Schema version 1 opens without error
✓ Future migration scaffold in place (no-op for V1)
```

---

## 7. UI/UX Testing

### 7.1 Accessibility

```
✓ All interactive elements have semantic labels
✓ All images have descriptive labels
✓ Minimum touch target 48×48dp (visual inspection + automated check)
✓ Color contrast ≥ 4.5:1 for body text (design review)
✓ Forms usable with TalkBack enabled
```

### 7.2 State Coverage

For every screen, verify:
```
✓ Loading state renders without overflow
✓ Empty state renders with illustration + CTA
✓ Error state renders with retry option
✓ Data state renders correctly with 1 item
✓ Data state renders correctly with 100 items (no overflow)
```

### 7.3 Keyboard / Overflow

```
✓ Forms scroll above keyboard
✓ No RenderFlex overflow on any screen at 360dp width
✓ Long project names truncated correctly
✓ Large amounts formatted correctly (₹1Cr)
```

---

## 8. Code Quality Standards

### 8.1 Linting Rules (`analysis_options.yaml`)

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - avoid_empty_else
    - avoid_print
    - avoid_unnecessary_containers
    - prefer_const_constructors
    - prefer_final_fields
    - prefer_final_locals
    - use_key_in_widget_constructors
    - sized_box_for_whitespace
    - avoid_redundant_argument_values
```

### 8.2 Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Classes | PascalCase | `ProjectEntity` |
| Variables | camelCase | `totalSpent` |
| Constants | camelCase | `AppSpacing.lg` |
| Files | snake_case | `project_entity.dart` |
| Directories | snake_case | `use_cases/` |
| Private members | _camelCase | `_isLoading` |
| Enums | PascalCase values | `StageStatus.inProgress` |

### 8.3 File Organization Rules

- One class per file (with rare exceptions for small related classes)
- File name matches primary class name
- Barrel exports for each module
- No circular imports between features

### 8.4 CI/CD Checks (Future)

```
- flutter analyze (zero errors, zero warnings)
- flutter test (all tests pass)
- dart format --set-exit-if-changed (formatted)
- flutter build apk --release (builds successfully)
```

---

## 9. Test Coverage Targets

| Layer | Target Coverage |
|-------|----------------|
| Domain (entities, use cases) | 90% |
| Data (repositories, mappers) | 80% |
| Utilities | 95% |
| Shared Widgets | 70% |
| Feature Screens | 50% |
| Integration Flows | 4 critical paths |

Run coverage:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```
