import 'package:flutter/material.dart';
import '../../../theme/app_text_styles.dart';

class AppDropdownField<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: AppTextStyles.bodyMedium,
      icon: const Icon(Icons.keyboard_arrow_down),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}
