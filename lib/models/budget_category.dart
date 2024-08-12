import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'budget_category.g.dart';

@HiveType(typeId: 0)
class BudgetCategory {
  @HiveField(0)
  final String? id; // 唯一標識符

  @HiveField(1)
  final String name;

  @HiveField(2)
  final IconData icon;

  @HiveField(3)
  final bool isExpense;

  BudgetCategory({
    this.id,
    required this.name,
    required this.icon,
    required this.isExpense,
  });
}
