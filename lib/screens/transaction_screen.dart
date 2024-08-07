import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'budget_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';
import '../models/budget.dart';
import '../models/transaction.dart' as trans;
import '../widgets/category_selector.dart';
import '../services/database_service.dart';
import '../models/budget_category.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final DatabaseService _dbService = DatabaseService(); // 初始化数据库服务
  final FirebaseFirestore _db = FirebaseFirestore.instance; // 初始化 Firestore

  final TextEditingController _noteController =
      TextEditingController(); // 备注控制器
  final TextEditingController _amountController =
      TextEditingController(); // 金额控制器
  String _selectedCategory = ''; // 当前选中的类别
  bool _isExpense = true; // 用于标识当前选择的类别是否为支出
  double _amount = 0.0; // 交易金额
  List<Budget> _budgets = []; // 预算列表
  List<Map<String, dynamic>> _categories = []; // 类别列表
  String? _receiptUrl; // 存储发票图片的URL
  double _totalIncome = 0.0; // 存储特定类别的总收入

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
        await _dbService.getCategories(_isExpense);
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

  // 从数据库加载特定类别的总收入
  Future<void> _loadIncome(String category) async {
    double totalIncome =
        await _dbService.getTotalIncome(category, DateTime.now());
    setState(() {
      _totalIncome = totalIncome;
    });
  }

  // 添加新的交易并更新预算
  Future<void> _addTransaction(
      String category, double amount, String note) async {
    trans.Transaction newTransaction = trans.Transaction(
      id: '',
      category: category,
      amount: amount,
      date: DateTime.now(),
      note: note,
      isExpense: _isExpense,
      receiptUrl: _receiptUrl,
    );

    await _dbService.addTransaction(newTransaction);
    setState(() {
      _noteController.clear();
      _amountController.clear();
      _amount = 0.0;
    });

    // 弹出提示框
    _showConfirmationDialog();
  }

  // 显示确认对话框
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('交易已添加'),
          content: Text('您的交易记录已成功添加。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadCategories(); // 确认后刷新类别UI
              },
              child: Text('确认'),
            ),
          ],
        );
      },
    );
  }

  // 当选择支出或收入时更新类别
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    if (!_isExpense) {
      _loadIncome(category); // 加载特定类别的总收入
    }
    _showInputDialog(); // 显示输入对话框
  }

  // 切换收入或支出并更新类别和预算
  void _toggleExpense(bool isExpense) {
    setState(() {
      _isExpense = isExpense;
      _loadCategories();
      _loadBudgets(); // 切换支出或收入时加载预算
      if (!isExpense && _selectedCategory.isNotEmpty) {
        _loadIncome(_selectedCategory); // 切换到收入时加载特定类别的总收入
      }
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

  // 显示输入对话框
  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('输入交易信息'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: '备注',
                ),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: '金额',
                ),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: _pickReceiptImage,
                child: Text('上传发票'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                double amount = double.tryParse(_amountController.text) ?? 0.0;
                _addTransaction(
                    _selectedCategory, amount, _noteController.text);
                Navigator.of(context).pop();
              },
              child: Text('确认'),
            ),
          ],
        );
      },
    );
  }

  // 选择发票图片
  Future<void> _pickReceiptImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _receiptUrl = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记账'),
      ),
      drawer: _buildSideMenu(),
      body: Padding(
        padding: const EdgeInsets.all(0.0), // 增加整体边距
        child: Column(
          children: <Widget>[
            // 类别选择器
            Flexible(
              flex: 1,
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
          ],
        ),
      ),
    );
  }
}
