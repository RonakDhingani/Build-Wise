# BuildWise — UI/UX Guidelines

---

## 1. Design Philosophy

**Premium. Minimal. Fast. Trustworthy.**

BuildWise users make real financial decisions from this app. Every pixel must convey confidence and clarity.

Inspired by:
- **Notion** — whitespace, hierarchy, calm layouts
- **Google Pay** — immediate clarity on financial numbers
- **Linear** — precision, professional density
- **Zerodha** — financial data trust, clean charts

---

## 2. Core UX Principles

### 2.1 Speed First
- Critical actions (add expense, view balance) require ≤ 3 taps
- No loading spinners on cached/local data
- Optimistic UI updates (show result immediately, revert on failure)
- Forms auto-focus first field on open

### 2.2 Progressive Disclosure
- Main screen shows summary, not detail
- Details on tap
- Destructive options behind long-press or swipe, not front-and-center

### 2.3 Feedback Always
- Every user action gets immediate visual response
- Success: green checkmark or snackbar
- Error: red text inline (not modal)
- Loading: skeleton screens, not spinners (where possible)

### 2.4 Error Prevention Over Recovery
- Required fields marked clearly
- Inline validation (not on submit only)
- Destructive actions require explicit confirmation
- Irreversible actions (delete) have undo window (5 seconds)

### 2.5 Consistency
- Same component for same purpose everywhere
- Same color for same meaning (green=good, amber=warning, red=danger)
- Same icon for same action

---

## 3. Layout Principles

### 3.1 Spacing
- Minimum margin from screen edge: 16dp
- Card padding: 16dp internal
- Between sections: 24dp
- Between related items: 8dp
- Between unrelated items: 16dp

### 3.2 Cards
- All content in cards (not raw lists)
- Rounded corners: 12dp
- Light shadow (elevation 2)
- White background on soft neutral app background

### 3.3 Hierarchy
- One primary action per screen (FAB or prominent button)
- Secondary actions smaller or in context menus
- Tertiary actions in overflow menu (⋮)

### 3.4 Touch Targets
- Minimum 48×48dp for all interactive elements
- Buttons: full-width on mobile forms
- List items: minimum 56dp height

---

## 4. Screen-Specific Guidelines

### 4.1 Project Selection Screen
- Clean grid or list of project cards
- Card shows: name, location, budget, % complete, days remaining
- Empty state: illustration + "Create your first project" CTA
- No cluttered header, just BuildWise logo + search icon

### 4.2 Dashboard
- Hero card: Budget summary (large numbers, clear labels)
- Progress ring or bar: overall completion
- Recent 5 expenses with amounts
- Active stage highlighted with gold accent
- Quick action row: 3 buttons max
- No more than 5 sections total

### 4.3 Expense Screen
- List with date grouping (Today, Yesterday, Earlier)
- Amount right-aligned, bold
- Category icon/color chip left
- Total bar at top (not bottom)
- Filter chips horizontal scroll (not dropdown)

### 4.4 Add Expense Sheet (Critical)
- Bottom sheet (75% height)
- Amount field: first, large, auto-focused, numeric keyboard
- Category: horizontal chip row (not dropdown — faster)
- Date: compact picker showing "Today / Yesterday / Pick date"
- All optional fields collapsed by default, "+ More" expander
- Save button: sticky bottom, full width

### 4.5 Material Screen
- List with remaining quantity prominently shown
- Low stock items: amber left border
- Out of stock items: red left border
- Cost summary card at top

### 4.6 Reports Screen
- 4 report type cards in 2×2 grid
- Each card: icon, title, short description
- Tap → filter options (minimal) → Generate PDF
- PDF viewer with share button in app bar

### 4.7 Stages Screen
- Vertical timeline layout
- Each stage: status badge, progress bar, date range
- Drag handle visible (subtle)
- Active stage visually distinct (gold accent or elevated)

---

## 5. Interaction Patterns

### 5.1 Forms
- Labels above fields (not placeholder-only)
- Placeholder text: hint, not label
- Inline validation after user leaves field (onFocusLost)
- Error text: red, below field
- Required indicator: * after label

### 5.2 Deletion Flow
```
User swipes left or long-presses
  → Delete option appears (red background)
    → Tap delete
      → Item disappears immediately (optimistic)
        → Snackbar: "Expense deleted. Undo"
          → Undo tapped: item restored
          → Snackbar dismissed: permanent deletion
```

### 5.3 Empty States
- Custom illustration (construction theme)
- Clear headline: "No expenses yet"
- Supportive subtext: "Track your first expense to see your spending"
- CTA button: primary action for this screen

### 5.4 Loading States
- Skeleton screens matching actual content shape
- No full-screen spinner (use in-place skeleton)
- Exception: PDF generation → full-screen loader with progress text

### 5.5 Pull to Refresh
- Not needed (local DB, always fresh)
- Remove if framework adds by default

---

## 6. Navigation Patterns

### 6.1 Bottom Navigation
- 5 tabs: Dashboard, Expenses, Materials, Reports, Settings
- Active tab: Navy fill icon
- Inactive tab: gray outline icon
- No labels needed if icons are clear (consider labels for clarity)
- Persistent across project context

### 6.2 Back Navigation
- System back = go to parent screen
- No custom back gestures
- Modal sheets dismissed with swipe down or × button

### 6.3 Project Context
- Project name shown in app bar of all project screens
- Tap project name → Project selection (switch project)

---

## 7. Accessibility

- All images have semantic labels
- Form fields have explicit labels (not relying on placeholder)
- Color not sole indicator (use icons + color together)
- Minimum contrast ratio 4.5:1 for body text, 3:1 for large text
- Support system text scale (no fixed pixel text sizes in theme)
- Interactive element labels for screen readers

---

## 8. Micro-interactions

**Keep minimal. No gratuitous animations.**

Approved micro-interactions:
- Budget bar fill animation on dashboard load (300ms, once)
- Stage completion: checkmark animation (200ms)
- Add expense success: brief green flash on amount (150ms)
- Delete: slide-out animation (150ms)
- Screen transitions: default Material motion (no custom)

Forbidden:
- Lottie animations on every screen
- Parallax effects
- Bounce physics
- Long staggered list animations

---

## 9. Responsiveness

Primary target: phones (360–428dp width)
- All layouts tested at 360dp minimum width
- No horizontal overflow allowed
- Tables → vertical card layout on small screens
- PDF viewer: pinch-zoom only

Tablet support: future consideration. V1 not required.

---

## 10. Error & Edge Case Design

| Scenario | Design Response |
|----------|----------------|
| Budget overrun (spent > budget) | Red remaining balance, warning banner |
| Stage out of order completion | Allow, no enforcement |
| Photo storage full | Toast warning, disable photo capture |
| Large number (₹1Cr+) | Format as "₹1.0 Cr" not "₹10000000" |
| Long project name (>30 chars) | Truncate with ellipsis in cards |
| Zero expenses | Empty state illustration |
| All stages complete | Celebration state on dashboard |
