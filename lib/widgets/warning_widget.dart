import 'package:flutter/material.dart';

// ignore: must_be_immutable
class WarningWidget extends StatelessWidget {
  final String warningMessage;
  final String? subtitle;
  final Widget? trailingWidget;
  final Color? iconColor;
  final void Function()? onTap;
  final Widget? leadingWidget;
  Color? tileColor;
  WarningWidget(
      {super.key,
      this.subtitle,
      required this.warningMessage,
      this.trailingWidget,
      this.onTap,
      this.iconColor,
      this.tileColor,
      this.leadingWidget});

  @override
  Widget build(BuildContext context) {
    Widget? subtitleWidget = subtitle == null ? null : Text(subtitle!);
    final color = tileColor ?? Colors.yellow.shade400;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: ListTile(
          tileColor: color,
          minLeadingWidth: 0,
          contentPadding: const EdgeInsets.all(10),
          onTap: onTap,
          leading: leadingWidget ??
              Icon(
                Icons.warning_amber_rounded,
                size: 30,
                color: iconColor ?? Colors.red,
              ),
          title: Text(warningMessage),
          subtitle: subtitleWidget,
          trailing: trailingWidget),
    );
  }
}
