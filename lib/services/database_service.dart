import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../models/transaction.dart' as trans;
import '../models/budget_category.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addBudget(Budget budget) async {
    await _db.collection('budgets').add({
      'category': budget.category,
      'amount': budget.amount,
      'spent': budget.spent,
    });
  }

  Future<void> updateBudget(Budget budget) async {
    await _db.collection('budgets').doc(budget.id).update({
      'category': budget.category,
      'amount': budget.amount,
      'spent': budget.spent,
    });
  }

  Future<List<Budget>> getBudgets() async {
    QuerySnapshot snapshot = await _db.collection('budgets').get();
    return snapshot.docs.map((doc) {
      return Budget(
        id: doc.id,
        category: doc['category'],
        amount: doc['amount'],
        spent: doc['spent'],
      );
    }).toList();
  }

  Future<void> addTransaction(trans.Transaction transaction) async {
    await _db.collection('transactions').add({
      'category': transaction.category,
      'amount': transaction.amount,
      'date': transaction.date,
      'note': transaction.note,
      'receiptUrl': transaction.receiptUrl,
    });

    // Update the budget spent
    DocumentSnapshot budgetSnapshot =
        await _db.collection('budgets').doc(transaction.category).get();
    if (budgetSnapshot.exists) {
      double newSpent = budgetSnapshot['spent'] + transaction.amount;
      await _db.collection('budgets').doc(transaction.category).update({
        'spent': newSpent,
      });
    }
  }

  Future<List<String>> getCategories(bool isExpense) async {
    QuerySnapshot snapshot = await _db
        .collection('categories')
        .where('type', isEqualTo: isExpense ? 'expense' : 'income')
        .get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Future<void> addBudgetCategory(BudgetCategory category) async {
    await _db.collection('budgetCategories').add({
      'name': category.name,
      'icon': category.icon.codePoint,
      'budget': category.budget,
      'isExpense': category.isExpense, // 確保在添加時也存儲支出或收入的標誌
    });
  }

  Future<List<BudgetCategory>> getBudgetCategories(bool isExpense) async {
    QuerySnapshot snapshot = await _db
        .collection('budgetCategories')
        .where('isExpense', isEqualTo: isExpense)
        .get();
    return snapshot.docs.map((doc) {
      return BudgetCategory(
        name: doc['name'],
        icon: IconData(doc['icon'], fontFamily: 'MaterialIcons'),
        budget: doc['budget'],
        isExpense: doc['isExpense'], // 修正為使用正確的字段名稱
      );
    }).toList();
  }
}
