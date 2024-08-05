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
        Text(
          'Amount: \$${amount.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
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
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: widget.onAddTransaction,
          child: Text('Add Transaction'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}
