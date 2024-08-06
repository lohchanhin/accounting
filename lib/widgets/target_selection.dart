import 'package:flutter/material.dart';
import '../services/database_service.dart';

class TargetSelection extends StatefulWidget {
  final String category;
  final IconData icon;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final DateTime selectedMonth;

  const TargetSelection({
    Key? key,
    required this.category,
    required this.icon,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.selectedMonth,
  }) : super(key: key);

  @override
  _TargetSelectionState createState() => _TargetSelectionState();
}

class _TargetSelectionState extends State<TargetSelection> {
  double? remainingBudget;

  @override
  void initState() {
    super.initState();
    _loadRemainingBudget();
  }

  Future<void> _loadRemainingBudget() async {
    DatabaseService dbService = DatabaseService();
    double budget = await dbService.getRemainingBudget(
        widget.category, widget.selectedMonth);
    setState(() {
      remainingBudget = budget;
    });
  }

  @override
  void didUpdateWidget(TargetSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _loadRemainingBudget();
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
            if (remainingBudget != null) ...[
              SizedBox(height: 4),
              Text(
                '预算: \$${remainingBudget!.toStringAsFixed(2)}', // 显示剩余预算
                style: TextStyle(
                  color: widget.selectedCategory == widget.category
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
