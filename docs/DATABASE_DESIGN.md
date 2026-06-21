# BuildWise — Database Design

Database: Isar (embedded, offline, ACID)

---

## 1. Schema Overview

```
ProjectModel
    ├── StageModel (1:many, projectId)
    │       └── PhotoModel (1:many, stageId)
    ├── ExpenseModel (1:many, projectId)
    ├── MaterialModel (1:many, projectId)
    └── PhotoModel (general, stageId = null)

ExpenseCategoryModel (global, shared across projects)
AppSettingsModel (single record, id = 0)
```

---

## 2. Schema Definitions

### 2.1 ProjectModel

```dart
@Collection()
class ProjectModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String name;
  
  late String location;
  String? plotSize;          // "2400 sqft"
  String? builtUpArea;       // "1800 sqft"
  int? numberOfFloors;
  
  @Index()
  late double budget;
  
  late DateTime startDate;
  DateTime? expectedCompletionDate;
  String? notes;
  String? coverImagePath;    // local file path
  
  @Enumerated(EnumType.name)
  late ProjectStatus status; // active | archived
  
  late DateTime createdAt;
  late DateTime updatedAt;
  
  // Computed (not stored, calculated from linked records)
  // totalSpent → sum of expense.amount
  // completionPercentage → avg of stage.progressPercent
}

enum ProjectStatus { active, archived }
```

**Indexes:** id (primary), name, status, createdAt

---

### 2.2 StageModel

```dart
@Collection()
class StageModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late int projectId;        // FK → ProjectModel.id
  
  late String name;
  late int orderIndex;       // sort order, 0-based
  
  @Enumerated(EnumType.name)
  late StageStatus status;   // notStarted | inProgress | completed | onHold
  
  DateTime? startDate;
  DateTime? endDate;
  
  @Index()
  late int progressPercent;  // 0–100
  
  String? notes;
  late bool isDefault;       // true = system stage, false = custom
  
  late DateTime createdAt;
  late DateTime updatedAt;
}

enum StageStatus { notStarted, inProgress, completed, onHold }
```

**Default stage orderIndex:**
Foundation=0, Structure=1, BrickWork=2, Plaster=3, Flooring=4,
Electrical=5, Plumbing=6, Painting=7, Interior=8, Exterior=9

---

### 2.3 ExpenseCategoryModel

```dart
@Collection()
class ExpenseCategoryModel {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String name;
  
  late bool isDefault;       // true = system category
  String? colorHex;          // optional category color
  String? iconName;          // optional icon
  late DateTime createdAt;
}
```

**Default categories (seeded on first launch):**
Materials, Labor, Electrical, Plumbing, Interior, Exterior,
Transportation, Equipment, Government Fees, Other

---

### 2.4 ExpenseModel

```dart
@Collection()
class ExpenseModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late int projectId;        // FK → ProjectModel.id
  
  int? stageId;              // FK → StageModel.id (nullable)
  late int categoryId;       // FK → ExpenseCategoryModel.id
  
  late double amount;
  late DateTime date;
  
  String? description;
  String? vendorName;
  
  @Enumerated(EnumType.name)
  late PaymentType paymentType; // cash | cheque | upi | bankTransfer | credit | other
  
  String? billImagePath;     // local file path
  
  late DateTime createdAt;
  late DateTime updatedAt;
}

enum PaymentType { cash, cheque, upi, bankTransfer, credit, other }
```

**Indexes:** projectId, date, categoryId, stageId

---

### 2.5 MaterialModel

```dart
@Collection()
class MaterialModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late int projectId;        // FK → ProjectModel.id
  
  int? stageId;              // FK → StageModel.id (nullable)
  
  late String name;
  
  @Enumerated(EnumType.name)
  late MaterialUnit unit;    // bags|kg|tons|pieces|sqft|sqm|liters|meters|rolls|other
  
  late double quantityPurchased;
  late double quantityUsed;  // default 0.0
  
  // quantityRemaining = quantityPurchased - quantityUsed (computed)
  
  double? costPerUnit;
  // totalCost = quantityPurchased * costPerUnit (computed)
  
  String? vendorName;
  late DateTime purchaseDate;
  String? notes;
  
  late bool isDefault;       // true = from default list
  late DateTime createdAt;
  late DateTime updatedAt;
}

enum MaterialUnit { bags, kg, tons, pieces, sqft, sqm, liters, meters, rolls, other }
```

**Default materials seeded as templates (not per-project, user adds from template).**

---

### 2.6 PhotoModel

```dart
@Collection()
class PhotoModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late int projectId;        // FK → ProjectModel.id
  
  int? stageId;              // FK → StageModel.id (null = general project photo)
  
  late String filePath;      // local file path (app documents dir)
  String? thumbnailPath;     // compressed thumbnail path
  String? caption;
  
  late DateTime takenAt;     // EXIF or DateTime.now()
  late DateTime createdAt;
}
```

---

### 2.7 AppSettingsModel

```dart
@Collection()
class AppSettingsModel {
  Id id = 0;                 // singleton, always id=0
  
  late String currencyCode;  // "INR" default
  late String currencySymbol; // "₹" default
  late String dateFormat;    // "dd/MM/yyyy" default
  int? lastActiveProjectId;  // auto-restore last project
  
  @Enumerated(EnumType.name)
  late AppTheme theme;       // light | dark (future)
}

enum AppTheme { light, dark }
```

---

## 3. Relationships (Simulated FKs)

Isar has no foreign keys. Relationships enforced in Repository layer.

| Relationship | Type | Cascade |
|-------------|------|---------|
| Project → Stages | 1:many via projectId | Delete project → delete stages |
| Project → Expenses | 1:many via projectId | Delete project → delete expenses |
| Project → Materials | 1:many via projectId | Delete project → delete materials |
| Project → Photos | 1:many via projectId | Delete project → delete photos |
| Stage → Photos | 1:many via stageId | Delete stage → null stageId (orphan to project) |
| Stage → Expenses | 1:many via stageId | Delete stage → null stageId on expenses |
| Category → Expenses | 1:many via categoryId | Protect: cannot delete category with expenses |

---

## 4. Query Patterns

### Common Queries

```dart
// Get all active projects, newest first
isar.projectModels
    .filter()
    .statusEqualTo(ProjectStatus.active)
    .sortByCreatedAtDesc()
    .findAll()

// Get expenses for project, by date range
isar.expenseModels
    .filter()
    .projectIdEqualTo(projectId)
    .dateBetween(startDate, endDate)
    .sortByDateDesc()
    .findAll()

// Get total spent for project
isar.expenseModels
    .filter()
    .projectIdEqualTo(projectId)
    .amountProperty()
    .sum()  // requires Isar aggregate

// Get materials low on stock
isar.materialModels
    .filter()
    .projectIdEqualTo(projectId)
    .findAll()
    // then filter in Dart: remainingQty < purchasedQty * 0.1
    
// Watch project expenses (stream for real-time updates)
isar.expenseModels
    .filter()
    .projectIdEqualTo(projectId)
    .watch(fireImmediately: true)
```

---

## 5. Seeding Strategy

On first app launch (AppSettingsModel not found):
1. Create `AppSettingsModel` (id=0, defaults)
2. Seed `ExpenseCategoryModel` with 10 default categories
3. Store default material names in-memory constant (not seeded to DB — user adds from list)

On project creation:
1. Create `ProjectModel`
2. Seed 10 `StageModel` records with default names, orderIndex 0–9, status=notStarted

---

## 6. Migrations

Isar V1 has limited migration support. Strategy:
- Use `schemaVersion` field in Isar open config
- Write `MigrationService` that handles version bumps
- Each schema change documented with version number
- V1 starts at schema version 1

```dart
class MigrationService {
  static Future<void> migrate(Isar isar, int fromVersion) async {
    if (fromVersion < 2) {
      // Future V2 migration logic
    }
  }
}
```

---

## 7. Data Integrity Rules

| Rule | Enforcement |
|------|------------|
| Budget must be positive | Validator + Repository check |
| Expense amount must be positive | Validator |
| Material quantityUsed ≤ quantityPurchased | Repository check |
| Stage progressPercent 0–100 | Clamp in domain entity |
| Project name unique per user | Repository check (warn, not block) |
| Delete project cascades all children | Repository transaction |
| Settings id always 0 | Hardcoded in model |

---

## 8. Storage Estimation

| Entity | Avg size | 50 projects estimate |
|--------|----------|---------------------|
| ProjectModel | ~500 bytes | 25 KB |
| StageModel (10/project) | ~200 bytes | 100 KB |
| ExpenseModel | ~300 bytes | ~75 MB (500/project) |
| MaterialModel | ~200 bytes | ~5 MB (100/project) |
| PhotoModel (metadata) | ~100 bytes | ~1 MB |
| Photo files (compressed) | ~200 KB avg | ~2 GB (200/project) |

Photo files dominate storage. Compress to < 1MB on capture.

---

## 9. Backup & Export

V1 export: Serialize all Isar records to JSON. Store in Downloads.
V1 import: Parse JSON, insert via repository (validate before insert).

Future V2: JSON export becomes sync payload for cloud.
