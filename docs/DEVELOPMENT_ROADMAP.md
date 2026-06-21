# BuildWise — Development Roadmap

---

## Phase Structure

```
Phase 1: Foundation        (Week 1)
Phase 2: Design System     (Week 1–2)
Phase 3: Core Features     (Week 2–4)
Phase 4: Secondary Features (Week 4–5)
Phase 5: Reports & Polish  (Week 5–6)
Phase 6: QA & Release Prep (Week 6–7)
```

---

## Phase 1: Foundation Setup (Week 1, Days 1–3)

### Milestone: App boots with router, theme, and empty DB

#### P1.1 Project Scaffold
- [ ] Create Flutter project (`flutter create build_wise`)
- [ ] Add all dependencies to `pubspec.yaml`
- [ ] Configure `analysis_options.yaml` (flutter_lints + custom rules)
- [ ] Set up asset directories: `assets/images/`, `assets/icons/`, `assets/illustrations/`, `assets/fonts/`
- [ ] Add Inter font files
- [ ] Set Android min SDK to 21 in `build.gradle`

#### P1.2 Clean Architecture Skeleton
- [ ] Create folder structure per APP_ARCHITECTURE.md
- [ ] Create barrel exports for each layer
- [ ] Set up `core/` infrastructure

#### P1.3 Database
- [ ] Implement `IsarService` (open, close, singleton)
- [ ] Write all Isar schema models
- [ ] Run `flutter pub run build_runner build`
- [ ] Implement `MigrationService`
- [ ] Verify DB opens successfully on emulator

#### P1.4 Navigation
- [ ] Implement `AppRouter` with go_router
- [ ] Route constants in `AppRoutes`
- [ ] Shell route with placeholder bottom nav
- [ ] Redirect: no projects → `/projects`, projects → `/projects/:id/dashboard`

#### P1.5 Error Handling Core
- [ ] `Result<T>` sealed class
- [ ] `AppFailure` hierarchy

---

## Phase 2: Design System (Week 1–2, Days 3–7)

### Milestone: Design system implemented, widget catalog works

#### P2.1 Theme & Colors
- [ ] `AppColors` (full palette)
- [ ] `LightThemeColors` (semantic tokens)
- [ ] `AppTextStyles` (all scales)
- [ ] `AppSpacing` + `AppDimensions`
- [ ] `AppShadows`
- [ ] `AppTheme.light` wired into MaterialApp
- [ ] `BudgetHealthColors`
- [ ] `StageStatusColors`
- [ ] `CategoryColors`

#### P2.2 Constants
- [ ] `AppStrings` (all user-facing text)
- [ ] `AppAssets` (all asset paths)
- [ ] `AppConstants` (app name, defaults)

#### P2.3 Utilities
- [ ] `DateFormatter` (dd/MM/yyyy, relative: "Today", "Yesterday")
- [ ] `CurrencyFormatter` (₹1,23,456, ₹1.2L, ₹1.2Cr)
- [ ] `Validators` (required, amount, date, length)
- [ ] `ImageHelpers` (compress, save to docs dir)
- [ ] `FileHelpers` (paths, directory management)

#### P2.4 Shared Widget Library
- [ ] All buttons (4)
- [ ] All inputs (5)
- [ ] All cards (4)
- [ ] All feedback widgets (4)
- [ ] All dialogs (3)
- [ ] All layout widgets (4)
- [ ] Specialized widgets (BudgetProgressBar, StageStatusChip, AmountText, PhotoGridWidget)
- [ ] Barrel export: `shared/widgets/index.dart`

---

## Phase 3: Core Features (Week 2–4)

### Milestone: Full project lifecycle + expense + stages working

#### P3.1 Project Management (Days 8–11)
- [ ] `ProjectIsarModel` + Isar generation
- [ ] `ProjectMapper`
- [ ] `ProjectRepositoryImpl` (CRUD + archive + cascade delete)
- [ ] `ProjectEntity`
- [ ] `ProjectRepository` interface
- [ ] 6 use cases
- [ ] `ProjectsNotifier` (AsyncNotifier)
- [ ] `ActiveProjectProvider`
- [ ] `ProjectSelectionScreen` (empty state + card list)
- [ ] `CreateProjectScreen` (full form + validation)
- [ ] `EditProjectScreen`
- [ ] Stage seeding on project create (10 default stages)
- [ ] Settings seed (categories) on first launch

#### P3.2 Dashboard (Days 11–13)
- [ ] `DashboardSummary` entity
- [ ] `GetDashboardSummaryUseCase`
- [ ] `DashboardSummaryProvider`
- [ ] `DashboardScreen` with all sections
- [ ] `BudgetSummaryCard` widget
- [ ] `QuickActionsBar` widget

#### P3.3 Construction Stages (Days 13–16)
- [ ] `StageIsarModel` + generation
- [ ] `StageMapper`
- [ ] `StageRepositoryImpl`
- [ ] `StageEntity`
- [ ] 5 use cases
- [ ] `StageNotifier`
- [ ] `StagesScreen` (reorderable list)
- [ ] `StageDetailScreen` (full editing)
- [ ] Drag-and-drop reorder
- [ ] Mark complete flow

#### P3.4 Expense Tracking (Days 16–20)
- [ ] `ExpenseIsarModel` + `ExpenseCategoryIsarModel`
- [ ] `ExpenseMapper`
- [ ] `ExpenseRepositoryImpl` (with filters + aggregates)
- [ ] `ExpenseEntity` + `ExpenseCategoryEntity`
- [ ] 5 use cases
- [ ] `ExpenseNotifier` + filter provider
- [ ] `ExpenseScreen` (filtered list with date grouping)
- [ ] `AddExpenseBottomSheet` (critical UX: < 10 second flow)
- [ ] `ExpenseDetailScreen`
- [ ] Bill image capture + display

---

## Phase 4: Secondary Features (Week 4–5)

### Milestone: Materials, photos, settings working

#### P4.1 Material Management (Days 21–24)
- [ ] `MaterialIsarModel`
- [ ] `MaterialMapper`
- [ ] `MaterialRepositoryImpl`
- [ ] `MaterialEntity`
- [ ] 5 use cases
- [ ] `MaterialNotifier`
- [ ] `MaterialScreen`
- [ ] `AddMaterialBottomSheet` (with autocomplete)
- [ ] `MaterialDetailScreen`
- [ ] Low stock detection + dashboard alert

#### P4.2 Photo Management (Days 24–26)
- [ ] `PhotoIsarModel`
- [ ] `PhotoMapper`
- [ ] `PhotoRepositoryImpl`
- [ ] `PhotoEntity`
- [ ] `ImageHelpers.captureFromCamera()`
- [ ] `ImageHelpers.pickFromGallery()`
- [ ] `PhotoGridWidget` (integrated in StageDetailScreen)
- [ ] `FullscreenPhotoViewer`

#### P4.3 Settings (Days 26–28)
- [ ] `AppSettingsIsarModel`
- [ ] `SettingsRepositoryImpl`
- [ ] `SettingsNotifier`
- [ ] `SettingsScreen`
- [ ] Currency selection (INR, USD, EUR)
- [ ] Date format selection
- [ ] Category management screen
- [ ] Data export/import (JSON)

---

## Phase 5: Reports & PDF (Week 5–6)

### Milestone: All 4 reports generate and share successfully

#### P5.1 PDF Service (Days 29–33)
- [ ] `PdfReportService` structure
- [ ] `PdfHeader` + `PdfFooter` templates
- [ ] Budget Report PDF
- [ ] Expense Report PDF
- [ ] Material Report PDF
- [ ] Progress Report PDF
- [ ] BuildWise branding in all PDFs
- [ ] Page numbers + timestamps

#### P5.2 Report Screens (Days 33–35)
- [ ] `ReportsScreen` (4 type cards)
- [ ] `ReportFilterSheet` (date range)
- [ ] `PdfViewerScreen`
- [ ] Share via system share sheet
- [ ] Save to Downloads

---

## Phase 6: QA & Polish (Week 6–7)

### Milestone: Production-ready, tested, App Store/Play Store ready

#### P6.1 Testing (Days 36–40)
- [ ] Unit tests: all use cases, repositories, utilities, validators
- [ ] Widget tests: all shared widgets, forms, cards, dialogs
- [ ] Integration tests: project creation, expense flow, material flow, report generation
- [ ] DB tests: CRUD, cascade delete, data integrity
- [ ] Accessibility audit

#### P6.2 Performance
- [ ] Profile app cold start (target < 3s)
- [ ] Profile DB queries (target < 200ms)
- [ ] Profile PDF generation (target < 5s)
- [ ] Image lazy loading + thumbnail cache verification
- [ ] Memory leak check (Riverpod provider lifecycle)

#### P6.3 Polish
- [ ] All empty states: illustrations + copy
- [ ] All loading states: skeleton screens
- [ ] All error states: user-friendly messages
- [ ] Snackbar undo for delete actions
- [ ] Transitions between screens
- [ ] Keyboard dismissal on outside tap
- [ ] Form auto-scroll to error field

#### P6.4 Release Prep
- [ ] App icon (BuildWise branded)
- [ ] Splash screen
- [ ] Android manifest permissions (camera, storage)
- [ ] ProGuard rules (if release build)
- [ ] Version: 1.0.0+1
- [ ] Play Store listing content
- [ ] Screenshots (5+ per Play Store requirement)

---

## Dependency Graph

```
Foundation → Design System → Shared Widgets
                                    ↓
            Project Management → Dashboard
                    ↓
            Stages ← Expenses ← Materials
                    ↓
                  Photos
                    ↓
                 Reports
                    ↓
                Settings
```

Each feature gate: unit test passes before next feature starts.

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Isar migration complexity | Medium | High | Design schemas carefully upfront, add migration service from day 1 |
| PDF rendering performance | Medium | Medium | Test with large datasets early, use isolates if needed |
| Image storage size | High | Medium | Compress on capture, warn user at 500MB |
| go_router shell route complexity | Low | Medium | Prototype navigation early in Phase 1 |
| Drag-to-reorder stages | Low | Low | Use `reorderables` package, proven solution |

---

## V2 Readiness Checklist

After V1 complete, these changes enable cloud sync without refactoring:

- [ ] `RemoteProjectRepository` implements `ProjectRepository`
- [ ] `SyncService` coordinates local + remote
- [ ] Provider override mechanism in place
- [ ] All entities have `id` and `updatedAt` (already in schema)
- [ ] Export/Import (V1) = cloud sync payload (V2)
