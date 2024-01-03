import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/firebase_auth/firebase_auth_bloc.dart';
import 'package:flutter_mqtt_location_tracker/models/loan.dart';
import 'package:flutter_mqtt_location_tracker/screens/manage_profile_images.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_center_container.dart';
import 'package:flutter_mqtt_location_tracker/widgets/progress_indicator.dart';
import 'package:flutter_mqtt_location_tracker/widgets/select_one.dart';
import 'package:flutter_mqtt_location_tracker/widgets/signature_widget.dart';
import 'package:flutter_mqtt_location_tracker/widgets/terms_and_conditions.dart';
import 'package:flutter_mqtt_location_tracker/widgets/warning_widget.dart';

class PlayNjangiWidget extends StatefulWidget {
  const PlayNjangiWidget({super.key});

  @override
  PlayNjangiWidgetState createState() => PlayNjangiWidgetState();
}

class PlayNjangiWidgetState extends State<PlayNjangiWidget> {
  String? warningMessage;
  bool isLoading = false;
  bool isSubmitting = false;
  bool hasAgreedToTerms = false;
  Loan? loan;
  String? screenshotUrl;
  String? submissionType;

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _beneficiaryInfoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUser = getFirebaseAuthUser(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Center(child: Text('Play your Njangi')),
      ),
      body: DefaultCenterContainer(
        isColumn: false,
        children: [
          const Card(
            //color: Colors.blue.shade50,
            elevation: 4,
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              title: Text(
                'How to Submit your Njangi payment',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  'Attach a screenshot of your payment, then enter the amount and add beneficiary details like the beneficiary name. If you are playing for multiple people, make sure to write the name and amount that each person is playing.',
                  //textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  //color: Colors.blue.shade50,
                  elevation: 4,
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const PlayNjangiWidget()));
                    },
                    contentPadding: const EdgeInsets.all(10),
                    title: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Is this payment for loan, njangi or both',
                        //textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    subtitle: SelectOneOf(
                      alignment: WrapAlignment.center,
                      strings: 'Loan and Njangi, Loan, Njangi',
                      sep: ', ',
                      selectedValue: submissionType,
                      onObjectSelected: (str) {
                        submissionType = str;
                        setState(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  decoration: containerDecoration,
                  child: TextFormField(
                    controller: _amountController,
                    textInputAction: TextInputAction.next,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: false, signed: false),
                    maxLines: 1,
                    decoration: const InputDecoration(
                      hintText: 'Amount of money played',
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
                        return 'Enter the amount of money in the image';
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
                const SizedBox(
                  height: 16,
                ),
                Container(
                  decoration: containerDecoration,
                  child: TextFormField(
                    controller: _beneficiaryInfoController,
                    textInputAction: TextInputAction.done,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Beneficiary Information',
                      labelText:
                          'Eg Njangi for 10,000 frs and shares for 30,000 frs',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    validator: (value) {
                      value = (value ?? '').trim();
                      if (value.isEmpty) {
                        return 'Enter Beneficiary Info lile Name of Beneficiary';
                      }
                      if (value.length < 7) {
                        return 'Value is too short';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                UploadMediaItem(
                  heading: 'Upload Picture Proof of Payment',
                  onImageSaved: (downloadUrl) async {
                    if (downloadUrl != null) {
                      screenshotUrl = downloadUrl;
                      setState(() {});
                    }
                  },
                  buttonText: 'Upload Picture',
                  imageUrl: screenshotUrl,
                ),
                const SizedBox(
                  height: 20,
                ),
                if (warningMessage.isNotNullAndNotEmpty) ...[
                  WarningWidget(warningMessage: warningMessage!),
                  const SizedBox(
                    height: 20,
                  ),
                ],
                isSubmitting
                    ? const LoadingProgressIndicator()
                    : ActionButton(
                        text: 'Submit',
                        maxWidth: mobileScreenBox.maxWidth,
                        color: Colors.blue.shade900,
                        radius: 5,
                        onPressed: () async {
                          if (isSubmitting) {
                            return;
                          }
                          if (submissionType == null) {
                            warningMessage =
                                'Please Choose between Loan, Njangi, or Loan and Njangi';
                            setState(() {});
                            return;
                          }
                          if (screenshotUrl == null) {
                            warningMessage = 'Please Add An Image';
                            setState(() {});
                            return;
                          } else if (_formKey.currentState!.validate()) {
                            isSubmitting = true;
                            setState(() {});
                            final playDate = DateTime.now()
                                .toUtc()
                                .add(const Duration(hours: 1));
                            await FirestoreDB.njangiRef
                                .doc(getChatMessageId(
                                    playDate.millisecondsSinceEpoch))
                                .set({
                              'playDate': playDate.toIso8601String(),
                              'enteredAmount': double.parse(_amountController
                                  .text
                                  .replaceAll(',', '')
                                  .trim()),
                              'imageUrl': screenshotUrl,
                              'submittedByUid': currentUser.uid,
                              'playedBy': currentUser.displayName,
                              'beneficiaryDetails':
                                  _beneficiaryInfoController.text.trim(),
                              'njangiType': submissionType,
                            });
                            getIt<GeneralBox>()
                                .put(Keys.lastNjangiPlayDate, playDate);

                            getIt<GeneralBox>()
                                .put(Keys.njangiType, submissionType);
                            if (mounted) {
                              isSubmitting = false;
                              setState(() {});
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Center(
                                      child: Container(
                                        constraints: mobileScreenBox.copyWith(
                                            maxWidth: 400),
                                        child: const Padding(
                                          padding: EdgeInsets.all(18.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'You have submitted your Njangi',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                'Thanks for submitting your njangi. You can close this tab and exit this page.',
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20.0),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Close'),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        }),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Card(
            color: Colors.blue.shade50,
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                onTap: () async {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PlayNjangiWidget()));
                },
                contentPadding: const EdgeInsets.all(10),
                title: const Text(
                  'Tap here to load Njangi history',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Attach a screenshot of your payment, then enter the amount and add beneficiary details like the beneficiary name. If you are playing for multiple people, make sure to write the name and amount that each person is playing.',
                    //textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading) const LoadingProgressIndicator(),
          const SizedBox(height: 16.0),
          if (loan != null) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Loan Summary',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline),
                ),
                ListTile(
                  title: Text('Applied by ${loan!.ownerName}'),
                  subtitle: Text('Loan Reason: ${loan!.loanRequestReason}'),
                ),
                ListTile(
                  title: Text(
                      'Loan Amount XAF ${numberFormat.format(loan!.outStandingBalance)}'),
                  subtitle: Text(
                      'Loan Submitted On ${shortDateFormat.format(DateTime.fromMillisecondsSinceEpoch(loan!.submissionDate))}'),
                ),
                TermsAndConditionsCheckBox(
                  url: 'http://localhost:58476/#/',
                  textPrefix: 'By Approving this loan, you agree ',
                  urlText:
                      'that your shares can be used to pay this loan if it is not repaid by ${shortDateFormat.format(DateTime.fromMillisecondsSinceEpoch(loan!.proposedRepaymentDate))}. You also agree to the Terms and Conditions of Ngyenmuwah Dynamic Youth Loans linked in this text.',
                  onChanged: (value) {
                    setState(() {
                      hasAgreedToTerms = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: SignatureWidget(onPressed: (signatureBytes) async {
                      final user = getFirebaseAuthUser(context);
                      final ref = FirebaseStorage.instance
                          .ref()
                          .child('signatures')
                          .child(
                              '${user.uid}${longDateTimeFormat.format(getUtcNow())}.png');
                      final UploadTask uploadTask = ref.putData(signatureBytes,
                          SettableMetadata(contentType: 'image/png'));
                      final snapshot = await uploadTask;
                      screenshotUrl = await snapshot.ref.getDownloadURL();
                    }, onSignatureCleared: () async {
                      screenshotUrl = null;
                      setState(() {});
                    }),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: isSubmitting
                      ? const [LoadingProgressIndicator()]
                      : [
                          ActionButton(
                              text: 'Approve',
                              maxWidth: 140,
                              color: Colors.green.shade900,
                              radius: 5,
                              onPressed: () async {
                                if (!isSubmitting &&
                                    hasAgreedToTerms &&
                                    screenshotUrl != null) {
                                  isSubmitting = true;
                                  setState(() {});
                                  final loanRef =
                                      FirestoreDB.loansRef.doc(loan!.loanId);
                                  var approvedGaurantors = loan!
                                      .approvedGaurantors
                                      .map((e) => e.toJson())
                                      .toList();
                                  var loanUpdates = loan!.loanUpdates
                                      .map((e) => e.toJson())
                                      .toList();
                                  final dateTimeNow = DateTime.now()
                                      .toUtc()
                                      .add(const Duration(hours: 1));
                                  final gaurantorApprover = {
                                    'gaurantorApprovalDate':
                                        dateTimeNow.toIso8601String(),
                                    'gaurantorSignature': screenshotUrl,
                                    'gaurantorUid': currentUser.uid,
                                    'gaurantorName': currentUser.displayName,
                                    'loanId': loan!.loanId,
                                  };
                                  final updates = {
                                    'updateDate':
                                        dateTimeNow.millisecondsSinceEpoch,
                                    'outstandingBalance':
                                        loan!.outStandingBalance,
                                    'updatedByDisplayName':
                                        currentUser.displayName,
                                    'updatedByUserId': currentUser.uid,
                                    'updateMessage': 'Approved Loan',
                                    'other':
                                        '${currentUser.displayName} Approved Loan',
                                  };
                                  approvedGaurantors.add(gaurantorApprover);
                                  loanUpdates.add(updates);
                                  await loanRef.update({
                                    'approvedGaurantors': approvedGaurantors,
                                    'loanUpdates': loanUpdates
                                  });

                                  isSubmitting = false;
                                  setState(() {});
                                  if (mounted) {
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Center(
                                            child: Container(
                                              constraints: mobileScreenBox
                                                  .copyWith(maxWidth: 400),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(18.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      'Loan Approved',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Text(
                                                      'Thanks for approving this loan to be grated to ${loan!.ownerName}. You can close this tab and exit this page.',
                                                      style: const TextStyle(
                                                          fontSize: 17,
                                                          color:
                                                              Colors.black54),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                                Navigator.of(context)
                                                    .pop(); // Pop the current screen
                                              },
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                              }),
                          const SizedBox(
                            width: 5,
                          ),
                          ActionButton(
                              text: 'Dismiss',
                              maxWidth: 120,
                              color: Colors.red.shade900,
                              radius: 5,
                              onPressed: () async {
                                Navigator.of(context).pop();
                              }),
                        ],
                )
              ],
            )
          ]
        ],
      ),
    );
  }
}
