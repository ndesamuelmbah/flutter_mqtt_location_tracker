import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mqtt_location_tracker/utils/text_styles.dart';

class CustomTextField extends StatelessWidget {
  final bool isDense;
  final String label;
  final TextEditingController? controller;
  final Function(String?)? onSave;
  final Function(String?)? onChange;
  final Function()? onDone;
  final bool isFinalField;
  final FocusNode? focusNode;
  final GlobalKey? fieldKey;
  final int maxChars;
  final int? maxLines;
  final int? minLines;
  final bool? autofocus;
  final InputDecoration? decoration;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final TextInputType? textInputType;
  final String? initialValue;
  final bool readOnly;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    Key? key,
    this.isDense = false,
    required this.label,
    this.decoration,
    this.fieldKey,
    this.controller,
    this.onDone,
    this.focusNode,
    this.isFinalField = false,
    this.maxChars = 256,
    this.maxLines,
    this.onSave,
    this.minLines,
    this.validator,
    this.inputFormatters,
    this.textInputType,
    this.onChange,
    this.initialValue,
    this.readOnly = false,
    this.autofocus,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: captionStyle,
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: fieldKey,
          initialValue: initialValue,
          keyboardType: textInputType,
          controller: controller,
          onChanged: onChange,
          focusNode: focusNode,
          onSaved: onSave,
          maxLines: maxLines,
          readOnly: readOnly,
          autofocus: autofocus ?? false,
          textCapitalization: textCapitalization,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onEditingComplete: onDone,
          textInputAction:
              isFinalField ? TextInputAction.done : TextInputAction.next,
          validator: validator,
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxChars),
            ...(inputFormatters ?? []),
          ],
          decoration: decoration ??
              InputDecoration(
                  isDense: isDense,
                  hintText: label,
                  border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
