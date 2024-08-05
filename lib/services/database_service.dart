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
      'date': budget.date,
    });
  }

  // 更新已有的预算记录
  Future<void> updateBudget(Budget budget) async {
    await _db.collection('budgets').doc(budget.id).update({
      'category': budget.category,
      'amount': budget.amount,
      'spent': budget.spent,
      'date': budget.date,
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
        date: (doc['date'] as Timestamp).toDate(),
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

  // 获取指定类型的所有类别（支出或收入）
  Future<List<BudgetCategory>> getCategories(bool isExpense) async {
    QuerySnapshot snapshot = await _db
        .collection('budgetCategories')
        .where('isExpense', isEqualTo: isExpense)
        .get();
    return snapshot.docs.map((doc) {
      return BudgetCategory(
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
      'isExpense': category.isExpense, // 确保在添加时也存储支出或收入的标志
    });
  }

  // 获取指定类型的所有预算类别（支出或收入）
  Future<List<BudgetCategory>> getBudgetCategories(bool isExpense) async {
    QuerySnapshot snapshot = await _db
        .collection('budgetCategories')
        .where('isExpense', isEqualTo: isExpense)
        .get();
    return snapshot.docs.map((doc) {
      return BudgetCategory(
        name: doc['name'],
        icon: IconData(doc['icon'], fontFamily: 'MaterialIcons'),
        isExpense: doc['isExpense'],
      );
    }).toList();
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

  // 更新已有的预算类别记录
  Future<void> updateBudgetCategory(BudgetCategory category) async {
    QuerySnapshot snapshot = await _db
        .collection('budgetCategories')
        .where('name', isEqualTo: category.name)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await _db
          .collection('budgetCategories')
          .doc(snapshot.docs.first.id)
          .update({
        'icon': category.icon.codePoint,
        'isExpense': category.isExpense,
      });
    }
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
        date: (doc['date'] as Timestamp).toDate(),
      );
    }).toList();
  }
}
