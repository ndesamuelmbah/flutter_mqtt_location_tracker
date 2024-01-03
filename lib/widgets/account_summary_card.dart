import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';

class AccountSummaryCard extends StatelessWidget {
  final String userName;
  final double accountBalance;
  final double loanBalance;
  final DateTime loanDueDate;
  final DateTime nextNjangiDate;

  const AccountSummaryCard({
    super.key,
    required this.userName,
    required this.accountBalance,
    required this.loanBalance,
    required this.loanDueDate,
    required this.nextNjangiDate,
  });

  String formatCurrency(double amount) {
    // Implement your currency formatting logic here
    return amount.toStringAsFixed(2);
  }

  String formatDateTime(DateTime dateTime) {
    // Implement your date/time formatting logic here
    return dateTime.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      //margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: containerDecoration,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Welcome $userName',
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Here is a snapshot of your account today:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Account Balance: XAF ${formatCurrency(accountBalance)}',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Loan Balance: XAF ${formatCurrency(loanBalance)}',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Loan Due Date: ${formatDateTime(loanDueDate)}',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Next Njangi Date: ${formatDateTime(nextNjangiDate)}',
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
