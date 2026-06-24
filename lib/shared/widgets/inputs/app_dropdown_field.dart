import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

/// Material 3 selection field whose menu always opens *below* the field.
///
/// Built on [MenuAnchor] with a [MenuController] we own, so the open sequence
/// is: scroll the field toward the top of its scroll view (awaited), *then*
/// open the menu. Because room below is guaranteed first, the list never flips
/// upward (the uncontrollable behaviour of [DropdownMenu]/auto-anchored menus).
///
/// Keeps a [DropdownButtonFormField]-style API — `items` are plain
/// [DropdownMenuItem]s with `value` / `onChanged` / `validator` — so existing
/// call sites need no changes. The menu matches the field width.
class AppDropdownField<T> extends StatefulWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.value,
    required this.onChanged,
    this.validator,
    this.hint,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;
  final String? hint;

  @override
  State<AppDropdownField<T>> createState() => _AppDropdownFieldState<T>();
}

class _AppDropdownFieldState<T> extends State<AppDropdownField<T>> {
  final MenuController _menu = MenuController();

  /// Scrolls the field to the top of its scroll view (so there is room for the
  /// menu below), then resolves. No-op when no enclosing Scrollable.
  Future<void> _ensureRoomBelow() async {
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return;
    await Scrollable.ensureVisible(
      context,
      alignment: 0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _toggle() async {
    if (_menu.isOpen) {
      _menu.close();
      return;
    }
    await _ensureRoomBelow();
    if (mounted) _menu.open();
  }

  DropdownMenuItem<T>? get _selectedItem {
    for (final i in widget.items) {
      if (i.value == widget.value) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: widget.value,
      validator: widget.validator,
      builder: (field) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return MenuAnchor(
              controller: _menu,
              alignmentOffset: const Offset(0, AppSpacing.xs),
              style: MenuStyle(
                minimumSize: WidgetStatePropertyAll(Size(width, 0)),
                maximumSize: WidgetStatePropertyAll(Size(width, 360)),
              ),
              menuChildren: [
                for (final item in widget.items)
                  MenuItemButton(
                    onPressed: () {
                      field.didChange(item.value);
                      widget.onChanged(item.value);
                    },
                    child: SizedBox(
                      width: width - AppSpacing.xxl,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: DefaultTextStyle.merge(
                          style: AppTextStyles.bodyMedium,
                          child: item.child,
                        ),
                      ),
                    ),
                  ),
              ],
              builder: (context, controller, _) {
                return _FieldBox(
                  label: widget.label,
                  hint: widget.hint,
                  isOpen: controller.isOpen,
                  errorText: field.errorText,
                  selectedChild: _selectedItem?.child,
                  onTap: _toggle,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// The tappable, text-field-styled anchor. Uses the app's global
/// [InputDecorationTheme] so it matches [AppTextField] and other inputs.
class _FieldBox extends StatelessWidget {
  const _FieldBox({
    required this.label,
    required this.hint,
    required this.isOpen,
    required this.errorText,
    required this.selectedChild,
    required this.onTap,
  });

  final String label;
  final String? hint;
  final bool isOpen;
  final String? errorText;
  final Widget? selectedChild;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = selectedChild != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InputDecorator(
        isEmpty: false,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
        ),
        child: Row(
          children: [
            Expanded(
              child: hasValue
                  ? DefaultTextStyle.merge(
                      style: AppTextStyles.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      child: selectedChild!,
                    )
                  : Text(
                      hint ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: LightThemeColors.textTertiary,
                      ),
                    ),
            ),
            Icon(
              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: LightThemeColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
