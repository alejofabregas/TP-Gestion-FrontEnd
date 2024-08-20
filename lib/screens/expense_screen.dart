import 'package:flutter/material.dart';

class ExpenseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Screen'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Expense Screen!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
