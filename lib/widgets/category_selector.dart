import 'package:flutter/material.dart';
import 'target_selection.dart';

class CategorySelector extends StatefulWidget {
  final List<Map<String, dynamic>> categories; // 類別列表
  final String selectedCategory; // 當前選中的類別
  final Function(String) onCategorySelected; // 當類別被選中時的回調函數
  final bool isExpense; // 標誌是支出還是收入

  CategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.isExpense,
  });

  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late bool _isExpense;

  @override
  void initState() {
    super.initState();
    _isExpense = widget.isExpense;
  }

  void _onCategorySelected(String category) {
    setState(() {
      _isExpense = category == '支出';
      widget.onCategorySelected(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // 支出和收入切換按鈕
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 支出按鈕
            ElevatedButton(
              onPressed: () => _onCategorySelected('支出'), // 按鈕被按下時的回調函數
              style: ElevatedButton.styleFrom(
                backgroundColor: _isExpense
                    ? Colors.grey[700]
                    : Colors.white, // 根據 _isExpense 設置按鈕顏色
                foregroundColor: _isExpense ? Colors.white : Colors.black,
                side: BorderSide(color: Colors.black),
                elevation: 5,
              ),
              child: Text('支出'), // 按鈕標題
            ),
            SizedBox(width: 10), // 按鈕之間的間距
            // 收入按鈕
            ElevatedButton(
              onPressed: () => _onCategorySelected('收入'), // 按鈕被按下時的回調函數
              style: ElevatedButton.styleFrom(
                backgroundColor: !_isExpense
                    ? Colors.grey[700]
                    : Colors.white, // 根據 _isExpense 設置按鈕顏色
                foregroundColor: !_isExpense ? Colors.white : Colors.black,
                side: BorderSide(color: Colors.black),
                elevation: 5,
              ),
              child: Text('收入'), // 按鈕標題
            ),
          ],
        ),
        // 類別選擇器
        Wrap(
          alignment: WrapAlignment.center, // 將所有子元素居中對齊
          children: widget.categories
              .map((categoryData) => Padding(
                    padding: const EdgeInsets.all(8.0), // 子元素之間的間距
                    child: TargetSelection(
                      category: categoryData['category'],
                      icon: categoryData['icon'],
                      budget: categoryData['budget'],
                      selectedCategory: widget.selectedCategory,
                      onCategorySelected: widget.onCategorySelected,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
