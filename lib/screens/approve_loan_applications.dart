import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/firebase_auth/firebase_auth_bloc.dart';
import 'package:flutter_mqtt_location_tracker/models/loan.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_center_container.dart';
import 'package:flutter_mqtt_location_tracker/widgets/progress_indicator.dart';
import 'package:flutter_mqtt_location_tracker/widgets/signature_widget.dart';
import 'package:flutter_mqtt_location_tracker/widgets/terms_and_conditions.dart';
import 'package:flutter_mqtt_location_tracker/widgets/warning_widget.dart';

class ApproveLoansWidget extends StatefulWidget {
  const ApproveLoansWidget({super.key});

  @override
  ApproveLoansWidgetState createState() => ApproveLoansWidgetState();
}

class ApproveLoansWidgetState extends State<ApproveLoansWidget> {
  String? warningMessage;
  bool isLoading = false;
  bool isSubmitting = false;
  bool hasAgreedToTerms = false;
  Loan? loan;
  String? approvalSignature;

  final _formKey = GlobalKey<FormState>();
  final _loanIdController = TextEditingController();

  void searchLoan() async {
    if (!isLoading && _formKey.currentState!.validate()) {
      isLoading = true;
      setState(() {});
      final loanId = _loanIdController.text.trim();
      final currentUser = getFirebaseAuthUser(context);
      final loanDoc = await FirestoreDB.loansRef.doc(loanId).get();
      if (loanDoc.exists) {
        final loanMap = loanDoc.data()! as Map<String, dynamic>;
        final loanInfo = Loan.fromJson(loanMap);
        final gaurantorIds = loanInfo.gaurantors.map((e) => e.uid).toList();
        final userIsGaurantor = gaurantorIds.contains(currentUser.uid);
        // if (loanInfo.ownerId == currentUser.uid) {
        //   warningMessage = 'Sorry, You cannot approve loans for yourself';
        // } else
        // if (userIsGaurantor &&
        //     loanInfo.approvedGaurantors
        //         .map((e) => e.gaurantorUid)
        //         .contains(currentUser.uid)) {
        //   warningMessage = 'Thanks, You have already Approved this loan.';
        // } else
        if (userIsGaurantor) {
          loan = loanInfo;
          warningMessage = null;
        }
      } else {
        warningMessage = 'The Loan Id $loanId you provided does not Exists.';
      }
      isLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = getFirebaseAuthUser(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Center(child: Text('Approve Loans')),
      ),
      body: DefaultCenterContainer(
        children: [
          if (warningMessage.isNotNullAndNotEmpty) ...[
            WarningWidget(warningMessage: warningMessage!),
            const SizedBox(
              height: 16,
            ),
          ],
          const Text(
            'Enter the Loan Application Id (7 characters)',
            style: TextStyle(fontSize: 18.0),
          ),
          const SizedBox(height: 8.0),
          Container(
            decoration: containerDecoration,
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _loanIdController,
                validator: (value) {
                  value = (value ?? '').trim();
                  if (value.isEmpty) {
                    return 'Enter Case Sensitive Loan Id';
                  }
                  if (value.length != 7) {
                    return 'Loan Id must be 7 Characters Long';
                  }
                  return null;
                },
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: 'Loan Application Id',
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      searchLoan();
                    },
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
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //       //color: Colors.green.shade700,
                  //       ),
                  //   borderRadius: BorderRadius.circular(5),
                  // ),
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
                      approvalSignature = await snapshot.ref.getDownloadURL();
                    }, onSignatureCleared: () async {
                      approvalSignature = null;
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
                                    approvalSignature != null) {
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
                                    'gaurantorSignature': approvalSignature,
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
