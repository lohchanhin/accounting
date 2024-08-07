import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../models/transaction.dart' as trans;
import '../models/budget_category.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance; // 初始化 Firestore

  // 添加新的预算记录到 Firestore
  Future<void> addBudget(Budget budget) async {
    await _db.collection('budgets').add({
      'category': budget.category,
      'amount': budget.amount,
      'spent': budget.spent,
      'date': budget.monthYear,
    });
  }

  // 更新已有的预算记录
  Future<void> updateBudget(Budget budget) async {
    await _db.collection('budgets').doc(budget.id).update({
      'category': budget.category,
      'amount': budget.amount,
      'spent': budget.spent,
      'date': budget.monthYear,
    });
  }

  // 获取所有的预算记录
  Future<List<Budget>> getBudgets() async {
    QuerySnapshot snapshot = await _db.collection('budgets').get();
    return snapshot.docs.map((doc) {
      return Budget(
        id: doc.id,
        category: doc['category'],
        amount: doc['amount'],
        spent: doc['spent'],
        monthYear: (doc['date'] as Timestamp).toDate(),
      );
    }).toList();
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
  }

  // 删除交易记录
  Future<void> deleteTransaction(String transactionId) async {
    await _db.collection('transactions').doc(transactionId).delete();
  }

  // 获取所有的交易记录
  Future<List<trans.Transaction>> getTransactions() async {
    QuerySnapshot snapshot = await _db.collection('transactions').get();
    return snapshot.docs.map((doc) {
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
  }

  // 获取指定类型的所有类别（支出或收入）
  Future<List<BudgetCategory>> getCategories(bool isExpense) async {
    QuerySnapshot snapshot = await _db
        .collection('budgetCategories')
        .where('isExpense', isEqualTo: isExpense)
        .get();
    return snapshot.docs.map((doc) {
      return BudgetCategory(
        id: doc.id,
        name: doc['name'],
        icon: IconData(doc['icon'], fontFamily: 'MaterialIcons'),
        isExpense: doc['isExpense'],
      );
    }).toList();
  }

  // 添加新的预算类别到 Firestore
  Future<void> addBudgetCategory(BudgetCategory category) async {
    await _db.collection('budgetCategories').add({
      'name': category.name,
      'icon': category.icon.codePoint,
      'isExpense': category.isExpense,
    });
  }

  // 更新已有的预算类别记录
  Future<void> updateBudgetCategory(BudgetCategory category) async {
    await _db.collection('budgetCategories').doc(category.id).update({
      'name': category.name,
      'icon': category.icon.codePoint,
      'isExpense': category.isExpense,
    });
  }

  // 删除预算类别记录
  Future<void> deleteBudgetCategory(String categoryId) async {
    await _db.collection('budgetCategories').doc(categoryId).delete();
  }

  // 获取指定类别在指定月份的消费总额
  Future<double> getMonthlySpending(String category, DateTime month) async {
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

    return totalSpending;
  }

  // 获取某个月份的预算
  Future<List<Budget>> getBudgetsForMonth(DateTime month) async {
    DateTime startDate = DateTime(month.year, month.month, 1);
    DateTime endDate = DateTime(month.year, month.month + 1, 1);
    QuerySnapshot snapshot = await _db
        .collection('budgets')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThan: endDate)
        .get();
    return snapshot.docs.map((doc) {
      return Budget(
        id: doc.id,
        category: doc['category'],
        amount: doc['amount'],
        spent: doc['spent'],
        monthYear: (doc['date'] as Timestamp).toDate(),
      );
    }).toList();
  }

// 获取指定类别在指定月份的剩余预算
  Future<double> getRemainingBudget(String category, DateTime month) async {
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

    return amount - totalSpent;
  }

  // 获取某个类别在指定月份的交易记录
  Future<List<trans.Transaction>> getTransactionsForCategoryAndMonth(
      String category, DateTime month) async {
    DateTime startDate = DateTime(month.year, month.month, 1);
    DateTime endDate = DateTime(month.year, month.month + 1, 1);
    QuerySnapshot snapshot = await _db
        .collection('transactions')
        .where('category', isEqualTo: category)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThan: endDate)
        .get();

    return snapshot.docs.map((doc) {
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
  }

  // 获取指定类别在指定月份的总收入
  Future<double> getTotalIncome(String category, DateTime month) async {
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

    return totalIncome;
  }
}
