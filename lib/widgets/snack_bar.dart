import 'package:flutter/material.dart';

void showSnackBar(String message, BuildContext context,
    {Duration duration = const Duration(milliseconds: 4500),
    Color backgroundColor = Colors.black,
    Color? textColor,
    Widget? content}) {
  final messengerState = ScaffoldMessenger.of(context);
  messengerState.clearSnackBars();
  messengerState.showSnackBar(
    SnackBar(
      content: content ??
          Text(
            message,
            style: TextStyle(
              color: textColor,
            ),
          ),
      behavior: SnackBarBehavior.floating,
      duration: duration,
      backgroundColor: backgroundColor,
    ),
  );
}
