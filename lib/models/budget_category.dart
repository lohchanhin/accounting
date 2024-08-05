import 'package:flutter/material.dart';

class BudgetCategory {
  final String name;
  final IconData icon;
  final double? budget;
  final bool isExpense;

  BudgetCategory({
    required this.name,
    required this.icon,
    this.budget,
    required this.isExpense,
  });
}
