import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/budget.dart';
import '../models/transaction.dart' as trans;
import '../models/budget_category.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance; // 初始化 Firestore
  final Box _cacheBox = Hive.box('cacheBox'); // 使用Hive的缓存箱

  // 添加新的预算记录到 Firestore
  Future<void> addBudget(Budget budget) async {
    await _db.collection('budgets').add({
      'category': budget.category,
      'amount': budget.amount,
      'spent': budget.spent,
      'date': budget.monthYear,
    });
    _cacheBox.put('budgets', null); // 清空缓存以便下次重新获取
  }

  // 更新已有的预算记录
  Future<void> updateBudget(Budget budget) async {
    await _db.collection('budgets').doc(budget.id).update({
      'category': budget.category,
      'amount': budget.amount,
      'spent': budget.spent,
      'date': budget.monthYear,
    });
    _cacheBox.put('budgets', null); // 清空缓存以便下次重新获取
  }

  // 获取所有的预算记录
  Future<List<Budget>> getBudgets() async {
    if (_cacheBox.get('budgets') != null) {
      return (_cacheBox.get('budgets') as List)
          .map((e) => e as Budget)
          .toList();
    } else {
      QuerySnapshot snapshot = await _db.collection('budgets').get();
      List<Budget> budgets = snapshot.docs.map((doc) {
        return Budget(
          id: doc.id,
          category: doc['category'],
          amount: doc['amount'],
          spent: doc['spent'],
          monthYear: (doc['date'] as Timestamp).toDate(),
        );
      }).toList();
      _cacheBox.put('budgets', budgets); // 将获取的数据存储到缓存中
      return budgets;
    }
  }

  // 添加新的交易记录
  Future<void> addTransaction(trans.Transaction transaction) async {
    await _db.collection('transactions').add({
      'category': transaction.category,
      'amount': transaction.amount,
      'date': transaction.date,
      'note': transaction.note,
      'receiptUrl': transaction.receiptUrl,
      'isExpense': transaction.isExpense,
    });

    // 更新预算的花费金额
    QuerySnapshot budgetSnapshot = await _db
        .collection('budgets')
        .where('category', isEqualTo: transaction.category)
        .get();
    if (budgetSnapshot.docs.isNotEmpty) {
      DocumentSnapshot budgetDoc = budgetSnapshot.docs.first;
      double newSpent = budgetDoc['spent'] + transaction.amount;
      await _db.collection('budgets').doc(budgetDoc.id).update({
        'spent': newSpent,
      });
    }
    _cacheBox.put('transactions', null); // 清空交易缓存
  }

  // 更新已有的交易记录
  Future<void> updateTransaction(trans.Transaction transaction) async {
    await _db.collection('transactions').doc(transaction.id).update({
      'category': transaction.category,
      'amount': transaction.amount,
      'date': transaction.date,
      'note': transaction.note,
      'receiptUrl': transaction.receiptUrl,
      'isExpense': transaction.isExpense,
    });
    _cacheBox.put('transactions', null); // 清空交易缓存
  }

  // 删除交易记录
  Future<void> deleteTransaction(String transactionId) async {
    await _db.collection('transactions').doc(transactionId).delete();
    _cacheBox.put('transactions', null); // 清空交易缓存
  }

  // 获取所有的交易记录
  Future<List<trans.Transaction>> getTransactions() async {
    if (_cacheBox.get('transactions') != null) {
      return (_cacheBox.get('transactions') as List)
          .map((e) => e as trans.Transaction)
          .toList();
    } else {
      QuerySnapshot snapshot = await _db.collection('transactions').get();
      List<trans.Transaction> transactions = snapshot.docs.map((doc) {
        return trans.Transaction(
          id: doc.id,
          category: doc['category'],
          amount: doc['amount'],
          date: (doc['date'] as Timestamp).toDate(),
          note: doc['note'],
          receiptUrl: doc['receiptUrl'],
          isExpense: doc['isExpense'],
        );
      }).toList();
      _cacheBox.put('transactions', transactions); // 将获取的数据存储到缓存中
      return transactions;
    }
  }

  // 获取指定类型的所有类别（支出或收入）
  Future<List<BudgetCategory>> getCategories(bool isExpense) async {
    String cacheKey = 'categories_$isExpense';
    if (_cacheBox.get(cacheKey) != null) {
      return (_cacheBox.get(cacheKey) as List)
          .map((e) => e as BudgetCategory)
          .toList();
    } else {
      QuerySnapshot snapshot = await _db
          .collection('budgetCategories')
          .where('isExpense', isEqualTo: isExpense)
          .get();
      List<BudgetCategory> categories = snapshot.docs.map((doc) {
        return BudgetCategory(
          id: doc.id,
          name: doc['name'],
          icon: IconData(doc['icon'], fontFamily: 'MaterialIcons'),
          isExpense: doc['isExpense'],
        );
      }).toList();
      _cacheBox.put(cacheKey, categories); // 将获取的数据存储到缓存中
      return categories;
    }
  }

  // 添加新的预算类别到 Firestore
  Future<void> addBudgetCategory(BudgetCategory category) async {
    await _db.collection('budgetCategories').add({
      'name': category.name,
      'icon': category.icon.codePoint,
      'isExpense': category.isExpense,
    });
    _cacheBox.put('categories_${category.isExpense}', null); // 清空类别缓存
  }

  // 更新已有的预算类别记录
  Future<void> updateBudgetCategory(BudgetCategory category) async {
    await _db.collection('budgetCategories').doc(category.id).update({
      'name': category.name,
      'icon': category.icon.codePoint,
      'isExpense': category.isExpense,
    });
    _cacheBox.put('categories_${category.isExpense}', null); // 清空类别缓存
  }

  // 删除预算类别记录
  Future<void> deleteBudgetCategory(String categoryId) async {
    DocumentSnapshot categoryDoc =
        await _db.collection('budgetCategories').doc(categoryId).get();
    bool isExpense = categoryDoc['isExpense'];
    await _db.collection('budgetCategories').doc(categoryId).delete();
    _cacheBox.put('categories_$isExpense', null); // 清空类别缓存
  }

  // 获取指定类别在指定月份的消费总额
  Future<double> getMonthlySpending(String category, DateTime month) async {
    String cacheKey = 'spending_${category}_${month.month}_${month.year}';
    if (_cacheBox.get(cacheKey) != null) {
      return _cacheBox.get(cacheKey);
    } else {
      DateTime startDate = DateTime(month.year, month.month, 1);
      DateTime endDate = DateTime(month.year, month.month + 1, 1);
      QuerySnapshot snapshot = await _db
          .collection('transactions')
          .where('category', isEqualTo: category)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThan: endDate)
          .get();

      double totalSpending = snapshot.docs.fold(0.0, (sum, doc) {
        return sum + doc['amount'];
      });
      _cacheBox.put(cacheKey, totalSpending); // 将获取的数据存储到缓存中
      return totalSpending;
    }
  }

  // 获取某个月份的预算
  Future<List<Budget>> getBudgetsForMonth(DateTime month) async {
    String cacheKey = 'budgets_${month.month}_${month.year}';
    if (_cacheBox.get(cacheKey) != null) {
      return (_cacheBox.get(cacheKey) as List).map((e) => e as Budget).toList();
    } else {
      DateTime startDate = DateTime(month.year, month.month, 1);
      DateTime endDate = DateTime(month.year, month.month + 1, 1);
      QuerySnapshot snapshot = await _db
          .collection('budgets')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThan: endDate)
          .get();
      List<Budget> budgets = snapshot.docs.map((doc) {
        return Budget(
          id: doc.id,
          category: doc['category'],
          amount: doc['amount'],
          spent: doc['spent'],
          monthYear: (doc['date'] as Timestamp).toDate(),
        );
      }).toList();
      _cacheBox.put(cacheKey, budgets); // 将获取的数据存储到缓存中
      return budgets;
    }
  }

  // 获取指定类别在指定月份的剩余预算
  Future<double> getRemainingBudget(String category, DateTime month) async {
    String cacheKey =
        'remainingBudget_${category}_${month.month}_${month.year}';
    if (_cacheBox.get(cacheKey) != null) {
      return _cacheBox.get(cacheKey);
    } else {
      DateTime startDate = DateTime(month.year, month.month, 1);
      DateTime endDate = DateTime(month.year, month.month + 1, 1);
      QuerySnapshot budgetSnapshot = await _db
          .collection('budgets')
          .where('category', isEqualTo: category)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThan: endDate)
          .get();

      double amount = 0.0;
      double spent = 0.0;

      if (budgetSnapshot.docs.isNotEmpty) {
        var budget = budgetSnapshot.docs.first;
        amount = budget['amount'] ?? 0.0;
        spent = budget['spent'] ?? 0.0;
      } else {
        // 没有找到预算记录，创建一个新的预算记录
        await _db.collection('budgets').add({
          'category': category,
          'amount': 0.0,
          'spent': 0.0,
          'date': startDate,
        });
      }

      // 获取该类别在指定月份的消费记录
      QuerySnapshot transactionSnapshot = await _db
          .collection('transactions')
          .where('category', isEqualTo: category)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThan: endDate)
          .get();

      double totalSpent = transactionSnapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc['amount'] ?? 0.0);
      });

      // 更新预算的花费金额
      if (budgetSnapshot.docs.isNotEmpty) {
        var budgetDoc = budgetSnapshot.docs.first;
        await _db.collection('budgets').doc(budgetDoc.id).update({
          'spent': totalSpent,
        });
      }

      double remainingBudget = amount - totalSpent;
      _cacheBox.put(cacheKey, remainingBudget); // 将获取的数据存储到缓存中
      return remainingBudget;
    }
  }

  // 获取某个类别在指定月份的交易记录
  Future<List<trans.Transaction>> getTransactionsForCategoryAndMonth(
      String category, DateTime month) async {
    String cacheKey = 'transactions_${category}_${month.month}_${month.year}';
    if (_cacheBox.get(cacheKey) != null) {
      return (_cacheBox.get(cacheKey) as List)
          .map((e) => e as trans.Transaction)
          .toList();
    } else {
      DateTime startDate = DateTime(month.year, month.month, 1);
      DateTime endDate = DateTime(month.year, month.month + 1, 1);
      QuerySnapshot snapshot = await _db
          .collection('transactions')
          .where('category', isEqualTo: category)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThan: endDate)
          .get();

      List<trans.Transaction> transactions = snapshot.docs.map((doc) {
        return trans.Transaction(
          id: doc.id,
          category: doc['category'],
          amount: doc['amount'],
          date: (doc['date'] as Timestamp).toDate(),
          note: doc['note'],
          receiptUrl: doc['receiptUrl'],
          isExpense: doc['isExpense'],
        );
      }).toList();
      _cacheBox.put(cacheKey, transactions); // 将获取的数据存储到缓存中
      return transactions;
    }
  }

  // 获取指定类别在指定月份的总收入
  Future<double> getTotalIncome(String category, DateTime month) async {
    String cacheKey = 'totalIncome_${category}_${month.month}_${month.year}';
    if (_cacheBox.get(cacheKey) != null) {
      return _cacheBox.get(cacheKey);
    } else {
      DateTime startDate = DateTime(month.year, month.month, 1);
      DateTime endDate = DateTime(month.year, month.month + 1, 1);
      QuerySnapshot snapshot = await _db
          .collection('transactions')
          .where('category', isEqualTo: category)
          .where('isExpense', isEqualTo: false)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThan: endDate)
          .get();

      double totalIncome = snapshot.docs.fold(0.0, (sum, doc) {
        return sum + doc['amount'];
      });

      _cacheBox.put(cacheKey, totalIncome); // 将获取的数据存储到缓存中
      return totalIncome;
    }
  }
}
