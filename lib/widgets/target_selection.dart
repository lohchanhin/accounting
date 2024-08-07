import 'package:flutter/material.dart';
import '../services/database_service.dart';

class TargetSelection extends StatefulWidget {
  final String category;
  final IconData icon;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final DateTime selectedMonth;
  final bool isExpense; // 新增字段标记类别是收入还是支出

  const TargetSelection({
    Key? key,
    required this.category,
    required this.icon,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.selectedMonth,
    required this.isExpense, // 初始化字段
  }) : super(key: key);

  @override
  _TargetSelectionState createState() => _TargetSelectionState();
}

class _TargetSelectionState extends State<TargetSelection> {
  double amount = 0; // 用于显示剩余预算或总收入

  @override
  void initState() {
    super.initState();
    _loadAmount();
  }

  Future<void> _loadAmount() async {
    print('更新图表金额');
    DatabaseService dbService = DatabaseService();
    if (widget.isExpense) {
      double budget = await dbService.getRemainingBudget(
          widget.category, widget.selectedMonth);
      if (mounted) {
        setState(() {
          amount = budget;
        });
      }
    } else {
      double income =
          await dbService.getTotalIncome(widget.category, widget.selectedMonth);
      if (mounted) {
        setState(() {
          amount = income;
        });
      }
    }
  }

  @override
  void didUpdateWidget(TargetSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _loadAmount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onCategorySelected(widget.category);
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.selectedCategory == widget.category
              ? Colors.blue
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              color: widget.selectedCategory == widget.category
                  ? Colors.white
                  : Colors.black,
            ),
            SizedBox(height: 4),
            Text(
              widget.category,
              style: TextStyle(
                color: widget.selectedCategory == widget.category
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            ...[
              SizedBox(height: 4),
              Text(
                '\$${amount.toStringAsFixed(2)}', // 显示剩余预算或总收入
                style: TextStyle(
                  color: widget.selectedCategory == widget.category
                      ? Colors.white
                      : Colors.black,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
