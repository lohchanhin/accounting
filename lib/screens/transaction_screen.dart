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

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _noteController = TextEditingController();
  String _selectedCategory = '';
  bool _isExpense = true;
  double _amount = 0.0;
  List<Budget> _budgets = [];
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadBudgets();
    _loadCategories();
  }

  Future<void> _loadBudgets() async {
    List<Budget> budgets = await _dbService.getBudgets();
    setState(() {
      _budgets = budgets;
    });
  }

  Future<void> _loadCategories() async {
    List<String> categories = await _dbService.getCategories(_isExpense);
    setState(() {
      _categories = categories.map((category) {
        return {
          'category': category,
          'icon': Icons.category, // 假設有個預設圖標
          'budget': _budgets
              .firstWhere((b) => b.category == category,
                  orElse: () => Budget(id: '', category: category))
              .amount,
        };
      }).toList();
      _selectedCategory = '';
    });
  }

  void _addTransaction() async {
    trans.Transaction newTransaction = trans.Transaction(
      id: '',
      category: _selectedCategory,
      amount: _amount,
      date: DateTime.now(),
      note: _noteController.text,
    );

    await _dbService.addTransaction(newTransaction);
    _loadBudgets(); // 更新預算

    setState(() {
      _noteController.clear();
      _amount = 0.0;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _isExpense = category == '支出';
      _selectedCategory = '';
      _loadCategories();
    });
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

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
      body: Column(
        children: <Widget>[
          Expanded(
            child: CategorySelector(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              isExpense: _isExpense,
            ),
            flex: 1,
          ),
          Expanded(
            child: NumericInput(
              onValueChanged: (value) {
                setState(() {
                  _amount = value;
                });
              },
              noteController: _noteController,
              onAddTransaction: _addTransaction,
            ),
            flex: 1,
          ),
        ],
      ),
    );
  }
}
