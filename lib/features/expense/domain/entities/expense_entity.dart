import 'package:flutter/material.dart';

class ExpenseCategoryEntity {
  const ExpenseCategoryEntity({
    required this.id,
    required this.name,
    required this.isDefault,
    this.colorHex,
    required this.createdAt,
  });

  final int id;
  final String name;
  final bool isDefault;
  final String? colorHex;
  final DateTime createdAt;

  Color get color {
    if (colorHex != null) {
      try {
        final hex = colorHex!.replaceAll('#', '');
        if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
    return _palette[id % _palette.length];
  }

  static const List<Color> _palette = [
    Color(0xFF5C6BC0),
    Color(0xFF26A69A),
    Color(0xFFEF5350),
    Color(0xFFFFA726),
    Color(0xFF66BB6A),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
    Color(0xFFEC407A),
    Color(0xFF8D6E63),
    Color(0xFF78909C),
  ];
}

enum PaymentMethod { cash, cheque, upi, bankTransfer, credit, other }

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.cash => 'Cash',
        PaymentMethod.cheque => 'Cheque',
        PaymentMethod.upi => 'UPI',
        PaymentMethod.bankTransfer => 'Bank Transfer',
        PaymentMethod.credit => 'Credit',
        PaymentMethod.other => 'Other',
      };
}

class ExpenseEntity {
  const ExpenseEntity({
    required this.id,
    required this.projectId,
    this.stageId,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.description,
    this.vendorName,
    required this.paymentMethod,
    this.billImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int projectId;
  final int? stageId;
  final int categoryId;
  final double amount;
  final DateTime date;
  final String? description;
  final String? vendorName;
  final PaymentMethod paymentMethod;
  final String? billImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseEntity copyWith({
    int? id,
    int? projectId,
    int? stageId,
    bool clearStageId = false,
    int? categoryId,
    double? amount,
    DateTime? date,
    String? description,
    String? vendorName,
    PaymentMethod? paymentMethod,
    String? billImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      stageId: clearStageId ? null : (stageId ?? this.stageId),
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      vendorName: vendorName ?? this.vendorName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      billImagePath: billImagePath ?? this.billImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}