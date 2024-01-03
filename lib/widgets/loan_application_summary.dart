import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';

class LoanApplicationSummary extends StatelessWidget {
  final String displayName;
  final double loanAmount;
  final String loanReason;
  final DateTime proposedPaymentDate;
  final String title;

  const LoanApplicationSummary(
      {super.key,
      required this.title,
      required this.displayName,
      required this.loanAmount,
      required this.loanReason,
      required this.proposedPaymentDate});

  @override
  Widget build(BuildContext context) {
    final dateformat = DateFormat('yyyy-MM-dd');
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            title,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline),
          ),
        ),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.black,
            ),
            children: [
              getTextSpan(
                  'Today, ${DateFormat('EEEE, MMM dd, yyyy, HH:mm a').format(DateTime.now())}, I  ',
                  isNormalDescription: true),
              getTextSpan(
                '$displayName,',
              ),
              getTextSpan(
                  ' being in sound mind and body, am applying for a loan from Ngyenmuwah Dynamic Youths in the amount of ',
                  isNormalDescription: true),
              getTextSpan(
                ' XAF ${numberFormat.format(loanAmount)}. ',
              ),
              getTextSpan('My reason for applying for this loan is\n',
                  isNormalDescription: true),
              getTextSpan('$loanReason\n', underline: false),
              getTextSpan('I would love for this loan to be approved by ',
                  isNormalDescription: true),
              getTextSpan('${dateformat.format(proposedPaymentDate)}.'),
              getTextSpan(
                  ' If Approved, I promise that I will be able to pay the loan by ',
                  isNormalDescription: true),
              getTextSpan(dateformat.format(proposedPaymentDate)),
              getTextSpan('.', isNormalDescription: true),
            ],
          ),
        )
      ]),
    );
  }

  TextSpan getTextSpan(String text,
      {bool isNormalDescription = false, bool underline = true}) {
    if (isNormalDescription) {
      return TextSpan(
        text: text,
        style: const TextStyle(fontSize: 16, wordSpacing: 2.0),
      );
    }
    return TextSpan(
      text: text,
      style: TextStyle(
          decoration: underline ? TextDecoration.underline : null,
          fontSize: 16,
          wordSpacing: 2.0,
          fontWeight: FontWeight.bold),
    );
  }
}
