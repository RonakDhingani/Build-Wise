# BuildWise — Product Requirements Document (PRD)

Version: 1.0 | Status: Planning

---

## 1. Functional Requirements

### 1.1 Project Management

**FR-PM-01:** User can create project with fields:
- Project Name (required, max 100 chars)
- Location (required, max 200 chars)
- Plot Size (optional, number + unit: sqft/sqm)
- Built-Up Area (optional, number + unit)
- Number of Floors (optional, integer)
- Budget (required, currency)
- Start Date (required)
- Expected Completion Date (optional)
- Notes (optional, max 1000 chars)
- Cover Photo (optional)

**FR-PM-02:** User can edit any project field after creation

**FR-PM-03:** User can delete project (with confirmation dialog, cascades delete all related data)

**FR-PM-04:** User can archive project (hidden from active list, accessible in archive)

**FR-PM-05:** Project list screen shows all active projects with summary cards

**FR-PM-06:** Project selection persists across app sessions (last opened project)

---

### 1.2 Dashboard

**FR-DB-01:** Dashboard displays per-project:
- Total Budget (formatted currency)
- Total Spent (formatted currency)
- Remaining Budget (formatted currency, color-coded: green/amber/red)
- Overall completion percentage (progress bar)
- Recent expenses (last 5)
- Active construction stage
- Material low-stock alerts

**FR-DB-02:** Budget health indicator:
- Green: spent < 75% budget
- Amber: spent 75–90% budget
- Red: spent > 90% budget

**FR-DB-03:** Quick action buttons on dashboard:
- Add Expense
- Add Material
- View Report

---

### 1.3 Construction Stages

**FR-ST-01:** Default stages pre-created for each project:
Foundation → Structure → Brick Work → Plaster → Flooring → Electrical → Plumbing → Painting → Interior → Exterior

**FR-ST-02:** User can add custom stage (name, position in sequence)

**FR-ST-03:** User can reorder stages via drag-and-drop

**FR-ST-04:** Each stage has:
- Name
- Status: Not Started | In Progress | Completed | On Hold
- Start Date
- End Date (actual)
- Notes (max 1000 chars)
- Photos (multiple)
- Progress percentage (manual input 0–100)

**FR-ST-05:** Mark stage complete sets status=Completed, records end date

**FR-ST-06:** Only one stage can be "In Progress" per project (enforced by UI, not DB)

**FR-ST-07:** Stage progress rolls up to project completion %

---

### 1.4 Expense Tracking

**FR-EX-01:** Add expense with fields:
- Amount (required, positive number)
- Date (required, defaults today)
- Category (required, from list)
- Stage (optional, links to project stage)
- Description (optional, max 500 chars)
- Vendor Name (optional)
- Payment Type: Cash | Cheque | UPI | Bank Transfer | Credit | Other
- Bill Image (optional, from camera or gallery)

**FR-EX-02:** Default categories: Materials, Labor, Electrical, Plumbing, Interior, Exterior, Transportation, Equipment, Government Fees, Other

**FR-EX-03:** User can create custom expense category

**FR-EX-04:** Expense list supports:
- Filter by date range
- Filter by category
- Filter by stage
- Sort by date (newest first default)
- Search by description/vendor

**FR-EX-05:** Expense total auto-updates dashboard

**FR-EX-06:** User can edit or delete expense

**FR-EX-07:** Bill image stored locally, viewable fullscreen

---

### 1.5 Material Management

**FR-MT-01:** Default materials available for any project:
Cement, Steel, Sand, Aggregate, Bricks, Blocks, Tiles, Paint, Putty, Pipes, Wires, Switches, Doors, Windows, Granite, Marble, Water Tank, Waterproofing, Plywood

**FR-MT-02:** Each material entry has:
- Material Name (required)
- Unit (required): bags/kg/tons/pieces/sqft/sqm/liters/meters/rolls/other
- Quantity Purchased (required, positive number)
- Quantity Used (optional, ≤ purchased)
- Quantity Remaining (auto-calculated: purchased − used)
- Cost Per Unit (optional)
- Total Cost (auto-calculated: qty × cost)
- Vendor Name (optional)
- Purchase Date (required, defaults today)
- Stage (optional, links to project stage)
- Notes (optional)

**FR-MT-03:** User can add custom material

**FR-MT-04:** Material list supports filter by stage, sort by name/date/cost

**FR-MT-05:** Low stock alert when remaining < 10% of purchased

**FR-MT-06:** Material summary on dashboard: total materials, total material cost

---

### 1.6 Photo Management

**FR-PH-01:** Add photos linked to:
- Project (general)
- Specific stage

**FR-PH-02:** Photo source: Device camera or gallery

**FR-PH-03:** Photos displayed in grid per stage, sorted by date

**FR-PH-04:** Fullscreen photo viewer with swipe navigation

**FR-PH-05:** Delete photo with confirmation

**FR-PH-06:** Photos stored in app documents directory (not gallery)

---

### 1.7 Reports

**FR-RP-01:** Budget Report PDF contains:
- Project overview (name, location, dates)
- Budget vs spent vs remaining
- Budget health indicator
- Expense breakdown by category (pie chart data in table)
- BuildWise branding + generation date

**FR-RP-02:** Expense Report PDF contains:
- All expenses sorted by date
- Subtotals by category
- Filter-applied indicator (if filtered)
- Payment method breakdown

**FR-RP-03:** Material Report PDF contains:
- All materials with quantities
- Total material cost
- Low stock items highlighted
- Vendor list

**FR-RP-04:** Project Progress Report PDF contains:
- Stage-by-stage status
- Completion percentages
- Timeline (planned vs actual dates)
- Photo count per stage
- Key milestones

**FR-RP-05:** All PDFs:
- BuildWise logo/branding header
- Page numbers
- Generation timestamp
- Professional layout
- Shareable via system share sheet

---

## 2. Non-Functional Requirements

### 2.1 Performance
- App cold start: < 3 seconds
- DB query response: < 200ms for lists up to 1000 records
- PDF generation: < 5 seconds for full project
- Image load: lazy-loaded, thumbnail cache

### 2.2 Storage
- Images compressed before storage (max 1MB per image, JPEG 80%)
- DB size monitored, user informed if > 500MB

### 2.3 Reliability
- Zero data loss on unexpected app close (Isar ACID transactions)
- Graceful error states on every screen

### 2.4 Usability
- No feature requires more than 3 taps from dashboard
- All forms have inline validation
- Destructive actions require confirmation

### 2.5 Offline
- 100% functionality without network
- No network requests in V1

### 2.6 Security
- No sensitive data transmitted
- Images stored in app-sandboxed directory
- No analytics or crash reporting to external servers in V1

### 2.7 Accessibility
- Minimum touch target: 48×48dp
- Color contrast ratio: ≥ 4.5:1
- Screen reader labels on all interactive elements

---

## 3. Constraints

| Constraint | Detail |
|-----------|--------|
| No backend | Isar only |
| No auth | Single user, no login |
| Android primary | API 21+ (Android 5.0) |
| Flutter | Latest stable |
| V1 deadline | See DEVELOPMENT_ROADMAP.md |

---

## 4. Assumptions

- Single user per device
- User manages ≤ 50 active projects
- Each project has ≤ 500 expenses
- Each project has ≤ 200 photos
- Currency is INR by default (configurable in Settings)
