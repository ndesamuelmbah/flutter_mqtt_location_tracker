// import 'dart:async';
// import 'dart:convert';
// import 'dart:isolate';
// import 'dart:ui';

// import 'package:background_locator_2/background_locator.dart';
// import 'package:background_locator_2/location_dto.dart';
// import 'package:background_locator_2/settings/android_settings.dart';
// import 'package:background_locator_2/settings/ios_settings.dart';
// import 'package:background_locator_2/settings/locator_settings.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_mqtt_location_tracker/utils/toast_messages.dart';
// import 'package:permission_handler/permission_handler.dart';

// import 'file_manager.dart';
// import 'location_callback_handler.dart';
// import 'location_service_repository.dart';

// class BackgroundLocationTest extends StatefulWidget {
//   const BackgroundLocationTest({super.key});

//   @override
//   _BackgroundLocationTestState createState() => _BackgroundLocationTestState();
// }

// class _BackgroundLocationTestState extends State<BackgroundLocationTest> {
//   ReceivePort port = ReceivePort();

//   String logStr = '';
//   bool? isRunning;
//   LocationDto? lastLocation;

//   @override
//   void initState() {
//     super.initState();

//     if (IsolateNameServer.lookupPortByName(
//             LocationServiceRepository.isolateName) !=
//         null) {
//       IsolateNameServer.removePortNameMapping(
//           LocationServiceRepository.isolateName);
//     }

//     IsolateNameServer.registerPortWithName(
//         port.sendPort, LocationServiceRepository.isolateName);

//     port.listen(
//       (dynamic data) async {
//         await updateUI(data);
//       },
//     );
//     initPlatformState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   Future<void> updateUI(dynamic data) async {
//     final log = await FileManager.readLogFile();

//     LocationDto? locationDto =
//         (data != null) ? LocationDto.fromJson(data) : null;
//     if (locationDto != null) {
//       await _updateNotificationText(locationDto);

//       setState(() {
//         if (data != null) {
//           lastLocation = locationDto;
//         }
//         logStr = log;
//       });
//     }
//   }

//   Future<void> _updateNotificationText(LocationDto? data) async {
//     if (data == null) {
//       return;
//     }

//     await BackgroundLocator.updateNotificationText(
//         title: "new location received",
//         msg: "${DateTime.now()}",
//         bigMsg: "${data.latitude}, ${data.longitude}");
//   }

//   Future<void> initPlatformState() async {
//     print('Initializing...');
//     await BackgroundLocator.initialize();
//     logStr = await FileManager.readLogFile();
//     print('Initialization done');
//     final _isRunning = await BackgroundLocator.isServiceRunning();
//     setState(() {
//       isRunning = _isRunning;
//     });
//     print('Running ${isRunning.toString()}');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final start = SizedBox(
//       width: double.maxFinite,
//       child: ElevatedButton(
//         child: Text('Start'),
//         onPressed: () {
//           _onStart();
//         },
//       ),
//     );
//     final stop = SizedBox(
//       width: double.maxFinite,
//       child: ElevatedButton(
//         child: Text('Stop'),
//         onPressed: () {
//           onStop();
//         },
//       ),
//     );
//     final clear = SizedBox(
//       width: double.maxFinite,
//       child: ElevatedButton(
//         child: Text('Clear Log'),
//         onPressed: () {
//           FileManager.clearLogFile();
//           setState(() {
//             logStr = '';
//           });
//         },
//       ),
//     );
//     String msgStatus = "-";
//     if (isRunning != null) {
//       if (isRunning == true) {
//         msgStatus = 'Is running';
//       } else {
//         msgStatus = 'Is not running now';
//       }
//     }
//     final status = Text("Status: $msgStatus");

//     final log = Text(
//       logStr,
//     );

//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Sams Flutter background Locator'),
//         ),
//         body: Container(
//           width: double.maxFinite,
//           padding: const EdgeInsets.all(22),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[start, stop, clear, status, log],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void onStop() async {
//     await BackgroundLocator.unRegisterLocationUpdate();
//     final _isRunning = await BackgroundLocator.isServiceRunning();
//     setState(() {
//       isRunning = _isRunning;
//     });
//   }

//   void _onStart() async {
//     if (await _checkLocationPermission()) {
//       print('onStart...');
//       await _startLocator();
//       final _isRunning = await BackgroundLocator.isServiceRunning();
//       print('onStart...$_isRunning');
//       setState(() {
//         isRunning = _isRunning;
//         lastLocation = null;
//       });
//     } else {
//       print('Permission denied');
//       showSuccessToast('You had failure');
//     }
//   }

//   Future<bool> _checkLocationPermission() async {
//     final permissionStatus = await Permission.location.request();
//     if ([
//       PermissionStatus.provisional,
//       PermissionStatus.denied,
//       PermissionStatus.restricted,
//       PermissionStatus.limited
//     ].contains(permissionStatus)) {
//       final permission = await Permission.locationAlways.request();
//       if (permission == PermissionStatus.granted) {
//         return true;
//       } else {
//         return false;
//       }
//     }
//     return permissionStatus == PermissionStatus.granted;
//   }

//   Future<void> _startLocator() async {
//     Map<String, dynamic> data = {'countInit': 1};
//     return await BackgroundLocator.registerLocationUpdate(
//         LocationCallbackHandler.callback,
//         initCallback: LocationCallbackHandler.initCallback,
//         initDataCallback: data,
//         disposeCallback: LocationCallbackHandler.disposeCallback,
//         iosSettings: IOSSettings(
//             accuracy: LocationAccuracy.NAVIGATION,
//             distanceFilter: 5,
//             stopWithTerminate: true),
//         autoStop: false,
//         androidSettings: AndroidSettings(
//             accuracy: LocationAccuracy.NAVIGATION,
//             interval: 60,
//             distanceFilter: 5,
//             client: LocationClient.android,
//             androidNotificationSettings: AndroidNotificationSettings(
//                 notificationChannelName: 'Location tracking',
//                 notificationTitle: 'Start Location Tracking',
//                 notificationMsg: 'Track location in background',
//                 notificationBigMsg:
//                     'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
//                 notificationIconColor: Colors.grey,
//                 notificationTapCallback:
//                     LocationCallbackHandler.notificationCallback)));
//   }
// }
