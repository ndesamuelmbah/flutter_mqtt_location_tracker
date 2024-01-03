import 'package:flutter/material.dart';

import '../utils/text_styles.dart';

class TextRow extends StatelessWidget {
  final String label;

  final String value;
  //final TextStyle labelStyle;

  const TextRow({
    Key? key,
    required this.label,
    required this.value,
    //required this.labelStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: captionStyle.copyWith(fontSize: 16, color: Colors.black),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 3,
            child: Text(
              '${value.isEmpty ? 0 : value}',
              style: captionStyle.copyWith(
                  fontSize: 14, color: Colors.black54, fontFamily: 'Roboto'),
            ),
          ),
        ],
      ),
    );
  }
}
