import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = "";
  String result = "0";

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        input = "";
        result = "0";
      } else if (value == "=") {
        try {
          result = _calculateResult(input);
        } catch (e) {
          result = "Error";
        }
      } else {
        input += value;
      }
    });
  }

  /// ✅ **Evaluates the Mathematical Expression**
  String _calculateResult(String expression) {
    try {
      expression = expression.replaceAll('×', '*').replaceAll('÷', '/');
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      return eval.toString();
    } catch (e) {
      return "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Calculator"),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    input,
                    style: TextStyle(fontSize: 36, color: Colors.white70),
                  ),
                  Text(
                    result,
                    style: TextStyle(fontSize: 48, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.white24),
          _buildButtons(),
        ],
      ),
    );
  }

  /// ✅ **Creates the Button Grid**
  Widget _buildButtons() {
    final buttons = [
      ["7", "8", "9", "÷"],
      ["4", "5", "6", "×"],
      ["1", "2", "3", "-"],
      ["C", "0", "=", "+"]
    ];

    return Column(
      children: buttons
          .map(
            (row) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((btn) => _button(btn)).toList(),
        ),
      )
          .toList(),
    );
  }

  /// ✅ **Creates Individual Buttons**
  Widget _button(String value) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(24),
          backgroundColor: _getButtonColor(value),
        ),
        onPressed: () => _onButtonPressed(value),
        child: Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// ✅ **Color Styling for Buttons**
  Color _getButtonColor(String value) {
    if (value == "C") return Colors.redAccent;
    if (value == "=") return Colors.greenAccent;
    if (["÷", "×", "-", "+"].contains(value)) return Colors.orangeAccent;
    return Colors.grey[800]!;
  }
}
