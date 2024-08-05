// target_selection.dart
import 'package:flutter/material.dart';

class TargetSelection extends StatelessWidget {
  final String category;
  final IconData icon;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const TargetSelection({
    Key? key,
    required this.category,
    required this.icon,
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
        ],
      ),
      selected: selectedCategory == category,
      onSelected: (selected) {
        onCategorySelected(category);
      },
      selectedColor: Colors.blue,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: selectedCategory == category ? Colors.white : Colors.black,
      ),
    );
  }
}
