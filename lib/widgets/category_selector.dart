import 'package:flutter/material.dart';
import 'target_selection.dart';

class CategorySelector extends StatefulWidget {
  final List<Map<String, dynamic>> categories; // 类别列表
  final String selectedCategory; // 当前选中的类别
  final Function(String) onCategorySelected; // 当类别被选中时的回调函数
  final bool isExpense; // 标志是支出还是收入
  final Function(bool) onExpenseToggle; // 切换支出或收入的回调函数

  CategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.isExpense,
    required this.onExpenseToggle,
  });

  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late bool _isExpense;
  String _uniqueKey = '';

  @override
  void initState() {
    super.initState();
    _isExpense = widget.isExpense;
  }

  void _toggleExpense(bool isExpense) {
    setState(() {
      _isExpense = isExpense;
      widget.onExpenseToggle(isExpense);
      // 生成一个新的唯一键以强制刷新 TargetSelection
      _uniqueKey = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // 支出和收入切换按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 支出按钮
            ElevatedButton(
              onPressed: () => _toggleExpense(true), // 切换到支出
              style: ElevatedButton.styleFrom(
                backgroundColor: _isExpense ? Colors.blue : Colors.grey,
                foregroundColor: _isExpense ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text('支出'), // 按钮标题
            ),
            SizedBox(width: 10), // 按钮之间的间距
            // 收入按钮
            ElevatedButton(
              onPressed: () => _toggleExpense(false), // 切换到收入
              style: ElevatedButton.styleFrom(
                backgroundColor: !_isExpense ? Colors.blue : Colors.grey,
                foregroundColor: !_isExpense ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text('收入'), // 按钮标题
            ),
          ],
        ),
        // 类别选择器
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: widget.categories.length,
            itemBuilder: (BuildContext context, int index) {
              var categoryData = widget.categories[index];
              return TargetSelection(
                key: ValueKey(_uniqueKey + categoryData['category']),
                selectedMonth: DateTime.now(),
                category: categoryData['category'],
                icon: categoryData['icon'],
                selectedCategory: widget.selectedCategory,
                onCategorySelected: widget.onCategorySelected,
                isExpense: _isExpense,
              );
            },
          ),
        ),
      ],
    );
  }
}
