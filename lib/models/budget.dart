class Budget {
  final String id;
  final String category;
  final double? amount; // 設置為可選，如果沒有設定預算則為null
  final double spent;

  Budget({
    required this.id,
    required this.category,
    this.amount,
    this.spent = 0,
  });
}
