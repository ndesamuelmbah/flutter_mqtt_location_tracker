import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final TextEditingController controller;
  final void Function(DateTime?) onDateSelected;
  final String? textLabel;
  final String? dateFormat;
  final Decoration? backgroundDecoration;
  const DatePickerWidget({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.controller,
    required this.onDateSelected,
    this.textLabel = 'Click To Select Date',
    this.backgroundDecoration,
    this.dateFormat = 'yyyy-MM-dd',
  });

  @override
  Widget build(BuildContext context) {
    String controllerText = controller.text.trim();
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 5)),
          firstDate: DateTime.now().add(const Duration(days: 5)),
          lastDate: DateTime.now().add(const Duration(days: 365 + 17)),
        );
        onDateSelected(date);
        // if (date != null) {
        //   controller.text = DateFormat(dateFormat).format(date);
        //   print(controller.text);
        // }
      },
      child: Container(
          decoration: backgroundDecoration ?? containerDecoration,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                textLabel ?? '',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                controllerText.isEmpty
                    ? 'Tap to Select a Date'
                    : controllerText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          )),
    );
  }
}
