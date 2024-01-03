import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/utils/palette.dart';

const TextStyle primaryColoredHeadingStyle = TextStyle(
    fontSize: 26, fontWeight: FontWeight.bold, color: Palette.primary);

const TextStyle body2Style = TextStyle(
    fontSize: 21, fontWeight: FontWeight.w400, color: Palette.textColor);

const TextStyle heading1Style = TextStyle(
  fontSize: 34,
  fontWeight: FontWeight.w400,
);

const TextStyle heading2Style = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w600,
);

const TextStyle heading3Style = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
);

const TextStyle headlineStyle = TextStyle(
  fontSize: 30,
  fontWeight: FontWeight.w700,
);

const TextStyle bodyStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Palette.textColor,
);

const TextStyle appBarStyle = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w500, color: Palette.primary);

const TextStyle subheadingStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w400, color: Palette.textColor);

const TextStyle captionStyle = TextStyle(
    fontSize: 13, fontWeight: FontWeight.bold, color: Palette.textColor);

const TextStyle hyperlinkStyle = TextStyle(
  decoration: TextDecoration.underline,
  fontWeight: FontWeight.w400,
);

const TextStyle hintStyle = TextStyle(
  fontWeight: FontWeight.w400,
  fontSize: 16,
  letterSpacing: 0.15,
  color: Palette.textColor,
);
ButtonStyle buttonStyle(
    {Color? color, Size minimumSize = const Size(100, 38)}) {
  return ElevatedButton.styleFrom(
      minimumSize: minimumSize,
      padding: const EdgeInsets.symmetric(vertical: 10),
      backgroundColor: color ?? Colors.pink.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      side: BorderSide(color: color ?? const Color(0xFF000000)));
}
