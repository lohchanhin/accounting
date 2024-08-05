import 'package:flutter/material.dart';

class NumericInput extends StatefulWidget {
  final Function(double) onValueChanged;
  final TextEditingController noteController;
  final VoidCallback onAddTransaction;

  NumericInput({
    required this.onValueChanged,
    required this.noteController,
    required this.onAddTransaction,
  });

  @override
  _NumericInputState createState() => _NumericInputState();
}

class _NumericInputState extends State<NumericInput> {
  double amount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GridView.builder(
          shrinkWrap: true,
          itemCount: 12,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2,
          ),
          itemBuilder: (context, index) {
            if (index < 9) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    amount = amount * 10 + (index + 1);
                  });
                  widget.onValueChanged(amount);
                },
                child: Text('${index + 1}'),
              );
            } else if (index == 9) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    amount = 0.0;
                  });
                  widget.onValueChanged(amount);
                },
                child: Text('C'),
              );
            } else if (index == 10) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    amount = amount * 10;
                  });
                  widget.onValueChanged(amount);
                },
                child: Text('0'),
              );
            } else {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    amount = amount / 10;
                  });
                  widget.onValueChanged(amount);
                },
                child: Text('.'),
              );
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: widget.noteController,
            decoration: InputDecoration(
              labelText: 'Note',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: widget.onAddTransaction,
          child: Text('Add Transaction'),
        ),
      ],
    );
  }
}
