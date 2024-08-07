class Budget {
  final String? id;
  final String category;
  double? amount; // 可选的预算金额
  final double spent;
  final DateTime monthYear; // 用於標識預算屬於哪一個月份

  Budget({
    this.id,
    required this.category,
    required this.monthYear,
    this.amount,
    this.spent = 0,
  });
}
