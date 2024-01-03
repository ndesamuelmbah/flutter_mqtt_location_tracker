import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/firebase_auth/firebase_auth_bloc.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter_mqtt_location_tracker/models/loan.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/media_utilities.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';
import 'package:flutter_mqtt_location_tracker/widgets/attachment_bottom_sheet.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_loading_shimmer.dart';
import 'package:flutter_mqtt_location_tracker/widgets/flutter_toasts.dart';
import 'package:flutter_mqtt_location_tracker/widgets/loan_application_summary.dart';
import 'package:universal_html/html.dart' if (dart.library.html) 'dart:html' as html;
import 'package:flutter_mqtt_location_tracker/widgets/warning_widget.dart';

class ManageLoan extends StatefulWidget {
  final String loanId;

  const ManageLoan({super.key, required this.loanId});

  @override
  ManageLoanState createState() => ManageLoanState();
}

class ManageLoanState extends State<ManageLoan> {
  bool hasDeniedCameraPerms = false;
  bool hasDeniedGalleryPerms = false;
  final imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Loan'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: mobileScreenBox,
          child: StreamBuilder<DocumentSnapshot<Object?>>(
            stream: FirestoreDB.loansRef.doc(widget.loanId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidgetsListView(
                  numberOfLoaders: 2,
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Failed to fetch loan details'),
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                if (data == null) {
                  return Center(
                    child: Text(
                        'Failed to fetch loan details for loan Id ${widget.loanId}'),
                  );
                }
                final loanInfo = Loan.fromJson(data);
                bool isLoanApproved = loanInfo.approvalDate != null;
                List<Widget> lw = [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      elevation: 4,
                      child: ListTile(
                        tileColor:
                            isLoanApproved ? Colors.green.shade200 : null,
                        title: const Text('Current Status'),
                        subtitle: isLoanApproved
                            ? const Text('This Application Approved')
                            : const Text('This Application is Under Review'),
                      ),
                    ),
                  ),
                  LoanApplicationSummary(
                    title: "Summary of Application",
                    displayName: loanInfo.ownerName,
                    loanAmount: loanInfo.outStandingBalance,
                    loanReason: loanInfo.loanRequestReason,
                    proposedPaymentDate: DateTime.fromMillisecondsSinceEpoch(
                        loanInfo.proposedRepaymentDate),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  // CopyLoanIdWidget(loanId: loanInfo.loanId),
                  // const SizedBox(
                  //   height: 16,
                  // ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: buildListOfGaurantors(
                        loanInfo.gaurantors,
                        loanInfo.approvedGaurantors as List<String>,
                        loanInfo.loanId),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        child: Center(
                          child: Image.network(
                            loanInfo.requesterSignature,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(loanInfo.ownerName),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(longDateTimeFormat.format(
                          DateTime.fromMillisecondsSinceEpoch(
                              loanInfo.submissionDate))),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  if (loanInfo.supportingDocuments.length < 10)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Card(
                        elevation: 4,
                        child: ListTile(
                            onTap: () async {
                              // if (kIsWeb) {
                              // } else {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return AttachmentBottomSheet(
                                      onAttachmentSelected: (source) async {
                                    final user = getFirebaseAuthUser(context);
                                    if (source == ImageSource.camera) {
                                      PermissionStatus permissions;
                                      if (kIsWeb) {
                                        permissions = await handleWebPermission(
                                            {'name': 'camera'});
                                      } else {
                                        permissions =
                                            await Permission.camera.request();
                                        if (permissions.isDenied) {
                                          permissions =
                                              await Permission.camera.request();
                                        }
                                      }
                                      if (permissions.isPermanentlyDenied) {
                                        hasDeniedCameraPerms = true;
                                        setState(() {});
                                      } else {
                                        // Open the gallery
                                        final image =
                                            await imagePicker.pickImage(
                                                source: ImageSource.camera,
                                                maxWidth: 500,
                                                maxHeight: 800);
                                        if (image != null) {
                                          final extension = image.name
                                              .split('.')
                                              .last
                                              .toLowerCase();
                                          final docRef = FirestoreDB
                                              .supportingDocumentsRef
                                              .child(
                                                  '${user.uid}_${longDateTimeFormat.format(getUtcNow()).replaceAll(RegExp('[ ,:]'), '_')}.$extension');
                                          final String? url =
                                              await saveXFileImageToFirestore(
                                                  image, docRef);
                                          if (url != null) {
                                            List<String> loanDocs =
                                                loanInfo.supportingDocuments
                                                    as List<String>;
                                            loanDocs.add(url);
                                            await FirestoreDB.loansRef
                                                .doc(loanInfo.loanId)
                                                .update({
                                              'supportingDocuments': loanDocs
                                            });
                                          }
                                        }
                                      }
                                    } else {
                                      // Open the camera
                                      print('Gallery selected');
                                      PermissionStatus permissions;
                                      if (kIsWeb) {
                                        permissions = await handleWebPermission(
                                            {'name': 'clipboard-read'});
                                        print('web permissions $permissions');
                                      } else {
                                        permissions =
                                            await Permission.storage.request();
                                        if (permissions.isDenied) {
                                          permissions = await Permission.storage
                                              .request();
                                        }
                                      }
                                      if (permissions.isPermanentlyDenied) {
                                        hasDeniedCameraPerms = true;
                                        setState(() {});
                                      } else {
                                        // Open the gallery
                                        print('Gallery selected');
                                        final image =
                                            await imagePicker.pickImage(
                                                source: ImageSource.gallery,
                                                maxWidth: 500,
                                                maxHeight: 800);
                                        if (image != null) {
                                          final extension = image.name
                                              .split('.')
                                              .last
                                              .toLowerCase();
                                          final docRef = FirestoreDB
                                              .supportingDocumentsRef
                                              .child(
                                                  '${user.uid}_${longDateTimeFormat.format(getUtcNow()).replaceAll(RegExp('[ ,:]'), '_')}.$extension');
                                          final String? url =
                                              await saveXFileImageToFirestore(
                                                  image, docRef);
                                          if (url != null) {
                                            List<String> loanDocs =
                                                loanInfo.supportingDocuments
                                                    as List<String>;
                                            loanDocs.add(url);
                                            await FirestoreDB.loansRef
                                                .doc(loanInfo.loanId)
                                                .update({
                                              'supportingDocuments': loanDocs
                                            });
                                          }
                                        }
                                      }
                                    }
                                  });
                                },
                              );
                              //}
                            },
                            title:
                                const Text('Add Up to 10 Supporting documents'),
                            subtitle:
                                const Text('png, jpg, jpeg, doc, docx, txt'),
                            leading: const Icon(
                              Icons.attach_file_outlined,
                              size: 30,
                            )),
                      ),
                    ),
                  //ActionButton(text: 'Add Supporting documents', color: Colors.blue, onPressed: (){})
                  if (loanInfo.supportingDocuments.isNotEmpty)
                    SizedBox(
                      height: 250,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: buildListOfDocuments(loanInfo),
                      ),
                    ),
                  if (!kIsWeb &&
                      (hasDeniedCameraPerms || hasDeniedGalleryPerms))
                    WarningWidget(
                      warningMessage:
                          "You need to Grant Permissions to Continue",
                      subtitle:
                          'Please tap this button to manually grant the required Permissions',
                      onTap: () async {
                        await openAppSettings();
                      },
                    )
                ];
                // lw.addAll(data.entries.map((e) => ListTile(
                //       title: Text(e.key),
                //       subtitle: Text(e.value.toString()),
                //     )));
                return ListView(children: lw);
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  List<Widget> buildListOfDocuments(Loan loanInfo) {
    return loanInfo.supportingDocuments.map((e) {
      return GestureDetector(
        onTap: () async {
          html.window.open(e, "_self");
          // if ('.jpg .png .jpeg'
          //     .split(' ')
          //     .any((element) => e.contains(element))) {
          //   html.window.open(e, "_self");
          // }
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child:
              '.jpg .png .jpeg'.split(' ').any((element) => e.contains(element))
                  ? Image.network(e, fit: BoxFit.fitHeight)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: getDocumentPreview(e),
                    ),
        ),
      );
    }).toList();
  }

  List<Widget> buildListOfGaurantors(List<FirebaseAuthUser> gaurantors,
      List<String> approvedGaurantors, String loanId) {
    List<Widget> widgets = [
      const Text(
        "List of Gaurantors",
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          //decoration: TextDecoration.underline,
        ),
      ),
      const SizedBox(
        height: 10,
      )
    ];
    for (var gaurantor in gaurantors) {
      bool hasApproved = approvedGaurantors.contains(gaurantor.uid);

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            elevation: 4,
            child: ListTile(
              //tileColor: color,
              title: Text(gaurantor.displayName!),
              subtitle: Text(gaurantor.phoneNumber),
              trailing: hasApproved
                  ? const Text(
                      "Approved",
                      style: TextStyle(color: Colors.green),
                    )
                  : const Text(
                      "Waiting",
                      style: TextStyle(color: Colors.grey),
                    ),
            ),
          ),
        ),
      );
    }
    widgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Card(
          elevation: 4,
          child: ListTile(
              //tileColor: color,
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: loanId));
                showSuccessToast('Loan ID copied to clipboard.');
              },
              title: const Text('Loan Id (Tap to Copy)'),
              subtitle: Text(loanId),
              trailing: const Icon(
                Icons.copy_all_outlined,
                size: 30,
              )),
        ),
      ),
    );
    return widgets;
  }
}
