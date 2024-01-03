import 'package:flutter/material.dart';

class CustomWebIconButton extends StatelessWidget {
  final Widget icon;
  final Color? color;
  final void Function()? onPressed;
  const CustomWebIconButton(
      {super.key,
      required this.icon,
      required this.onPressed,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: MaterialButton(
        onPressed: onPressed,
        color: color,
        elevation: 6.0,
        minWidth: 50.0,
        height: 50.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
        ),
        child: icon,
      ),
    );
  }
}
