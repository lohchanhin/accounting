import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/budget_category.dart';
import '../models/budget.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final DatabaseService _dbService = DatabaseService(); // 初始化数据库服务
  final TextEditingController _nameController =
      TextEditingController(); // 控制名称输入的控制器
  bool _isExpense = true; // 用于标识当前选择的类别是否为支出
  IconData _selectedIcon = Icons.category; // 当前选择的图标
  List<BudgetCategory> _categories = []; // 预算类别列表
  DateTime _selectedMonth = DateTime.now(); // 当前选择的月份

  @override
  void initState() {
    super.initState();
    _selectedMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1); // 设置为当月的第一天
    _loadCategories(); // 加载预算类别
  }

  // 从数据库加载预算类别
  Future<void> _loadCategories() async {
    List<BudgetCategory> categories =
        await _dbService.getBudgetCategories(_isExpense);
    setState(() {
      _categories = categories;
    });
  }

  // 添加新类别到数据库
  Future<void> _addCategory() async {
    BudgetCategory newCategory = BudgetCategory(
      name: _nameController.text,
      icon: _selectedIcon,
      isExpense: _isExpense,
    );
    await _dbService.addBudgetCategory(newCategory);
    _loadCategories(); // 更新列表
    setState(() {
      _nameController.clear();
      _selectedIcon = Icons.category;
    });
  }

  // 当选择图标时更新状态
  void _onIconSelected(IconData icon) {
    setState(() {
      _selectedIcon = icon;
    });
  }

  // 切换月份
  void _onMonthChanged(DateTime newMonth) {
    setState(() {
      _selectedMonth = DateTime(newMonth.year, newMonth.month, 1); // 设置为当月的第一天
    });
    // 根据新月份更新预算或消费数据
  }

  // 显示月份选择器
  void _showMonthPicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      selectableDayPredicate: (DateTime val) => val.day == 1,
    ).then((pickedDate) {
      if (pickedDate != null && pickedDate != _selectedMonth) {
        _onMonthChanged(pickedDate);
      }
    });
  }

  // 显示修改预算的对话框
  void _showEditBudgetDialog(BudgetCategory category) async {
    final TextEditingController _editBudgetController = TextEditingController();
    double monthlySpending =
        await _dbService.getMonthlySpending(category.name, _selectedMonth);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('修改预算 - ${category.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _editBudgetController,
                decoration: InputDecoration(labelText: '每月预算'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              Text('本月已花费: \$${monthlySpending.toStringAsFixed(2)}'),
            ],
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
                  Budget updatedBudget = Budget(
                    id: '',
                    category: category.name,
                    amount: newBudget,
                    spent: monthlySpending,
                    date: _selectedMonth,
                  );
                  await _dbService.addBudget(updatedBudget);
                  _loadCategories(); // 更新类别列表
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
        title: const Text('预算与类别管理'), // 应用标题
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _showMonthPicker(context), // 显示月份选择器
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 增加整体边距
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 支出按钮
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
                      borderRadius: BorderRadius.circular(20.0), // 圆角设计
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
                // 收入按钮
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
                      borderRadius: BorderRadius.circular(20.0), // 圆角设计
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
            // 类别名称输入框
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '类别名称',
                  border: OutlineInputBorder(), // 方框边界
                ),
              ),
            ),
            // 图标选择按钮
            IconButton(
              icon: Icon(_selectedIcon, size: 40), // 调整图标大小
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
            // 添加类别按钮
            ElevatedButton(
              onPressed: _addCategory,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // 圆角设计
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              child: Text(
                '添加类别',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            // 显示预算类别列表
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
                      trailing: Icon(Icons.edit),
                      onTap: () {
                        _showEditBudgetDialog(category); // 实现查看和修改预算的功能
                      },
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
  final Function(IconData) onIconSelected; // 当选择图标时的回调函数

  IconPickerDialog({required this.onIconSelected});

  @override
  _IconPickerDialogState createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  // 定义一组常用的图标
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
      title: Text('选择图标'),
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
              icon: Icon(icon, size: 30), // 调整图标大小
              onPressed: () {
                widget.onIconSelected(icon); // 当选择图标时触发回调函数
                Navigator.of(context).pop(icon); // 关闭对话框
              },
            );
          },
        ),
      ),
    );
  }
}
