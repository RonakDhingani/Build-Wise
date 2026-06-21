# BuildWise — User Flow

---

## 1. App Entry Flow

```
App Launch
    │
    ├── No projects exist → Project Selection Screen (empty state)
    │       └── Tap "Create Project" → Create Project Screen
    │               └── Fill form → Save → Project Dashboard
    │
    └── Projects exist → Project Selection Screen
            ├── Tap project card → Project Dashboard
            └── Tap "+ New Project" → Create Project Screen
```

---

## 2. Project Selection Screen

```
Project Selection Screen
    ├── Project cards (name, location, budget, % complete)
    ├── Search bar (filter by name/location)
    ├── Sort: Recent | Alphabetical | Budget
    ├── Filter: Active | Archived
    ├── FAB: "+ Create Project"
    └── Long press card → Context menu: Edit | Archive | Delete
```

---

## 3. Project Dashboard Flow

```
Project Dashboard (Bottom Nav: Dashboard)
    ├── Header: Project name, location
    ├── Budget summary card (total/spent/remaining)
    ├── Progress bar (overall % complete)
    ├── Active stage chip
    ├── Recent expenses list (last 5)
    ├── Quick actions: [+ Expense] [+ Material] [Report]
    └── Bottom Nav → [Dashboard] [Expenses] [Materials] [Reports] [Settings]
```

---

## 4. Add Expense Flow (Critical — must be < 10 seconds)

```
Dashboard → "+ Expense" button
    │
    └── Add Expense Bottom Sheet
            ├── Amount field (auto-focus, number keyboard)
            ├── Category picker (chips, scrollable)
            ├── Date (defaults today, tap to change)
            ├── Description (optional)
            ├── Vendor (optional)
            ├── Payment type (dropdown)
            ├── Stage link (optional, dropdown)
            ├── Bill image (optional, camera/gallery)
            └── [Save] → Dashboard (expense added, budget updated)
```

**Target: 3 required taps (amount → category → save)**

---

## 5. Expense Screen Flow

```
Bottom Nav: Expenses
    ├── Expense list (sorted newest first)
    ├── Filter bar: Category | Stage | Date Range
    ├── Search bar
    ├── Total shown at top
    ├── FAB: "+ Add Expense"
    ├── Tap expense → Expense Detail Screen
    │       ├── View all fields
    │       ├── View bill image (if attached)
    │       ├── [Edit] → Edit Expense Sheet
    │       └── [Delete] → Confirmation dialog → deleted
    └── Swipe left on item → Delete (with undo snackbar)
```

---

## 6. Material Management Flow

```
Bottom Nav: Materials
    ├── Material list (grouped by stage or alphabetical)
    ├── Search bar
    ├── Filter: By stage | Low stock only
    ├── Summary bar: Total cost, Total items
    ├── FAB: "+ Add Material"
    │       └── Add Material Sheet
    │               ├── Name (autocomplete from defaults)
    │               ├── Unit (dropdown)
    │               ├── Qty Purchased
    │               ├── Qty Used (optional)
    │               ├── Cost per unit (optional)
    │               ├── Vendor (optional)
    │               ├── Date (defaults today)
    │               ├── Stage (optional)
    │               └── [Save]
    └── Tap material → Material Detail
            ├── View all fields
            ├── Update qty used
            ├── [Edit] → Edit Material Sheet
            └── [Delete] → Confirmation
```

---

## 7. Construction Stages Flow

```
Dashboard → Active Stage chip / Stages tab (in project detail)
    │
    └── Stages Screen
            ├── Stage cards in sequence order
            ├── Status badges (Not Started/In Progress/Complete/On Hold)
            ├── Progress bars per stage
            ├── Drag handle to reorder
            ├── FAB: "+ Add Custom Stage"
            └── Tap stage → Stage Detail Screen
                    ├── Status picker
                    ├── Start/End dates
                    ├── Progress % slider
                    ├── Notes
                    ├── Photos grid
                    │       ├── "+ Add Photo" (camera/gallery)
                    │       └── Tap photo → Fullscreen viewer
                    └── [Mark Complete] button
```

---

## 8. Reports Flow (Critical — must be < 15 seconds)

```
Bottom Nav: Reports
    ├── Report type cards:
    │       ├── Budget Report
    │       ├── Expense Report
    │       ├── Material Report
    │       └── Project Progress Report
    └── Tap report type
            ├── Filter options (date range, stage — where applicable)
            ├── Preview summary
            ├── [Generate PDF] button
            │       ├── Loading indicator (< 5s)
            │       └── PDF viewer screen
            │               └── [Share] → System share sheet
            └── [Download] → Save to Downloads folder
```

---

## 9. Settings Flow

```
Bottom Nav: Settings
    ├── Current Project: [switch project]
    ├── App Settings
    │       ├── Currency (INR default)
    │       ├── Date Format (DD/MM/YYYY default)
    │       └── Theme (Light / Dark — future)
    ├── Data Management
    │       ├── Export all data (JSON)
    │       └── Import data (JSON)
    ├── About
    │       ├── Version
    │       └── BuildWise branding
    └── Manage Categories (add/edit/delete expense categories)
```

---

## 10. Navigation State Machine

```
State: No Projects
    Action: Create Project → State: Project Active

State: Project Active  
    Events: 
        - Add Expense → expense count++, budget spent++
        - Add Material → material count++
        - Mark Stage Complete → stage status=complete
        - Generate Report → PDF created, no state change
        - Archive Project → project archived, return to selection
        - Delete Project → all data deleted, return to selection
```

---

## 11. Error State Flows

```
DB Write Failure
    └── Show error snackbar "Failed to save. Try again."
    
Image Load Failure  
    └── Show placeholder icon

PDF Generation Failure
    └── Show error dialog with retry option

Storage Full
    └── Show warning banner on image capture
```

---

## 12. Tap Count Analysis

| Action | Taps Required |
|--------|--------------|
| Create project (minimal) | 3 (name + budget + save) |
| Add expense (minimal) | 3 (amount + category + save) |
| Add material (minimal) | 4 (name + unit + qty + save) |
| Generate report | 2 (type + generate) |
| Mark stage complete | 2 (stage + mark complete) |
| Switch project | 2 (back + tap project) |
