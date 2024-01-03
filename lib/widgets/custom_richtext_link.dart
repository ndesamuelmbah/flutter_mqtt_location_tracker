import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomRichTextLink extends StatelessWidget {
  final Function onTextLinkClicked;
  final String textPrefix;
  final String linkText;

  const CustomRichTextLink({
    super.key,
    required this.onTextLinkClicked,
    required this.textPrefix,
    required this.linkText,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: textPrefix,
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
              text: linkText,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  onTextLinkClicked();
                }),
        ],
      ),
    );
  }
}
