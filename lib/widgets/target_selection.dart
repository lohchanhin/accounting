import 'package:flutter/material.dart';

class TargetSelection extends StatelessWidget {
  final String category;
  final IconData icon;
  final double? budget;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const TargetSelection({
    Key? key,
    required this.category,
    required this.icon,
    this.budget,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          SizedBox(width: 4),
          Text(category),
          if (budget != null) SizedBox(width: 4),
          if (budget != null) Text('(\$${budget!.toStringAsFixed(2)})'),
        ],
      ),
      selected: selectedCategory == category,
      onSelected: (selected) {
        onCategorySelected(category);
      },
    );
  }
}
