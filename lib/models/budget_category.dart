import 'package:flutter/material.dart';

class BudgetCategory {
  final String name;
  final IconData icon;
  final bool isExpense;

  BudgetCategory({
    required this.name,
    required this.icon,
    required this.isExpense,
  });
}
