import 'package:flutter_mqtt_location_tracker/widgets/call_button.dart';
import 'package:flutter/material.dart';

class PaymentNotAvailableWarning extends StatelessWidget {
  final String userName;
  final String phoneNumber;
  final String warningMessage;
  final String? subtitle;
  final bool showCallButton;
  const PaymentNotAvailableWarning(
      {Key? key,
      this.subtitle,
      required this.userName,
      required this.phoneNumber,
      required this.warningMessage,
      this.showCallButton = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? subtitleWidget = subtitle == null ? null : Text(subtitle!);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: ListTile(
        tileColor: Colors.yellow.shade400,
        minLeadingWidth: 0,
        contentPadding: const EdgeInsets.all(10),
        leading: const Icon(
          Icons.warning_amber_rounded,
          size: 30,
          color: Colors.red,
        ),
        title: Text(warningMessage),
        subtitle: subtitleWidget,
        trailing: showCallButton
            ? CallButton(
                color: Colors.green.shade900,
                userName: userName,
                phoneNumber: phoneNumber,
              )
            : null,
      ),
    );
  }
}
