import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 1)
class Budget {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  double? amount; // 可选的预算金额

  @HiveField(3)
  final double spent;

  @HiveField(4)
  final DateTime monthYear; // 用於標識預算屬於哪一個月份

  Budget({
    this.id,
    required this.category,
    required this.monthYear,
    this.amount,
    this.spent = 0,
  });
}
