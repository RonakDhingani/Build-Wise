import 'package:isar/isar.dart';

part 'expense_category_isar_model.g.dart';

@Collection()
class ExpenseCategoryModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  late bool isDefault;
  String? colorHex;
  String? iconName;
  late DateTime createdAt;
}
