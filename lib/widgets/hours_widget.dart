import 'package:flutter/material.dart';

class HoursWidget extends StatelessWidget {
  final bool isOnMobile;
  const HoursWidget({super.key, required this.isOnMobile});

  @override
  Widget build(BuildContext context) {
    double fontSize = isOnMobile ? 16 : 18;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saturdays and Sundays',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: Colors.pink),
        ),
        SizedBox(
          height: isOnMobile ? 5 : 10,
        ),
        Text(
          '7:00 AM to 8:00 PM',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: Colors.pink),
        ),
      ],
    );
  }
}
