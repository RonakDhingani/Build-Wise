import 'package:flutter/material.dart';
import '../../../constants/app_strings.dart';
import 'app_confirmation_dialog.dart';

class AppDeleteDialog {
  AppDeleteDialog._();

  static Future<bool?> show(
    BuildContext context, {
    required String itemName,
    required VoidCallback onDelete,
  }) {
    return AppConfirmationDialog.show(
      context,
      title: '${AppStrings.deleteConfirmTitle.replaceAll('?', '')} $itemName?',
      message: AppStrings.deleteConfirmMessage,
      confirmLabel: AppStrings.delete,
      onConfirm: onDelete,
      isDangerous: true,
    );
  }
}
