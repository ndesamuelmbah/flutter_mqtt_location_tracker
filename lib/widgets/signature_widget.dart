import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:flutter_mqtt_location_tracker/utils/toast_messages.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/progress_indicator.dart';

class SignatureWidget extends StatefulWidget {
  final double width;
  final double height;
  final Color? penColor;
  final Color? clearColor;
  final Color? borderColor;
  final Color backgroundColor;
  final FontWeight fontWeight;
  final String? fontFamily;
  final bool showBorder;
  final double borderWidth;
  final double radius;
  final double maxWidth;
  final String? saveLabel;
  final String? clearLabel;
  final double horizontalPadding;
  final double? penStrokeWidth;
  final Color? fontColor;
  final String? signerRole;
  final Future<void> Function(Uint8List) onPressed;
  final Future<void> Function() onSignatureCleared;
  const SignatureWidget(
      {Key? key,
      this.backgroundColor = Colors.transparent,
      this.fontWeight = FontWeight.normal,
      this.fontColor,
      this.fontFamily,
      this.borderColor,
      this.showBorder = true,
      this.borderWidth = 1,
      this.penStrokeWidth = 2,
      this.radius = 10,
      this.maxWidth = 300,
      this.height = 120,
      this.width = 308,
      this.horizontalPadding = 5.0,
      this.saveLabel = 'Save Signature',
      this.clearLabel = 'Clear',
      this.penColor = Colors.blue,
      this.clearColor = Colors.black45,
      this.signerRole,
      required this.onPressed,
      required this.onSignatureCleared})
      : super(key: key);

  @override
  SignatureWidgetState createState() => SignatureWidgetState();
}

class SignatureWidgetState extends State<SignatureWidget> {
  final GlobalKey<SignatureState> _signatureKey = GlobalKey<SignatureState>();
  Uint8List? _signatureBytes;
  late SignatureController _controller;
  bool isLoading = false;
  bool hasSavedSignature = false;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 2,
      penColor: widget.penColor!,
      exportBackgroundColor: Colors.blue.shade50,
    );
  }

  @override
  void dispose() {
    _controller.clear();
    _controller.dispose();
    if (_signatureBytes != null) {
      _signatureBytes = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
      decoration: BoxDecoration(
          //color: Colors.blue.shade100,
          border: Border.all(
            width: 1.5,
            color: widget.borderColor ?? Colors.blue,
          ),
          borderRadius: BorderRadius.circular(widget.radius)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.signerRole != null)
            Center(
              child: Text(
                widget.signerRole!,
                style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontStyle: FontStyle.italic),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
            child: Signature(
              controller: _controller,
              key: _signatureKey,
              height: widget.height,
              width: widget.width,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? const LoadingProgressIndicator()
                  : ActionButton(
                      horizontalPadding: 0,
                      radius: 5,
                      maxWidth: 130,
                      onPressed: _saveSignature,
                      text: widget.saveLabel!,
                      color:
                          !hasSavedSignature ? widget.penColor! : Colors.grey,
                    ),
              const SizedBox(width: 10),
              ActionButton(
                horizontalPadding: 0,
                radius: 5,
                maxWidth: 130,
                onPressed: () async {
                  if (_controller.isNotEmpty) {
                    hasSavedSignature = false;
                    _controller.clear();
                    await widget.onSignatureCleared();
                    if (mounted) {
                      setState(() {});
                    }
                  }
                },
                text: widget.clearLabel!,
                color: widget.clearColor!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveSignature() async {
    if (hasSavedSignature) {
      showSuccessToast('Signature has already been saved');
      return;
    }
    if (_controller.isNotEmpty) {
      isLoading = true;
      setState(() {});
      final bytes = await _controller.toPngBytes();
      if (bytes != null) {
        await widget.onPressed(bytes);
        hasSavedSignature = true;
      } else {
        showErrorToast('Error Saving Signature');
      }
      if (mounted) {
        isLoading = false;
        setState(() {});
      }
    } else {
      showErrorToast('No Signature to Save');
    }
  }
}
