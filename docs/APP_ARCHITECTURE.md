# BuildWise — App Architecture

---

## 1. Architecture Overview

Clean Architecture with 3 layers + Feature-First folder structure.

```
┌─────────────────────────────────────────┐
│           PRESENTATION LAYER            │
│   Screens · Widgets · Providers (UI)    │
├─────────────────────────────────────────┤
│             DOMAIN LAYER                │
│   Entities · Use Cases · Repo Contracts │
├─────────────────────────────────────────┤
│              DATA LAYER                 │
│   Isar · Repos · Models · Mappers       │
└─────────────────────────────────────────┘
```

Dependency rule: Inner layers know nothing about outer layers.

---

## 2. Layer Responsibilities

### 2.1 Presentation Layer
- Flutter Widgets (screens, components)
- Riverpod providers (UI state only)
- Notifiers/Controllers call domain use cases
- No business logic in widgets

### 2.2 Domain Layer
- Pure Dart entities (no Flutter, no Isar)
- Use cases (single-responsibility actions)
- Abstract repository interfaces
- Business rules live here

### 2.3 Data Layer
- Isar schema models
- Repository implementations
- Mappers (Isar model ↔ Domain entity)
- Services (PDF, image, file)

---

## 3. Feature-First Folder Structure

```
lib/
├── core/                          # Shared infrastructure
│   ├── database/
│   │   ├── isar_service.dart      # Isar singleton + initialization
│   │   └── database_provider.dart
│   ├── error/
│   │   ├── failure.dart           # Sealed class failures
│   │   └── exceptions.dart
│   ├── result/
│   │   └── result.dart            # Result<T, F> type
│   ├── di/
│   │   └── providers.dart         # Global DI providers
│   └── extensions/
│       ├── datetime_ext.dart
│       └── double_ext.dart
│
├── shared/                        # Reusable UI
│   ├── widgets/
│   │   ├── buttons/
│   │   │   ├── app_primary_button.dart
│   │   │   ├── app_secondary_button.dart
│   │   │   ├── app_outline_button.dart
│   │   │   └── app_icon_button.dart
│   │   ├── inputs/
│   │   │   ├── app_text_field.dart
│   │   │   ├── app_search_field.dart
│   │   │   ├── app_dropdown_field.dart
│   │   │   ├── app_date_picker_field.dart
│   │   │   └── app_currency_field.dart
│   │   ├── cards/
│   │   │   ├── app_summary_card.dart
│   │   │   ├── app_expense_card.dart
│   │   │   ├── app_material_card.dart
│   │   │   └── app_stage_card.dart
│   │   ├── feedback/
│   │   │   ├── app_loading_widget.dart
│   │   │   ├── app_empty_state.dart
│   │   │   ├── app_error_state.dart
│   │   │   └── app_success_state.dart
│   │   ├── dialogs/
│   │   │   ├── app_confirmation_dialog.dart
│   │   │   ├── app_delete_dialog.dart
│   │   │   └── app_success_dialog.dart
│   │   └── layout/
│   │       ├── app_scaffold.dart
│   │       ├── app_bar_widget.dart
│   │       ├── section_header.dart
│   │       └── app_bottom_sheet.dart
│   └── providers/
│       └── shared_providers.dart
│
├── theme/                         # Design system
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   ├── app_spacing.dart
│   ├── app_dimensions.dart
│   ├── app_theme.dart             # MaterialApp theme builder
│   └── app_shadows.dart
│
├── constants/                     # App-wide constants
│   ├── app_strings.dart
│   ├── app_assets.dart
│   ├── app_routes.dart
│   └── app_constants.dart
│
├── utils/                         # Pure utility functions
│   ├── date_formatter.dart
│   ├── currency_formatter.dart
│   ├── validators.dart
│   ├── file_helpers.dart
│   ├── image_helpers.dart
│   └── pdf_helpers.dart
│
├── features/
│   ├── project/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── project_isar_model.dart
│   │   │   ├── mappers/
│   │   │   │   └── project_mapper.dart
│   │   │   └── repositories/
│   │   │       └── project_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── project_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── project_repository.dart    # abstract
│   │   │   └── use_cases/
│   │   │       ├── create_project_use_case.dart
│   │   │       ├── update_project_use_case.dart
│   │   │       ├── delete_project_use_case.dart
│   │   │       ├── archive_project_use_case.dart
│   │   │       ├── get_projects_use_case.dart
│   │   │       └── get_project_by_id_use_case.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── project_providers.dart
│   │       ├── notifiers/
│   │       │   └── project_notifier.dart
│   │       └── screens/
│   │           ├── project_selection_screen.dart
│   │           ├── create_project_screen.dart
│   │           └── edit_project_screen.dart
│   │
│   ├── dashboard/
│   │   ├── domain/
│   │   │   └── use_cases/
│   │   │       └── get_dashboard_summary_use_case.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── dashboard_providers.dart
│   │       ├── notifiers/
│   │       │   └── dashboard_notifier.dart
│   │       ├── screens/
│   │       │   └── dashboard_screen.dart
│   │       └── widgets/
│   │           ├── budget_summary_card.dart
│   │           ├── recent_expenses_list.dart
│   │           ├── stage_progress_widget.dart
│   │           └── quick_actions_bar.dart
│   │
│   ├── stage/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── stage_isar_model.dart
│   │   │   ├── mappers/
│   │   │   │   └── stage_mapper.dart
│   │   │   └── repositories/
│   │   │       └── stage_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── stage_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── stage_repository.dart
│   │   │   └── use_cases/
│   │   │       ├── get_stages_use_case.dart
│   │   │       ├── create_stage_use_case.dart
│   │   │       ├── update_stage_use_case.dart
│   │   │       ├── delete_stage_use_case.dart
│   │   │       └── reorder_stages_use_case.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── stage_providers.dart
│   │       ├── notifiers/
│   │       │   └── stage_notifier.dart
│   │       ├── screens/
│   │       │   ├── stages_screen.dart
│   │       │   └── stage_detail_screen.dart
│   │       └── widgets/
│   │           ├── stage_list_item.dart
│   │           └── stage_status_chip.dart
│   │
│   ├── expense/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── expense_isar_model.dart
│   │   │   │   └── expense_category_isar_model.dart
│   │   │   ├── mappers/
│   │   │   │   └── expense_mapper.dart
│   │   │   └── repositories/
│   │   │       └── expense_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── expense_entity.dart
│   │   │   │   └── expense_category_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── expense_repository.dart
│   │   │   └── use_cases/
│   │   │       ├── add_expense_use_case.dart
│   │   │       ├── update_expense_use_case.dart
│   │   │       ├── delete_expense_use_case.dart
│   │   │       ├── get_expenses_use_case.dart
│   │   │       └── get_expense_summary_use_case.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── expense_providers.dart
│   │       ├── notifiers/
│   │       │   └── expense_notifier.dart
│   │       ├── screens/
│   │       │   ├── expense_screen.dart
│   │       │   └── expense_detail_screen.dart
│   │       └── widgets/
│   │           ├── add_expense_sheet.dart
│   │           ├── expense_filter_bar.dart
│   │           └── expense_list_item.dart
│   │
│   ├── material/
│   │   ├── data/ [same pattern]
│   │   ├── domain/ [same pattern]
│   │   └── presentation/ [same pattern]
│   │
│   ├── photo/
│   │   ├── data/ [same pattern]
│   │   ├── domain/ [same pattern]
│   │   └── presentation/ [same pattern]
│   │
│   ├── report/
│   │   ├── domain/
│   │   │   └── use_cases/
│   │   │       ├── generate_budget_report_use_case.dart
│   │   │       ├── generate_expense_report_use_case.dart
│   │   │       ├── generate_material_report_use_case.dart
│   │   │       └── generate_progress_report_use_case.dart
│   │   ├── services/
│   │   │   └── pdf_report_service.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── report_providers.dart
│   │       ├── screens/
│   │       │   ├── reports_screen.dart
│   │       │   └── pdf_viewer_screen.dart
│   │       └── widgets/
│   │           └── report_type_card.dart
│   │
│   └── settings/
│       ├── domain/
│       │   └── entities/
│       │       └── app_settings_entity.dart
│       ├── data/
│       │   └── repositories/
│       │       └── settings_repository_impl.dart
│       └── presentation/
│           ├── providers/
│           │   └── settings_providers.dart
│           └── screens/
│               └── settings_screen.dart
│
├── navigation/
│   ├── app_router.dart            # go_router configuration
│   └── route_names.dart
│
└── main.dart
```

---

## 4. State Management Architecture

### Riverpod Provider Hierarchy

```
IsarServiceProvider (global singleton)
    │
    ├── ProjectRepositoryProvider
    │       └── ProjectNotifierProvider (AsyncNotifier)
    │               └── ProjectSelectionScreen
    │
    ├── ActiveProjectProvider (StateProvider<int?> — project ID)
    │       └── consumed by all feature providers
    │
    ├── ExpenseRepositoryProvider
    │       └── ExpenseNotifierProvider
    │               └── ExpenseScreen
    │
    ├── MaterialRepositoryProvider
    │       └── MaterialNotifierProvider
    │
    ├── StageRepositoryProvider
    │       └── StageNotifierProvider
    │
    └── DashboardSummaryProvider (FutureProvider, watches active project)
```

### Provider Types Used

| Provider Type | Use Case |
|--------------|----------|
| `Provider` | Repositories, services, use cases (DI) |
| `StateProvider` | Simple state (active project ID, filters) |
| `AsyncNotifier` | Complex async state with CRUD |
| `FutureProvider` | One-shot async reads (dashboard summary) |
| `StreamProvider` | Isar watch streams (real-time DB updates) |

---

## 5. Navigation Architecture

### go_router Structure

```
/                           → redirect to /projects
/projects                   → ProjectSelectionScreen
/projects/create            → CreateProjectScreen
/projects/:id/edit          → EditProjectScreen
/projects/:id/dashboard     → DashboardScreen (shell)
    /projects/:id/expenses  → ExpenseScreen
    /projects/:id/materials → MaterialScreen
    /projects/:id/reports   → ReportsScreen
    /projects/:id/settings  → SettingsScreen
/projects/:id/stages        → StagesScreen
/projects/:id/stages/:stageId → StageDetailScreen
/projects/:id/expenses/:expenseId → ExpenseDetailScreen
/projects/:id/materials/:materialId → MaterialDetailScreen
/projects/:id/reports/pdf   → PdfViewerScreen
```

Shell route wraps project screens with bottom navigation.

---

## 6. Error Handling Strategy

```dart
// Result type for use cases
sealed class Result<T> {
  const Result();
}
class Success<T> extends Result<T> {
  final T data;
}
class Failure<T> extends Result<T> {
  final AppFailure failure;
}

// Failure types
sealed class AppFailure {
  final String message;
}
class DatabaseFailure extends AppFailure {}
class ValidationFailure extends AppFailure {}
class StorageFailure extends AppFailure {}
class NotFoundFailure extends AppFailure {}
```

Use cases return `Result<T>`. Notifiers handle result and emit error state. Screens show `AppErrorState` widget.

---

## 7. Data Flow

```
User Action (Widget)
    → Notifier method call
        → Use Case execute()
            → Repository method
                → Isar operation
                    → Isar model
                        → mapper → Domain entity
                            → Result<Entity>
                                → Notifier state update
                                    → UI rebuild
```

---

## 8. Cloud Sync Readiness (V2)

Repository interface remains unchanged. V2 adds:
- `RemoteProjectRepository` implementation
- `SyncService` that orchestrates local + remote
- Provider override for remote vs local repo
- No domain/presentation changes required

```dart
// V1: local only
final projectRepositoryProvider = Provider(
  (ref) => ProjectRepositoryImpl(ref.read(isarServiceProvider))
);

// V2: swap to sync repo
final projectRepositoryProvider = Provider(
  (ref) => SyncProjectRepository(
    local: ProjectRepositoryImpl(...),
    remote: RemoteProjectRepository(...)
  )
);
```

---

## 9. Key Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x
  go_router: ^14.x
  isar: ^3.x
  isar_flutter_libs: ^3.x
  path_provider: ^2.x
  image_picker: ^1.x
  pdf: ^3.x
  printing: ^5.x
  share_plus: ^9.x
  flutter_image_compress: ^2.x
  intl: ^0.19.x
  uuid: ^4.x
  reorderables: ^0.6.x

dev_dependencies:
  build_runner: ^2.x
  isar_generator: ^3.x
  riverpod_generator: ^2.x
  flutter_lints: ^4.x
  mocktail: ^1.x
```
