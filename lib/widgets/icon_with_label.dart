import 'package:flutter/material.dart';

class IconWithLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final void Function() onPressed;
  final Color? color;
  final Color? iconColor;
  final double? size;
  final bool? shouldFirstPop;

  const IconWithLabel(this.icon, this.label, this.onPressed,
      {Key? key,
      this.size = 30,
      this.color,
      this.iconColor,
      this.shouldFirstPop = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key(label),
      children: [
        CircleAvatar(
            backgroundColor: color,
            radius: size,
            child: IconButton(
                onPressed: () {
                  if (shouldFirstPop!) {
                    Navigator.of(context).pop();
                  }
                  onPressed();
                },
                icon: Icon(icon, size: size, color: iconColor))),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black))
      ],
    );
  }
}
