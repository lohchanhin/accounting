import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/transaction.dart' as trans;
import '../models/budget.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String category;
  final DateTime month;
  final bool isExpense;

  const CategoryDetailScreen({
    Key? key,
    required this.category,
    required this.month,
    required this.isExpense,
  }) : super(key: key);

  @override
  _CategoryDetailScreenState createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final DatabaseService _dbService = DatabaseService();
  double _monthlyBudget = 0.0;
  double _monthlySpent = 0.0;
  double _totalIncome = 0.0; // 添加总收入
  List<trans.Transaction> _transactions = [];
  Budget? _currentBudget;

  @override
  void initState() {
    super.initState();
    _loadCategoryDetails();
  }

  Future<void> _loadCategoryDetails() async {
    if (widget.isExpense) {
      double remainingBudget =
          await _dbService.getRemainingBudget(widget.category, widget.month);
      double monthlySpent =
          await _dbService.getMonthlySpending(widget.category, widget.month);
      List<trans.Transaction> transactions = await _dbService
          .getTransactionsForCategoryAndMonth(widget.category, widget.month);

      setState(() {
        _monthlyBudget = remainingBudget + monthlySpent;
        _monthlySpent = monthlySpent;
        _transactions = transactions;
      });
    } else {
      List<trans.Transaction> transactions = await _dbService
          .getTransactionsForCategoryAndMonth(widget.category, widget.month);
      double totalIncome =
          transactions.fold(0.0, (sum, item) => sum + item.amount);

      setState(() {
        _transactions = transactions;
        _totalIncome = totalIncome; // 设置总收入
      });
    }
  }

  // 显示修改预算的对话框
  void _showEditBudgetDialog() {
    final TextEditingController _editBudgetController =
        TextEditingController(text: _currentBudget?.amount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('修改预算 - ${widget.category}'),
          content: TextField(
            controller: _editBudgetController,
            decoration: InputDecoration(labelText: '每月预算'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                double? newBudget = double.tryParse(_editBudgetController.text);
                if (newBudget != null) {
                  if (_currentBudget != null) {
                    _currentBudget!.amount = newBudget;
                    await _dbService.updateBudget(_currentBudget!);
                  } else {
                    Budget newBudgetEntry = Budget(
                      id: '',
                      category: widget.category,
                      monthYear: widget.month,
                      amount: newBudget,
                      spent: _monthlySpent,
                    );
                    await _dbService.addBudget(newBudgetEntry);
                  }
                  await _loadCategoryDetails();
                  Navigator.of(context).pop();
                }
              },
              child: Text('保存'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.category} - ${widget.month.year}-${widget.month.month}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isExpense) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '月份额度设置',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: _showEditBudgetDialog,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('预算: \$${_monthlyBudget.toStringAsFixed(2)}'),
                      SizedBox(height: 5),
                      Text('已花费: \$${_monthlySpent.toStringAsFixed(2)}'),
                    ] else ...[
                      Text(
                        '总收入: \$${_totalIncome.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  trans.Transaction transaction = _transactions[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: ListTile(
                      title: Text(transaction.note ?? '無備註'),
                      subtitle: Text(transaction.date.toString()),
                      trailing:
                          Text('\$${transaction.amount.toStringAsFixed(2)}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
