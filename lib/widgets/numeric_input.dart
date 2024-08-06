import 'package:accounting/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import '../services/database_service.dart';

class NumericInput extends StatefulWidget {
  final Function(double) onValueChanged;
  final TextEditingController noteController;
  final String selectedCategory;
  final bool isExpense;
  final VoidCallback onAddTransaction;
  final double buttonSize; // 新增变量，用于控制按钮大小
  final double buttonSpacing; // 按钮间距
  final Color buttonColor; // 按钮颜色
  final Color textColor; // 按钮文字颜色

  NumericInput({
    required this.onValueChanged,
    required this.noteController,
    required this.selectedCategory,
    required this.isExpense,
    required this.onAddTransaction,
    this.buttonSize = 60.0, // 默认按钮大小
    this.buttonSpacing = 10.0, // 默认按钮间距
    this.buttonColor = Colors.blue, // 默认按钮颜色
    this.textColor = Colors.white, // 默认按钮文字颜色
  });

  @override
  _NumericInputState createState() => _NumericInputState();
}

class _NumericInputState extends State<NumericInput> {
  double? _currentValue = 0;

  void _updateAmount(double value) {
    setState(() {
      _currentValue = value;
    });
    widget.onValueChanged(value);
  }

  void _addTransaction() async {
    final newTransaction = Transaction(
      id: '',
      category: widget.selectedCategory,
      amount: _currentValue!,
      date: DateTime.now(),
      note: widget.noteController.text,
      isExpense: widget.isExpense,
    );
    await DatabaseService().addTransaction(newTransaction);
    widget.onAddTransaction();
  }

  @override
  Widget build(BuildContext context) {
    var calc = SimpleCalculator(
      value: _currentValue!,
      hideExpression: true,
      hideSurroundingBorder: true,
      autofocus: true,
      onChanged: (key, value, expression) {
        setState(() {
          _currentValue = value ?? 0;
        });
        widget.onValueChanged(_currentValue!);
        if (key == '保存') {
          _addTransaction();
        }
      },
      onTappedDisplay: (value, details) {
        if (kDebugMode) {
          print('$value\t${details.globalPosition}');
        }
      },
      theme: const CalculatorThemeData(
        borderColor: Color.fromARGB(255, 0, 0, 0),
        borderWidth: 5,
        displayColor: Color.fromARGB(255, 255, 255, 255),
        displayStyle:
            TextStyle(fontSize: 80, color: Color.fromARGB(255, 0, 0, 0)),
        expressionColor: Color.fromARGB(255, 254, 255, 255),
        expressionStyle:
            TextStyle(fontSize: 20, color: Color.fromARGB(255, 0, 0, 0)),
        operatorColor: Color.fromARGB(255, 254, 255, 255),
        operatorStyle:
            TextStyle(fontSize: 30, color: Color.fromARGB(255, 0, 0, 0)),
        commandColor: Color.fromARGB(255, 255, 255, 255),
        commandStyle:
            TextStyle(fontSize: 30, color: Color.fromARGB(255, 0, 0, 0)),
        numColor: Color.fromARGB(255, 255, 255, 255),
        numStyle: TextStyle(fontSize: 30, color: Color.fromARGB(255, 0, 0, 0)),
      ),
    );

    return Column(
      children: <Widget>[
        Expanded(
          child: calc,
        ),
      ],
    );
  }
}
