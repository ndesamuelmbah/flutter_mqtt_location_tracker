import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' if (dart.library.html) 'dart:html'
    as html;

class TermsAndConditionsCheckBox extends StatefulWidget {
  final String url;
  final String? urlText;
  final String? textPrefix;
  final Decoration? decoration;
  final Function(bool value) onChanged;

  const TermsAndConditionsCheckBox(
      {super.key,
      required this.onChanged,
      required this.url,
      this.decoration,
      this.urlText = 'Terms and Conditions',
      this.textPrefix = 'By continuing, you are agreeing to the'});

  @override
  TermsAndConditionsCheckBoxState createState() =>
      TermsAndConditionsCheckBoxState();
}

class TermsAndConditionsCheckBoxState
    extends State<TermsAndConditionsCheckBox> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.decoration,
      child: ListTile(
        horizontalTitleGap: 16,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8),
        minLeadingWidth: 0,
        leading: Checkbox(
          value: _isChecked,
          onChanged: (value) {
            setState(() {
              _isChecked = value!;
              widget.onChanged(_isChecked);
            });
          },
        ),
        title: GestureDetector(
          onTap: () async {
            // Launch the url using universal_html package
            html.window.open(widget.url, 'Terms and Conditions', '_blank');
          },
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(text: '${widget.textPrefix} '),
                TextSpan(
                  text: widget.urlText,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
