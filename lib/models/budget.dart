class Budget {
  final String id;
  final String category;
  final double? amount; // 可选的预算金额
  final double spent;
  final DateTime date; // 新增日期字段

  Budget({
    required this.id,
    required this.category,
    required this.date,
    this.amount,
    this.spent = 0,
  });
}
