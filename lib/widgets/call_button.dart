import 'package:flutter_mqtt_location_tracker/widgets/trigger_phone_call.dart';
import 'package:flutter/material.dart';

class CallButton extends StatelessWidget {
  final String phoneNumber;
  final String userName;
  final Color color;
  final String message;
  final Function()? onPressed;
  const CallButton(
      {Key? key,
      required this.phoneNumber,
      required this.userName,
      this.onPressed,
      this.message =
          "I am writing about your recent Order on Duka Food App. I would love to ...",
      required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(1.0), // borde width
        decoration: BoxDecoration(
            shape: BoxShape.circle, border: Border.all(color: color, width: 1)),
        child: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: IconButton(
              onPressed: onPressed ??
                  () async {
                    triggerPhoneCall(context, phoneNumber, userName, message);
                  },
              icon: Icon(
                Icons.call,
                color: color,
              )),
        ));
  }
}
