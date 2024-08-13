import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'package:hive/hive.dart';

class TargetSelection extends StatefulWidget {
  final String category;
  final IconData icon;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final DateTime selectedMonth;
  final bool isExpense; // 标记类别是收入还是支出

  const TargetSelection({
    Key? key,
    required this.category,
    required this.icon,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.selectedMonth,
    required this.isExpense,
  }) : super(key: key);

  @override
  _TargetSelectionState createState() => _TargetSelectionState();
}

class _TargetSelectionState extends State<TargetSelection> {
  double remainingBudget = 0; // 剩余预算
  double totalSpentOrIncome = 0; // 总支出或总收入
  final Box _cacheBox = Hive.box('cacheBox'); // 使用Hive缓存箱

  @override
  void initState() {
    super.initState();
    _loadAmounts();
  }

  Future<void> _loadAmounts() async {
    print('更新类别的金额');

    DatabaseService dbService = DatabaseService();

    if (widget.isExpense) {
      String remainingBudgetCacheKey =
          'remainingBudget_${widget.category}_${widget.selectedMonth.month}_${widget.selectedMonth.year}';
      String totalSpentCacheKey =
          'totalSpent_${widget.category}_${widget.selectedMonth.month}_${widget.selectedMonth.year}';

      // 尝试从缓存中获取剩余预算
      double? cachedRemainingBudget = _cacheBox.get(remainingBudgetCacheKey);
      double? cachedTotalSpent = _cacheBox.get(totalSpentCacheKey);

      if (cachedRemainingBudget != null && cachedTotalSpent != null) {
        setState(() {
          remainingBudget = cachedRemainingBudget;
          totalSpentOrIncome = cachedTotalSpent;
        });
      } else {
        double retrievedRemainingBudget = await dbService.getRemainingBudget(
            widget.category, widget.selectedMonth);
        double retrievedTotalSpent = await dbService.getMonthlySpending(
            widget.category, widget.selectedMonth);

        // 将数据存储到缓存中
        _cacheBox.put(remainingBudgetCacheKey, retrievedRemainingBudget);
        _cacheBox.put(totalSpentCacheKey, retrievedTotalSpent);

        if (mounted) {
          setState(() {
            remainingBudget = retrievedRemainingBudget;
            totalSpentOrIncome = retrievedTotalSpent;
          });
        }
      }
    } else {
      String totalIncomeCacheKey =
          'totalIncome_${widget.category}_${widget.selectedMonth.month}_${widget.selectedMonth.year}';

      // 尝试从缓存中获取总收入
      double? cachedTotalIncome = _cacheBox.get(totalIncomeCacheKey);

      if (cachedTotalIncome != null) {
        setState(() {
          totalSpentOrIncome = cachedTotalIncome;
        });
      } else {
        double retrievedTotalIncome = await dbService.getTotalIncome(
            widget.category, widget.selectedMonth);

        // 将数据存储到缓存中
        _cacheBox.put(totalIncomeCacheKey, retrievedTotalIncome);

        if (mounted) {
          setState(() {
            totalSpentOrIncome = retrievedTotalIncome;
          });
        }
      }
    }
  }

  @override
  void didUpdateWidget(TargetSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory ||
        oldWidget.selectedMonth != widget.selectedMonth) {
      _loadAmounts();
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
            SizedBox(height: 4),
            Text(
              widget.isExpense
                  ? '花费: \$${totalSpentOrIncome.toStringAsFixed(2)}'
                  : '收入: \$${totalSpentOrIncome.toStringAsFixed(2)}',
              style: TextStyle(
                color: widget.selectedCategory == widget.category
                    ? Colors.white
                    : Colors.black,
                fontSize: 12,
              ),
            ),
            if (widget.isExpense) ...[
              SizedBox(height: 4),
              Text(
                '餘額: \$${remainingBudget.toStringAsFixed(2)}',
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
