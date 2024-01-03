import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/models/play_njangi.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/progress_indicator.dart';
import 'package:flutter_mqtt_location_tracker/widgets/warning_widget.dart';

class PlayNjangiListItem extends StatefulWidget {
  final PlayNjangi playNjangi;
  final bool isAdmin;

  const PlayNjangiListItem(
      {super.key, required this.playNjangi, required this.isAdmin});

  @override
  PlayNjangiListItemState createState() => PlayNjangiListItemState();
}

class PlayNjangiListItemState extends State<PlayNjangiListItem> {
  bool showImage = false;
  bool isLoading = false;
  bool hasMismatchedAmount = false;
  String? warningMessage;
  String? warningSubmessage;

  final _formKey = GlobalKey<FormState>();
  final _sharesController = TextEditingController();
  final _njangiController = TextEditingController();
  final _adminCommentController = TextEditingController();

  @override
  void initState() {
    //if(!widget.isAdmin){
    if (widget.playNjangi.adminComment != null) {
      _adminCommentController.text = widget.playNjangi.adminComment!;
    } else {
      _adminCommentController.text = 'Details are correct.';
    }
    if (widget.playNjangi.njangiAmount > 0) {
      _njangiController.text =
          numberFormat.format(widget.playNjangi.njangiAmount);
    }
    if (widget.playNjangi.sharesAmount > 0) {
      _sharesController.text =
          numberFormat.format(widget.playNjangi.sharesAmount);
    }
    //}
    super.initState();
  }

  @override
  void dispose() {
    _sharesController.dispose();
    _adminCommentController.dispose();
    _njangiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'XAF ${numberFormat.format(widget.playNjangi.enteredAmount)} on ${shortDateFormat.format(widget.playNjangi.playDate)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 8),
          Text(
            widget.playNjangi.beneficiaryDetails,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          if (widget.isAdmin)
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: containerDecoration,
                    child: TextFormField(
                      controller: _njangiController,
                      textInputAction: TextInputAction.next,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: false, signed: false),
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Amount for Njangi',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'XAF ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      validator: (value) {
                        value = (value ?? '').replaceAll(',', '').trim();
                        if (value.isEmpty) {
                          return 'Enter the amount of money for Njangi';
                        }
                        double? amount = double.tryParse(value);
                        if (amount == null) {
                          return 'Write only numbers, and/or commars';
                        }
                        if (amount < 5000) {
                          return 'Njangi amount must be at least XAF 5,000.00';
                        }
                        if (amount > 200000) {
                          return 'Max Nangi Amount is XAF 200,000.00';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: containerDecoration,
                    //width: 120,
                    child: TextFormField(
                      controller: _sharesController,
                      textInputAction: TextInputAction.next,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: false, signed: false),
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Amount for Shares',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'XAF ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      validator: (value) {
                        value = (value ?? '').replaceAll(',', '').trim();
                        if (value.isEmpty) {
                          return 'Enter the amount of money from shares';
                        }
                        double? amount = double.tryParse(value);
                        if (amount == null) {
                          return 'Write only numbers, and/or commars';
                        }
                        double numberOfShares = amount / 20000;
                        if (numberOfShares != numberOfShares.toInt()) {
                          return 'Enter a multiple of XAF 20,000';
                        }
                        if (amount > 200000) {
                          return 'Shares Amount must be less than XAF 200,000';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: containerDecoration,
                    //width: 120,
                    child: TextFormField(
                      controller: _adminCommentController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.name,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Any note about this?',
                        labelText: 'eg The amount you entered was correct',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                      ),
                      validator: (value) {
                        value = (value ?? '').replaceAll(',', '').trim();
                        if (value.isEmpty) {
                          return 'Enter a Comment about this';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (warningMessage != null) ...[
                    const SizedBox(height: 10),
                    WarningWidget(
                      warningMessage: warningMessage!,
                      subtitle: warningSubmessage,
                    )
                  ],
                  const SizedBox(height: 10),
                  isLoading
                      ? const LoadingProgressIndicator()
                      : ActionButton(
                          text: 'Submit',
                          color: Colors.blue.shade900,
                          maxWidth: mobileScreenBox.maxWidth,
                          radius: 5,
                          horizontalPadding: 0,
                          onPressed: () async {
                            if (!isLoading) {
                              if (_formKey.currentState!.validate()) {
                                warningMessage = null;
                                final njangiAmount =
                                    getNumberFromText(_njangiController.text);
                                final sharesAmount =
                                    getNumberFromText(_sharesController.text);
                                final diff = sharesAmount +
                                    njangiAmount -
                                    widget.playNjangi.enteredAmount;
                                if (!hasMismatchedAmount && diff.abs() > 3000) {
                                  warningMessage = 'Amounts do not match';
                                  warningSubmessage =
                                      'If you believe the different of XAF ${numberFormat.format(diff.abs())} is correct, then press the Submit button again to save it';
                                  hasMismatchedAmount = true;
                                  setState(() {});
                                  return;
                                }
                                final updates = {
                                  'njangiAmount': njangiAmount,
                                  'sharesAmount': sharesAmount,
                                  'adminComment':
                                      _adminCommentController.text.trim()
                                };
                                isLoading = true;
                                setState(() {});
                                await FirestoreDB.njangiRef
                                    .doc(widget.playNjangi.documentId)
                                    .update(updates);
                                isLoading = false;
                                setState(() {});
                              }
                            }
                          }),
                  const SizedBox(height: 28)
                ],
              ),
            ),
          ActionButton(
              text: showImage ? 'Hide Payment Image' : 'Show Payment Image',
              color: Colors.blue.shade900,
              maxWidth: mobileScreenBox.maxWidth,
              radius: 5,
              //showBorder: false,
              horizontalPadding: 0,
              //fontWeight: FontWeight.bold,
              onPressed: () {
                setState(() {
                  showImage = !showImage;
                });
              }),
          if (widget.playNjangi.adminComment != null) ...[
            const SizedBox(
              height: 10,
            ),
            Text(
              'Admin Comment: ${widget.playNjangi.adminComment}',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
          if (showImage) ...[
            const SizedBox(
              height: 10,
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: Center(
                child: Image.network(
                  widget.playNjangi.imageUrl,
                  fit: BoxFit.fitHeight,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child; // Return the image if it's already loaded
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  double getNumberFromText(String? text) {
    text = (text ?? '').replaceAll(',', '').trim();
    if (text.isEmpty) {
      return 0;
    }
    return double.parse(text);
  }
}
