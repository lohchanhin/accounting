import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2)
class Transaction {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String? note;

  @HiveField(5)
  final String? receiptUrl;

  @HiveField(6)
  final bool isExpense; // 用於標識是收入還是支出

  Transaction({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
    this.receiptUrl,
    required this.isExpense,
  });
}
