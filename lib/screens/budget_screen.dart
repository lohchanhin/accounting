import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/budget_category.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final DatabaseService _dbService = DatabaseService(); // 初始化數據庫服務
  final TextEditingController _nameController =
      TextEditingController(); // 控制名稱輸入的控制器
  final TextEditingController _budgetController =
      TextEditingController(); // 控制預算輸入的控制器
  bool _isExpense = true; // 用於標識當前選擇的類別是否為支出
  IconData _selectedIcon = Icons.category; // 當前選擇的圖標
  List<BudgetCategory> _categories = []; // 預算類別列表

  @override
  void initState() {
    super.initState();
    _loadCategories(); // 加載預算類別
  }

  // 從數據庫加載預算類別
  Future<void> _loadCategories() async {
    List<BudgetCategory> categories =
        await _dbService.getBudgetCategories(_isExpense);
    setState(() {
      _categories = categories;
    });
  }

  // 添加新類別到數據庫
  Future<void> _addCategory() async {
    BudgetCategory newCategory = BudgetCategory(
      name: _nameController.text,
      icon: _selectedIcon,
      budget: double.tryParse(_budgetController.text),
      isExpense: _isExpense,
    );
    await _dbService.addBudgetCategory(newCategory);
    _loadCategories(); // 更新列表
    setState(() {
      _nameController.clear();
      _budgetController.clear();
      _selectedIcon = Icons.category;
    });
  }

  // 當選擇圖標時更新狀態
  void _onIconSelected(IconData icon) {
    setState(() {
      _selectedIcon = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('預算與類別管理'), // 應用標題
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 增加整體邊距
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 支出按鈕
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isExpense = true;
                      _loadCategories();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isExpense ? Colors.blue : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // 圓角設計
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    '支出',
                    style: TextStyle(
                      color: _isExpense ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                // 收入按鈕
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isExpense = false;
                      _loadCategories();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isExpense ? Colors.blue : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // 圓角設計
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    '收入',
                    style: TextStyle(
                      color: !_isExpense ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            // 類別名稱輸入框
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '類別名稱',
                  border: OutlineInputBorder(), // 方框邊界
                ),
              ),
            ),
            // 每月預算輸入框
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _budgetController,
                decoration: InputDecoration(
                  labelText: '每月預算',
                  border: OutlineInputBorder(), // 方框邊界
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            // 圖標選擇按鈕
            IconButton(
              icon: Icon(_selectedIcon, size: 40), // 調整圖標大小
              onPressed: () async {
                IconData? icon = await showDialog<IconData>(
                  context: context,
                  builder: (context) => IconPickerDialog(
                    onIconSelected: _onIconSelected,
                  ),
                );
                if (icon != null) {
                  _onIconSelected(icon);
                }
              },
            ),
            // 添加類別按鈕
            ElevatedButton(
              onPressed: _addCategory,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // 圓角設計
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              child: Text(
                '添加類別',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            // 顯示預算類別列表
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  BudgetCategory category = _categories[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: ListTile(
                      leading: Icon(category.icon, size: 40),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Text(
                        category.budget != null
                            ? '\$${category.budget!.toStringAsFixed(2)}'
                            : 'No budget',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
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

class IconPickerDialog extends StatefulWidget {
  final Function(IconData) onIconSelected; // 當選擇圖標時的回調函數

  IconPickerDialog({required this.onIconSelected});

  @override
  _IconPickerDialogState createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  // 定義一組常用的圖標
  final List<IconData> _icons = [
    Icons.category,
    Icons.food_bank,
    Icons.shopping_cart,
    Icons.local_hospital,
    Icons.school,
    Icons.directions_car,
    Icons.house,
    Icons.fitness_center,
    Icons.flight,
    Icons.movie,
    // Add more icons as needed
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('選擇圖標'),
      content: Container(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: _icons.length,
          itemBuilder: (context, index) {
            IconData icon = _icons[index];
            return IconButton(
              icon: Icon(icon, size: 30), // 調整圖標大小
              onPressed: () {
                widget.onIconSelected(icon); // 當選擇圖標時觸發回調函數
                Navigator.of(context).pop(icon); // 關閉對話框
              },
            );
          },
        ),
      ),
    );
  }
}
