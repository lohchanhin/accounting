import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'budget_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';
import '../models/budget.dart';
import '../models/transaction.dart' as trans;
import '../widgets/category_selector.dart';
import '../widgets/numeric_input.dart';
import '../services/database_service.dart';
import '../models/budget_category.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final DatabaseService _dbService = DatabaseService(); // 初始化数据库服务
  final TextEditingController _noteController =
      TextEditingController(); // 备注控制器
  String _selectedCategory = ''; // 当前选中的类别
  bool _isExpense = true; // 用于标识当前选择的类别是否为支出
  double _amount = 0.0; // 交易金额
  List<Budget> _budgets = []; // 预算列表
  List<Map<String, dynamic>> _categories = []; // 类别列表

  @override
  void initState() {
    super.initState();
    _loadBudgets(); // 加载预算
    _loadCategories(); // 加载类别
  }

  // 从数据库加载预算
  Future<void> _loadBudgets() async {
    List<Budget> budgets = await _dbService.getBudgets();
    setState(() {
      _budgets = budgets;
    });
  }

  // 从数据库加载类别
  Future<void> _loadCategories() async {
    List<BudgetCategory> categories =
        await _dbService.getBudgetCategories(_isExpense);
    setState(() {
      _categories = categories.map((category) {
        return {
          'category': category.name,
          'icon': category.icon,
        };
      }).toList();
      _selectedCategory = '';
    });
  }

  // 添加新的交易
  void _addTransaction() async {
    trans.Transaction newTransaction = trans.Transaction(
      id: '',
      category: _selectedCategory,
      amount: _amount,
      date: DateTime.now(),
      note: _noteController.text,
    );

    await _dbService.addTransaction(newTransaction);
    _loadBudgets(); // 更新预算

    setState(() {
      _noteController.clear();
      _amount = 0.0;
    });
  }

  // 当选择支出或收入时更新类别
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  // 切换收入或支出并更新类别
  void _toggleExpense(bool isExpense) {
    setState(() {
      _isExpense = isExpense;
      _loadCategories();
    });
  }

  // 导航到指定页面
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // 构建侧边菜单
  Widget _buildSideMenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
                FirebaseAuth.instance.currentUser?.displayName ?? 'User Name'),
            accountEmail:
                Text(FirebaseAuth.instance.currentUser?.email ?? 'User Email'),
            currentAccountPicture: CircleAvatar(
              child: Text(FirebaseAuth.instance.currentUser?.displayName
                      ?.substring(0, 1) ??
                  'U'),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('Budget'),
            onTap: () => _navigateTo(context, const BudgetScreen()),
          ),
          ListTile(
            leading: Icon(Icons.assessment),
            title: Text('Report'),
            onTap: () => _navigateTo(context, const ReportScreen()),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => _navigateTo(context, const SettingsScreen()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      drawer: _buildSideMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 增加整体边距
        child: Column(
          children: <Widget>[
            // 类别选择器
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CategorySelector(
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: _onCategorySelected,
                    isExpense: _isExpense,
                    onExpenseToggle: _toggleExpense, // 添加切换收入支出的回调函数
                  ),
                ),
              ),
              flex: 1,
            ),
            SizedBox(height: 10),
            // 数字输入区域
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: NumericInput(
                    onValueChanged: (value) {
                      setState(() {
                        _amount = value;
                      });
                    },
                    noteController: _noteController,
                    onAddTransaction: _addTransaction,
                  ),
                ),
              ),
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }
}
