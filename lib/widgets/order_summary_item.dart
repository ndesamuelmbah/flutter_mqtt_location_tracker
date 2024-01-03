// import 'package:flutter_mqtt_location_tracker/client/api_requests.dart';
// import 'package:flutter_mqtt_location_tracker/core/utils/date_util.dart';
// import 'package:flutter_mqtt_location_tracker/core/utils/firestore_db.dart';
// import 'package:flutter_mqtt_location_tracker/core/utils/strings.dart';
// import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
// import 'package:flutter_mqtt_location_tracker/widgets/step_progress_view.dart';
// import 'package:flutter_mqtt_location_tracker/repository/login/login_response.dart';
// import 'package:flutter_mqtt_location_tracker/screens/add_review.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';

// import 'package:flutter_mqtt_location_tracker/screens/reorder_screen.dart';
// import 'package:flutter_mqtt_location_tracker/core/utils/color_palette.dart';
// import 'package:flutter_mqtt_location_tracker/repository/order_summary/order_status.dart';
// import '../../bloc/auth/auth_bloc.dart';
// import '../../repository/order_summary/order_summary_model.dart';

// class OrderSummaryItem extends StatefulWidget {
//   final OrderSummary orderSummary;
//   final bool shouldShowReorder;
//   final Function(int orderId) callBack;
//   const OrderSummaryItem(
//       {Key? key,
//       required this.orderSummary,
//       this.shouldShowReorder = false,
//       required this.callBack})
//       : super(key: key);

//   @override
//   State<OrderSummaryItem> createState() => _OrderSummaryItemState();
// }

// class _OrderSummaryItemState extends State<OrderSummaryItem> {
//   showCancellationReasons(OrderSummary orderToModify) {
//     final authUser = getAuthUser(context);
//     TextStyle titleStyle = const TextStyle();
//     EdgeInsets padding =
//         const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0);
//     AlertDialog dailog = AlertDialog(
//       insetPadding: padding,
//       backgroundColor: const Color(0xFFE9EDF0),
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(13))),
//       title: Text("Why did you Cancel the Order?",
//           textAlign: TextAlign.center, style: titleStyle),
//       content: SingleChildScrollView(
//         child: ListBody(children: [
//           Wrap(
//               children:
//                   'The delivery is slow|I had an emergency|I no longer need the order|Other'
//                       .split('|')
//                       .map(
//                         (reason) => Padding(
//                           padding: const EdgeInsets.only(right: 4.0),
//                           child: GestureDetector(
//                               onTap: (() async {
//                                 final resp = await ApiRequest.genericPost(
//                                     'notify_customer_cancellation',
//                                     params: {
//                                       'driverId': orderToModify
//                                           .assignedDriver.last
//                                           .toString(),
//                                       'orderId':
//                                           orderToModify.orderId.toString(),
//                                       'driverName':
//                                           orderToModify.assignedDriver.first,
//                                       'driverPhone':
//                                           orderToModify.assignedDriver[1],
//                                       'orderedBy':
//                                           orderToModify.orderedBy.toString(),
//                                       'userLang': Strings.localeName,
//                                       'cancellationReason': reason,
//                                       'cancelledBy': authUser.userName,
//                                       'itemIds': orderToModify.orderedItems
//                                           .map((e) => e.itemId.toString())
//                                           .join(',')
//                                     });
//                                 if (resp != null &&
//                                     resp['updatedCustomer'] != null) {
//                                   final user =
//                                       AuthUser.fromMap(resp['updatedCustomer']);
//                                   context
//                                       .read<AuthBloc>()
//                                       .add(UpdateUser(user));
//                                 }
//                                 FirestoreDB().addCancelledOrders({
//                                   'driverId': orderToModify.assignedDriver.last
//                                       .toString(),
//                                   'orderId': orderToModify.orderId,
//                                   'driverName':
//                                       orderToModify.assignedDriver.first,
//                                   'driverPhone':
//                                       orderToModify.assignedDriver[1],
//                                   'orderedBy': orderToModify.orderedBy,
//                                   'userLang': Strings.localeName,
//                                   'cancelledBy': authUser.userName,
//                                   'cancellationReason': reason,
//                                   'itemIds': orderToModify.orderedItems
//                                       .map((e) => e.toMap())
//                                       .toList()
//                                 }, orderToModify.orderId.toInt(),
//                                     authUser.phoneNumber);
//                                 Navigator.of(context).pop();
//                               }),
//                               child: Chip(label: Text(reason))),
//                         ),
//                       )
//                       .toList()),
//           Padding(
//             padding: const EdgeInsets.only(top: 30),
//             child: ActionButton(
//               color: Colors.red,
//               text: "Cancel",
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           )
//         ]),
//       ),
//     );
//     showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => dailog);
//   }

//   @override
//   Widget build(BuildContext context) {
//     var authUser = (context.read<AuthBloc>().state as Authenticated).authUser;
//     var orderStatus = widget.orderSummary.orderStatus.toUpperCase();
//     var address = widget.orderSummary.dropOffAddress;
//     var date = widget.orderSummary.createDate.toLocal();
//     var price = NumberFormat.currency(symbol: '${authUser.currencyCode} ')
//         .format(widget.orderSummary.price);

//     List<String> titles = [
//       OrderStatus.processing,
//       OrderStatus.accepted,
//       OrderStatus.inTransit,
//       OrderStatus.delivered
//       // OrderStatus.completed,
//       // OrderStatus.filled,
//       // OrderStatus.cancelled,
//       // OrderStatus.rejected,
//     ];
//     int curStep = 0;
//     Color activeColor = Colors.green;
//     for (var status in titles) {
//       if (status.toLowerCase() == orderStatus.toLowerCase()) {
//         curStep = titles.indexOf(status) + 1;
//         break;
//       }
//     }
//     for (var status in [OrderStatus.completed, OrderStatus.filled]) {
//       if (status.toLowerCase() == orderStatus.toLowerCase()) {
//         titles.last = status;
//         curStep = titles.length;
//         break;
//       }
//     }

//     for (var status in [OrderStatus.rejected, OrderStatus.cancelled]) {
//       if (status.toLowerCase() == orderStatus.toLowerCase()) {
//         activeColor = Colors.red;
//         titles = [OrderStatus.processing, status];
//         curStep = 2;
//         break;
//       }
//     }
//     return Card(
//       color: Palette.primary.withOpacity(0.1),
//       elevation: 0.0,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 8),
//             StepProgressView(
//               width: MediaQuery.of(context).size.width,
//               curStep: curStep,
//               activeColor: activeColor,
//               titles: titles,
//               textColor: titles.length == 2 ? Colors.red : Colors.black,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildRow(Strings.date, date.timeDateFormat ?? ''),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//                 _buildTotal(price, context),
//               ],
//             ),
//             _buildRow(Strings.deliveryLocation, address),
//             _buildRow(Strings.statusLabel, orderStatus),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 if (widget.shouldShowReorder)
//                   Expanded(
//                     flex: 3,
//                     child: ActionButton(
//                       color: Colors.blue,
//                       text: Strings.orderAgain,
//                       onPressed: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (_) => ReorderScreen(
//                               orderSummary: widget.orderSummary,
//                               currencySymbol: authUser.currencyCode,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 if (widget.orderSummary.hasReviewed == 0 &&
//                     [
//                       OrderStatus.completed,
//                       OrderStatus.delivered,
//                       OrderStatus.filled,
//                     ]
//                         .map((e) => e.toUpperCase().trim())
//                         .toList()
//                         .contains(orderStatus.toUpperCase().trim()))
//                   Expanded(
//                     flex: 3,
//                     child: ActionButton(
//                       text: 'Review Order',
//                       color: Colors.blue,
//                       onPressed: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (_) => AddReviewScreen(
//                               key: Key(widget.orderSummary.orderId.toString() +
//                                   orderStatus),
//                               orderSummary: widget.orderSummary,
//                               storeId: widget.orderSummary.storeId.toInt(),
//                               currencySymbol: authUser.currencyCode,
//                               callback: (orderId) {
//                                 widget.callBack(orderId);
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 if (widget.orderSummary.assignedDriver.length <= 2)
//                   Expanded(
//                     flex: 3,
//                     child: ActionButton(
//                       text: 'Cancel Order',
//                       color: Colors.red,
//                       onPressed: () {
//                         showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return Dialog(
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(
//                                         15.0)), //this right here
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(20),
//                                     gradient: const LinearGradient(
//                                         colors: [Colors.white, Colors.white],
//                                         begin: Alignment.topRight,
//                                         //const FractionalOffset(0.0, 0.5),
//                                         end: Alignment.bottomLeft,
//                                         //const FractionalOffset(1.0, 0.6),
//                                         stops: [0.0, 1.0],
//                                         tileMode: TileMode.clamp),
//                                   ),
//                                   height:
//                                       MediaQuery.of(context).size.height * 0.30,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(12.0),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceEvenly,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         const Text(
//                                           'Are you sure you want to Cancel?',
//                                           style: TextStyle(
//                                             fontSize: 16.0,
//                                             color: Colors.black87,
//                                             fontWeight: FontWeight.bold,
//                                             fontFamily: 'OpenSansBold',
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 20.0, horizontal: 20),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Expanded(
//                                                 flex: 2,
//                                                 child: ActionButton(
//                                                     text: 'Yes',
//                                                     color: Colors.red,
//                                                     onPressed: () {
//                                                       Navigator.of(context)
//                                                           .pop();
//                                                       showCancellationReasons(
//                                                         widget.orderSummary,
//                                                       );
//                                                     }),
//                                               ),
//                                               Expanded(
//                                                 flex: 2,
//                                                 child: ActionButton(
//                                                     text: 'No',
//                                                     color: Colors.green,
//                                                     onPressed: () {
//                                                       Navigator.of(context)
//                                                           .pop();
//                                                     }),
//                                               )
//                                             ],
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             });
//                       },
//                     ),
//                   ),
//               ],
//             ),
//             if (widget.orderSummary.assignedDriver.length >= 2)
//               ListTile(
//                 tileColor: Colors.green[50],
//                 leading: Icon(
//                   Icons.local_shipping_outlined,
//                   size: 50,
//                   color: Colors.blue.shade300,
//                 ),
//                 title: Text(widget.orderSummary.assignedDriver[0].toString()),
//                 subtitle:
//                     Text(widget.orderSummary.assignedDriver[1].toString()),
//                 trailing: Icon(
//                   Icons.house,
//                   size: 50,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             const SizedBox(
//               height: 50,
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTotal(String price, BuildContext context) {
//     var total = Strings.total;
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Text(
//             total,
//             style: const TextStyle(
//                 fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
//           ),
//           Text(
//             price,
//             style: const TextStyle(
//               fontWeight: FontWeight.w400,
//               color: Colors.black,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRow(String key, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 15.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             key,
//             style: const TextStyle(
//                 fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontWeight: FontWeight.w400,
//               color: Colors.grey[400],
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
