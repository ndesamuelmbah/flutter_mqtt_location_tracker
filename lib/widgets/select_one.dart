import 'package:flutter/material.dart';

class SelectOneOf extends StatelessWidget {
  final String strings;
  final void Function(String) onObjectSelected;
  final String sep;
  final String? selectedValue;
  final WrapAlignment? alignment;

  const SelectOneOf(
      {super.key,
      required this.strings,
      required this.onObjectSelected,
      required this.selectedValue,
      this.sep = ',',
      this.alignment});

  @override
  Widget build(BuildContext context) {
    final List<String> options = strings.split(sep);

    return Wrap(
      alignment: alignment ?? WrapAlignment.start,
      children: options.map((str) {
        return GestureDetector(
          onTap: () {
            onObjectSelected(str);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: selectedValue == str
                    ? Colors.green.shade200
                    : Colors.grey.shade200,
                border: Border.all(
                  color: selectedValue == str ? Colors.green : Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                str,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
