import 'package:flutter/material.dart';

Widget buildRatingStar(double starValue, String shortPreviewText,
    {bool addPadding = true, double size = 24.0, bool expandChildren = false}) {
  Color color = starValue < 2 ? Colors.red : Colors.green;
  List<Widget> values = [];
  for (var e in [1, 2, 3, 4, 5]) {
    if (starValue >= e) {
      values.add(Icon(
        Icons.star_rate,
        color: color,
        size: size,
      ));
    } else if (starValue < e && starValue > e - 1) {
      values.add(Icon(
        Icons.star_half,
        color: color,
        size: size,
      ));
    } else {
      values.add(Icon(
        Icons.star_border,
        color: color,
        size: size,
      ));
    }
  }
  if (addPadding) {
    values.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(shortPreviewText),
    ));
  }
  if (expandChildren) {
    return Row(
        children: values
            .map((e) => Expanded(
                  child: e,
                ))
            .toList());
  }
  return Row(children: values);
}
