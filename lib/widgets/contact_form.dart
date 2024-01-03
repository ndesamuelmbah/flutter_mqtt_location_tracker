// import 'dart:convert';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// // import 'package:get_it/get_it.dart';
// import 'package:logging/logging.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_mqtt_location_tracker/bloc/firebase_auth/firebase_auth_bloc.dart';
// import 'package:flutter_mqtt_location_tracker/client/api_requests.dart';
// import 'package:flutter_mqtt_location_tracker/core/utils/constants.dart';
// import 'package:flutter_mqtt_location_tracker/core/utils/firestore_db.dart';
// import 'package:flutter_mqtt_location_tracker/core/utils/general_utils.dart';
// import 'package:flutter_mqtt_location_tracker/core/utils/get_device_id.dart';
// import 'package:flutter_mqtt_location_tracker/core/utils/strings.dart';
// import 'package:flutter_mqtt_location_tracker/core/utils/validate_email.dart';
// import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
// import 'package:flutter_mqtt_location_tracker/widgets/flutter_toasts.dart';
// import 'package:flutter_mqtt_location_tracker/widgets/ordered_menu_items_summary.dart';
// import 'package:flutter_mqtt_location_tracker/widgets/progress_indicator.dart';
// import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
// import 'package:flutter_mqtt_location_tracker/models/ordered_item.dart';
// import 'package:flutter_mqtt_location_tracker/repository/service_locator.dart';

// class ContactForm extends StatefulWidget {
//   final String header;
//   final bool includeContactReason;
//   final OrderedMenuItems? orderedMenuItems;
//   const ContactForm(
//       {Key? key,
//       required this.header,
//       required this.includeContactReason,
//       this.orderedMenuItems})
//       : super(key: key);

//   @override
//   ContactFormState createState() => ContactFormState();
// }

// class ContactFormState extends State<ContactForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _contactReasonController = TextEditingController();
//   final getIt = GetIt.I;
//   bool isLoading = false;
//   String? formSubmittedMessage;
//   Logger logger = Logger('contactForm');
//   bool isEmailReadOnly = false;
//   bool isNameReadOnly = false;
//   bool isPhoneReadOnly = false;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _contactReasonController.dispose();
//     if (widget.orderedMenuItems != null &&
//         widget.orderedMenuItems!.hasItems()) {
//       logger = Logger('contactFormCreateOrder');
//     }
//     super.dispose();
//   }

//   @override
//   void initState() {
//     final user = FirebaseAuth.instance.currentUser;
//     var timeNow = DateTime.now();
//     int lastPingTime = getIt<StoresBox>().get(Constants.lastTimeApiWasPinged) ??
//         timeNow.add(const Duration(minutes: -30)).millisecondsSinceEpoch;
//     Future.delayed(const Duration(milliseconds: 500)).then((value) {
//       final authUser = getNullableFirebaseAuthUser(context);
//       if (authUser != null) {
//         if (!authUser.email.endsWith('yvettes237kitchenapi.com')) {
//           _emailController.text = authUser.email;
//           isEmailReadOnly = true;
//         }
//         _nameController.text = authUser.displayName ?? '';
//         isNameReadOnly = true;

//         _phoneController.text = authUser.phoneNumber.replaceAll('+', '');
//         isPhoneReadOnly = true;
//         if (mounted) {
//           setState(() {});
//         }
//       }
//     });
//     if (timeNow.millisecondsSinceEpoch - lastPingTime > 5 * 60 * 1000) {
//       ApiRequest.genericGet('ping_api/${user?.uid}').then((value) {
//         getIt<StoresBox>().put(Constants.lastTimeApiWasPinged,
//             DateTime.now().millisecondsSinceEpoch);
//       });
//     } else {}

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: widget.includeContactReason == false
//             ? 5
//             : getPadding(
//                 MediaQuery.of(context).size,
//                 forForm: true,
//               ),
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (widget.orderedMenuItems == null)
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   widget.header,
//                   style: const TextStyle(
//                     fontSize: 24.0,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             if (widget.orderedMenuItems != null &&
//                 widget.orderedMenuItems!.hasItems()) ...[
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Column(
//                   children: const [
//                     Text(
//                       'Note About Payment',
//                       style: TextStyle(
//                         fontSize: 24.0,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 8,
//                     ),
//                     Text(
//                       "After placing your order, ${Strings.appName} will contact you with instructions on how to pay.",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 18.0,
//                         //fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               OrderedMenuItemsSummary(
//                 orderedMenuItems: widget.orderedMenuItems!,
//                 title: "Order Summary",
//               )
//             ],
//             const SizedBox(height: 8.0),
//             Container(
//               decoration: containerDecoration,
//               child: TextFormField(
//                 controller: _nameController,
//                 readOnly: isNameReadOnly,
//                 keyboardType: TextInputType.name,
//                 textCapitalization: TextCapitalization.words,
//                 autovalidateMode: AutovalidateMode.onUserInteraction,
//                 decoration: const InputDecoration(
//                   labelText: 'Name',
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.all(8.0),
//                 ),
//                 validator: validateName,
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8.0),
//                 color: Colors.grey[200],
//               ),
//               child: TextFormField(
//                 controller: _phoneController,
//                 readOnly: isPhoneReadOnly,
//                 keyboardType: TextInputType.phone,
//                 autovalidateMode: AutovalidateMode.onUserInteraction,
//                 decoration: const InputDecoration(
//                   labelText: 'Phone number',
//                   contentPadding: EdgeInsets.all(8.0),
//                   border: InputBorder.none,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your phone number';
//                   }
//                   if (RegExp(r"^1?[2-9][0-9]{9,9}$").hasMatch(value)) {
//                     return null;
//                   }
//                   return "Enter a Valid US phone number";
//                 },
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             Container(
//               decoration: containerDecoration,
//               child: TextFormField(
//                   controller: _emailController,
//                   readOnly: isEmailReadOnly,
//                   keyboardType: TextInputType.emailAddress,
//                   autovalidateMode: AutovalidateMode.onUserInteraction,
//                   decoration: const InputDecoration(
//                     labelText: 'Email (optional)',
//                     contentPadding: EdgeInsets.all(8.0),
//                     border: InputBorder.none,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return null;
//                     }
//                     value = value.trim();
//                     if (validateEmail(value) == null) {
//                       return null;
//                     }
//                     return "Enter a Valid Email Or Leave Empty";
//                   }),
//             ),
//             if (widget.includeContactReason) const SizedBox(height: 16.0),
//             if (widget.includeContactReason)
//               Container(
//                 decoration: containerDecoration,
//                 child: TextFormField(
//                     controller: _contactReasonController,
//                     keyboardType: TextInputType.multiline,
//                     autovalidateMode: AutovalidateMode.onUserInteraction,
//                     maxLines: 5,
//                     minLines: 3,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       hintText: widget.orderedMenuItems == null
//                           ? 'Contact Reason'
//                           : "Delivery Note",
//                       labelText: widget.orderedMenuItems == null
//                           ? 'I am contacting you to help me with ...'
//                           : "eg Make the order spicy like 3 out of 5",
//                       contentPadding: const EdgeInsets.all(16.0),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return widget.includeContactReason
//                             ? widget.orderedMenuItems == null
//                                 ? 'Please Enter A contact Reason'
//                                 : 'Please Include Delivery Note'
//                             : null;
//                       }
//                       value = value.trim().replaceAll(RegExp(r'\s+'), ' ');
//                       if (value.split(' ').length < 3) {
//                         return 'Needs to be at least 4 words';
//                       }
//                       return value.length < 12 ? "Too Short" : null;
//                     }),
//               ),
//             const SizedBox(height: 26.0),
//             isLoading
//                 ? Visibility(
//                     visible: isLoading,
//                     child: const LoadingProgressIndicator(),
//                   )
//                 : ActionButton(
//                     backgroundColor: Colors.blue.shade200,
//                     color: Colors.blue,
//                     borderWidth: 2,
//                     maxWidth: 400,
//                     height: 50,
//                     radius: 7,
//                     horizontalPadding: 0,
//                     fontColor: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     onPressed: () async {
//                       setState(() {
//                         isLoading = true;
//                       });
//                       if (formSubmittedMessage != null) {
//                         showSuccessToast(formSubmittedMessage!);
//                       } else if (_formKey.currentState!.validate()) {
//                         // Do something with the form data
//                         String name = _nameController.text.trim();
//                         String phone = _phoneController.text.trim();
//                         String email = _emailController.text.trim();
//                         String contactReason =
//                             _contactReasonController.text.trim();
//                         if (phone.startsWith('1')) {
//                           phone = '+$phone';
//                         } else {
//                           phone = '+1$phone';
//                         }
//                         final cu = getNullableFirebaseAuthUser(context);
//                         Map<String, String> params = {
//                           'phoneNumber': cu?.phoneNumber ?? phone,
//                           //'uid': user.uid,
//                           'userName': cu?.displayName ?? name,
//                           'skipFirestoreCheck': false.toString()
//                         };
//                         if (widget.includeContactReason &&
//                             widget.orderedMenuItems == null) {
//                           params['contactMessage'] = contactReason;
//                         }
//                         if (widget.orderedMenuItems != null &&
//                             widget.orderedMenuItems!.hasItems()) {
//                           params['deliveryMessage'] = contactReason;
//                           params['orderedMenuItems'] = json.encode(widget
//                               .orderedMenuItems!.orderedMenuItems
//                               .map((e) {
//                             var orderedMenuItem = e.menuItem.toJson();
//                             orderedMenuItem['totalPrice'] =
//                                 e.menuItem.itemPrice * e.quantity;
//                             orderedMenuItem['quantity'] = e.quantity;
//                             return orderedMenuItem;
//                           }).toList());
//                         }
//                         if (cu != null) {
//                           params['email'] = cu.email;
//                           params['uid'] = cu.uid;
//                         }
//                         if (email.isNotNullAndNotEmpty) {
//                           params['email'] = email;
//                         }
//                         final userMap = await ApiRequest.genericPost(
//                             'get_or_create_user',
//                             params: params);
//                         if (userMap != null) {
//                           if (userMap.containsKey('currentOrderId') &&
//                               widget.orderedMenuItems != null &&
//                               widget.orderedMenuItems!.hasItems()) {
//                             await HapticFeedback.vibrate();
//                             showSuccessToast('Your Order has been created');
//                           }
//                           await FirebaseAuth.instance.signOut();
//                           final FirebaseAuthUser firebaseAuthUser =
//                               FirebaseAuthUser.fromJson(userMap);
//                           getIt<StoresBox>()
//                               .put(Constants.currentUser, userMap);
//                           getIt<StoresBox>().put(
//                               Constants.lastTimeUserWasExtracted,
//                               DateTime.now().millisecondsSinceEpoch);
//                           await FirebaseAuth.instance
//                               .signInWithEmailAndPassword(
//                                   email: email.isNotEmpty
//                                       ? email
//                                       : firebaseAuthUser.email,
//                                   password: getIt<EnvVars>().EMAIL_PASSWORD);
//                           Map<String, dynamic> data = {
//                             'lastUpdated':
//                                 DateTime.now().millisecondsSinceEpoch,
//                             'customerPhone': firebaseAuthUser.phoneNumber,
//                             'customerName': firebaseAuthUser.displayName,
//                           };
//                           if (widget.includeContactReason &&
//                               widget.orderedMenuItems == null) {
//                             data['lastContactMessage'] = contactReason;
//                           } else if (widget.orderedMenuItems != null &&
//                               widget.orderedMenuItems!.hasItems()) {
//                             data['currentOrderId'] = userMap['currentOrderId'];
//                           }
//                           // if (!firebaseAuthUser.isAdmin && widget.orderedMenuItems == null) {
//                           //   FirestoreDB.chatsRef
//                           //       .doc(firebaseAuthUser.phoneNumber)
//                           //       .set(data)
//                           //       .then((_) {})
//                           //       .catchError((error, stackTrace) {
//                           //     logger.severe(error, stackTrace);
//                           //   });
//                           // }
//                           saveDeviceLoginInfo(firebaseAuthUser.phoneNumber);
//                           if (mounted) {
//                             context
//                                 .read<FirebaseAuthBloc>()
//                                 .add(Login(firebaseAuthUser));
//                           }
//                           if (widget.includeContactReason) {
//                             formSubmittedMessage =
//                                 widget.orderedMenuItems == null
//                                     ? 'We have Received Your Message'
//                                     : 'Your Order has been created';
//                           } else {
//                             formSubmittedMessage = 'You are now Logged In';
//                           }
//                           showSuccessToast('You are now Logged In');
//                         } else {
//                           showSuccessToast('An Error Occurred');
//                         }
//                       } else {
//                         showErrorToast('Please fill the required fields');
//                       }

//                       if (mounted) {
//                         setState(() {
//                           isLoading = false;
//                         });
//                       }
//                     },
//                     text: 'Submit',
//                   ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future saveDeviceLoginInfo(String authPhoneNumber) async {
//     var deviceInfo = await getDeviceInfo();
//     final dateTime = DateTime.now().toIso8601String();
//     deviceInfo['phoneNumber'] = authPhoneNumber;
//     deviceInfo['dateTime'] = dateTime;
//     await FirestoreDB.userDevicesRef.doc(dateTime).set(deviceInfo);
//   }
// }
