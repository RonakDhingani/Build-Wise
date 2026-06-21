import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_text_styles.dart';
import '../../../constants/app_constants.dart';

class AppCurrencyField extends StatelessWidget {
  const AppCurrencyField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.validator,
    this.currencySymbol,
    this.autofocus = false,
    this.focusNode,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<double>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? currencySymbol;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final symbol = currencySymbol ?? AppConstants.defaultCurrencySymbol;

    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      autofocus: autofocus,
      focusNode: focusNode,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: validator,
      onChanged: (v) {
        final amount = double.tryParse(v);
        if (amount != null) onChanged?.call(amount);
      },
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        prefixText: '$symbol ',
        prefixStyle: AppTextStyles.titleMedium,
      ),
    );
  }
}
