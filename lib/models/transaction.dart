class Transaction {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String? note;
  final String? receiptUrl;

  Transaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
    this.receiptUrl,
  });
}
