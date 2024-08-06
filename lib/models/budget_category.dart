import 'package:flutter/material.dart';

class BudgetCategory {
  final String? id; // 唯一標識符
  final String name;
  final IconData icon;
  final bool isExpense;

  BudgetCategory({
    this.id,
    required this.name,
    required this.icon,
    required this.isExpense,
  });
}
