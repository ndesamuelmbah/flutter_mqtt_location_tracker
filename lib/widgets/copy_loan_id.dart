import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mqtt_location_tracker/utils/toast_messages.dart';

class CopyLoanIdWidget extends StatelessWidget {
  final String loanId;
  const CopyLoanIdWidget({super.key, required this.loanId});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        RichText(
          text: TextSpan(
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
              children: [
                const TextSpan(
                  text: 'Loan ID: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' $loanId',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                )
              ]),
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: loanId));
            showSuccessToast('Loan ID copied to clipboard.');
          },
        ),
      ],
    );
  }
}
