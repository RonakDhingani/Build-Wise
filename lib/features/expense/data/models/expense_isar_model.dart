import 'package:isar/isar.dart';

part 'expense_isar_model.g.dart';

@Collection()
class ExpenseModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int projectId;

  int? stageId;

  @Index()
  late int categoryId;

  late double amount;

  @Index()
  late DateTime date;

  String? description;
  String? vendorName;

  @Enumerated(EnumType.name)
  late PaymentType paymentType;

  String? billImagePath;

  late DateTime createdAt;
  late DateTime updatedAt;
}

enum PaymentType { cash, cheque, upi, bankTransfer, credit, other }
