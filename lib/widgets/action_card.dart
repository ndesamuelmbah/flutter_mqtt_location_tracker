import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String? subTitle;
  final Padding? padding;
  final Color? color;
  final void Function()? onPressed;

  const ActionCard(
      {super.key,
      required this.title,
      this.subTitle,
      this.padding,
      this.onPressed,
      this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: color,
      child: ListTile(
        onTap: onPressed,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        subtitle: subTitle == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  subTitle!,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
      ),
    );
  }
}
