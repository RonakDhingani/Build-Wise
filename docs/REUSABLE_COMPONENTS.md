# BuildWise — Reusable Components

All components consume design system tokens. Zero hardcoded values.

---

## 1. Button Components

### AppPrimaryButton
```
Path: lib/shared/widgets/buttons/app_primary_button.dart

Props:
  - label: String (required)
  - onPressed: VoidCallback? (null = disabled state)
  - icon: IconData? (optional leading icon)
  - isLoading: bool (default false — shows CircularProgressIndicator)
  - width: double? (default: double.infinity)

Behavior:
  - Full width by default
  - Height: AppDimensions.buttonHeightLg (52dp)
  - Background: LightThemeColors.primary
  - Text: AppTextStyles.labelLarge, white
  - Radius: AppDimensions.radiusMd
  - Disabled: opacity 0.5
  - Loading: replaced label with small white spinner
```

### AppSecondaryButton
```
Path: lib/shared/widgets/buttons/app_secondary_button.dart

Props: same as Primary

Behavior:
  - Background: LightThemeColors.primaryLight
  - Text color: LightThemeColors.primary
  - No shadow
```

### AppOutlineButton
```
Props: same as Primary

Behavior:
  - Background: transparent
  - Border: 1.5dp, LightThemeColors.primary
  - Text: LightThemeColors.primary
```

### AppIconButton
```
Props:
  - icon: IconData (required)
  - onPressed: VoidCallback?
  - size: double (default AppDimensions.iconMd)
  - color: Color? (default textSecondary)
  - tooltip: String?
  - backgroundColor: Color? (optional tinted background)

Behavior:
  - Min touch target: 48×48dp (padding added internally)
```

---

## 2. Input Components

### AppTextField
```
Path: lib/shared/widgets/inputs/app_text_field.dart

Props:
  - label: String (required)
  - hint: String?
  - controller: TextEditingController?
  - onChanged: ValueChanged<String>?
  - validator: FormFieldValidator<String>?
  - keyboardType: TextInputType (default text)
  - maxLines: int (default 1)
  - maxLength: int?
  - suffix: Widget?
  - prefix: Widget?
  - enabled: bool (default true)
  - autofocus: bool (default false)
  - obscureText: bool (default false)
  - textCapitalization: TextCapitalization

Behavior:
  - Uses InputDecorationTheme from AppTheme
  - Error shown inline below field
  - No hardcoded colors
```

### AppSearchField
```
Props:
  - hint: String (required)
  - onChanged: ValueChanged<String>
  - onClear: VoidCallback?

Behavior:
  - Prefix: search icon (AppColors.neutral400)
  - Suffix: clear × icon (appears when text non-empty)
  - Background: neutral100
  - Radius: AppDimensions.radiusFull (pill shape)
  - Height: 44dp
```

### AppDropdownField<T>
```
Props:
  - label: String
  - items: List<DropdownMenuItem<T>>
  - value: T?
  - onChanged: ValueChanged<T?>
  - validator: FormFieldValidator<T>?
  - hint: String?

Behavior:
  - Styled same as AppTextField
  - Custom dropdown icon (chevron_down)
```

### AppDatePickerField
```
Props:
  - label: String
  - value: DateTime?
  - onChanged: ValueChanged<DateTime>
  - validator: FormFieldValidator<DateTime>?
  - firstDate: DateTime?
  - lastDate: DateTime?

Behavior:
  - Shows formatted date (via DateFormatter)
  - Trailing calendar icon
  - Tap → Material date picker
  - Read-only text field (no keyboard)
```

### AppCurrencyField
```
Props:
  - label: String
  - controller: TextEditingController
  - onChanged: ValueChanged<double>?
  - validator: FormFieldValidator<String>?

Behavior:
  - Prefix: currency symbol from settings (₹)
  - Input type: decimal
  - Formats with comma separator on focus lost
  - No negative values
```

---

## 3. Card Components

### AppSummaryCard
```
Path: lib/shared/widgets/cards/app_summary_card.dart

Props:
  - title: String
  - value: String
  - subtitle: String?
  - icon: IconData?
  - iconColor: Color?
  - backgroundColor: Color?
  - onTap: VoidCallback?
  - trailing: Widget?

Behavior:
  - Card with AppShadows.card
  - Radius: AppDimensions.radiusMd
  - Padding: AppSpacing.cardPadding
  - Icon in colored circle (40×40dp)
  - Value: AppTextStyles.displaySmall
  - Title: AppTextStyles.bodySmall, textSecondary
```

### AppExpenseCard
```
Props:
  - expense: ExpenseEntity
  - onTap: VoidCallback?
  - onDelete: VoidCallback?

Behavior:
  - Left: category color dot + icon
  - Center: description (bold), vendor + date (small gray)
  - Right: amount (bold navy), payment type chip
  - Swipeable (left → delete action)
  - Min height: 64dp
```

### AppMaterialCard
```
Props:
  - material: MaterialEntity
  - onTap: VoidCallback?

Behavior:
  - Name + unit
  - Progress bar: used/purchased ratio
  - Remaining qty badge
  - Left border color: green (normal) / amber (low) / red (out)
  - Cost: right-aligned
```

### AppStageCard
```
Props:
  - stage: StageEntity
  - onTap: VoidCallback?
  - onReorder: — (handled by parent reorderable list)

Behavior:
  - Left: order number circle
  - Status badge (top right)
  - Progress bar
  - Date range (if set)
  - Drag handle (right edge, always visible on stages screen)
```

---

## 4. Feedback Widgets

### AppLoadingWidget
```
Props:
  - message: String? (optional "Loading..." text)
  - size: double (default 40)

Behavior:
  - CircularProgressIndicator, AppColors.primary
  - Centered with optional message below
  - Used inside scaffold body, not full screen overlay
```

### AppEmptyState
```
Props:
  - title: String (required)
  - subtitle: String?
  - illustration: Widget? (SVG/image asset)
  - action: Widget? (CTA button)

Behavior:
  - Centered vertically in available space
  - Illustration: 180dp height max
  - Title: AppTextStyles.titleMedium
  - Subtitle: AppTextStyles.bodyMedium, textSecondary
  - Action: optional primary button below
```

### AppErrorState
```
Props:
  - message: String
  - onRetry: VoidCallback?

Behavior:
  - Error icon (red)
  - Message text
  - "Try Again" button (if onRetry provided)
```

### AppSuccessState
```
Props:
  - message: String
  - onDone: VoidCallback?

Behavior:
  - Success checkmark animation (simple scale-in)
  - Message
  - "Done" or "Continue" button
```

---

## 5. Dialog Components

### AppConfirmationDialog
```
Static method: AppConfirmationDialog.show(context, ...)

Props:
  - title: String
  - message: String
  - confirmLabel: String (default "Confirm")
  - cancelLabel: String (default "Cancel")
  - onConfirm: VoidCallback
  - isDangerous: bool (default false — red confirm button if true)

Returns: Future<bool?>
```

### AppDeleteDialog
```
Wraps AppConfirmationDialog with:
  - title: "Delete [item]?"
  - message: "This action cannot be undone."
  - confirmLabel: "Delete"
  - isDangerous: true
```

### AppSuccessDialog
```
Props:
  - title: String
  - message: String?
  - onDone: VoidCallback?

Behavior:
  - Auto-dismisses after 2 seconds OR on tap
```

---

## 6. Layout Widgets

### AppScaffold
```
Path: lib/shared/widgets/layout/app_scaffold.dart

Props:
  - body: Widget (required)
  - appBar: PreferredSizeWidget? (optional custom app bar)
  - floatingActionButton: Widget?
  - bottomNavigationBar: Widget?
  - backgroundColor: Color? (default LightThemeColors.background)
  - resizeToAvoidBottomInset: bool (default true)

Behavior:
  - Consistent background
  - Handles safe areas
  - No duplicate padding
```

### AppBarWidget
```
Props:
  - title: String
  - subtitle: String? (project name context)
  - leading: Widget? (back button default)
  - actions: List<Widget>?
  - onTitleTap: VoidCallback? (for project switch)

Behavior:
  - Height: 56dp
  - Title: AppTextStyles.titleLarge
  - Subtitle (if given): AppTextStyles.bodySmall, textSecondary
  - No elevation, border-bottom: 1dp neutral200
```

### SectionHeader
```
Props:
  - title: String
  - action: Widget? (optional "See all" link)
  - padding: EdgeInsets?

Behavior:
  - Title: AppTextStyles.titleMedium
  - Action: AppTextStyles.labelMedium, primary color
  - Horizontal padding: AppSpacing.pageHorizontal
```

### AppBottomSheet
```
Static method: AppBottomSheet.show(context, child: Widget, ...)

Props:
  - title: String?
  - child: Widget
  - maxHeightFraction: double (default 0.85)
  - isScrollable: bool (default true)
  - isDismissible: bool (default true)

Behavior:
  - Drag handle indicator at top
  - Title (if given) + close button
  - Content scrollable
  - Safe area bottom padding
  - AppShadows.sheet
```

---

## 7. Specialized Widgets

### BudgetProgressBar
```
Props:
  - budget: double
  - spent: double
  - height: double (default AppDimensions.progressBarHeight)

Behavior:
  - Animated width fill on first render (300ms)
  - Color from BudgetHealthColors.color(spentPercent)
  - Radius: AppDimensions.radiusFull
  - Overflow: bar fills 100% + turns red (no visual overflow)
```

### StageStatusChip
```
Props:
  - status: StageStatus

Behavior:
  - Pill shape (radiusFull)
  - Background: StageStatusColors.background(status)
  - Text: StageStatusColors.foreground(status)
  - Label: AppTextStyles.labelSmall
  - Icon: small leading icon per status
```

### AmountText
```
Props:
  - amount: double
  - style: TextStyle? (default AppTextStyles.displaySmall)
  - color: Color?
  - showSymbol: bool (default true)

Behavior:
  - Uses CurrencyFormatter
  - Color can override (for red remaining, etc.)
```

### PhotoGridWidget
```
Props:
  - photos: List<PhotoEntity>
  - onAddPhoto: VoidCallback
  - onDeletePhoto: ValueChanged<PhotoEntity>
  - onTapPhoto: ValueChanged<PhotoEntity>

Behavior:
  - Grid: 3 columns
  - Thumbnails: AspectRatio 1:1
  - + Add tile always last
  - Tap photo → fullscreen viewer
```

---

## 8. Component Usage Rules

1. Never create a one-off widget that duplicates a shared widget's purpose
2. Extend shared widgets via props, not by copy-pasting
3. If a screen needs a variant, add a prop to the shared widget
4. All shared widgets must handle: loading, empty, error, disabled states
5. Import shared widgets from `package:build_wise/shared/widgets/index.dart` (barrel export)
6. Document new shared widgets in this file before implementing

---

## 9. Barrel Exports

```dart
// lib/shared/widgets/index.dart
export 'buttons/app_primary_button.dart';
export 'buttons/app_secondary_button.dart';
export 'buttons/app_outline_button.dart';
export 'buttons/app_icon_button.dart';
export 'inputs/app_text_field.dart';
export 'inputs/app_search_field.dart';
export 'inputs/app_dropdown_field.dart';
export 'inputs/app_date_picker_field.dart';
export 'inputs/app_currency_field.dart';
export 'cards/app_summary_card.dart';
export 'cards/app_expense_card.dart';
export 'cards/app_material_card.dart';
export 'cards/app_stage_card.dart';
export 'feedback/app_loading_widget.dart';
export 'feedback/app_empty_state.dart';
export 'feedback/app_error_state.dart';
export 'feedback/app_success_state.dart';
export 'dialogs/app_confirmation_dialog.dart';
export 'dialogs/app_delete_dialog.dart';
export 'dialogs/app_success_dialog.dart';
export 'layout/app_scaffold.dart';
export 'layout/app_bar_widget.dart';
export 'layout/section_header.dart';
export 'layout/app_bottom_sheet.dart';
```
