// import 'dart:async';
// import 'dart:convert';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_mqtt_location_tracker/location.dart';
// import 'package:flutter_mqtt_location_tracker/models/device_location.dart';
// import 'package:flutter_mqtt_location_tracker/mqtt_handler/mqtt_handler.dart';
// import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
// import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get_it/get_it.dart';

// import 'package:workmanager/workmanager.dart';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   print('In background tasks');
//   Workmanager().executeTask((task, inputData) async {
//     print("Native called background task: $task");
//     final generalBox = GetIt.I<GeneralBox>();
//     var devicePositions =
//         generalBox.get(Keys.devicePositionsList) as DeviceLocations? ??
//             DeviceLocations(deviceLocations: []);

//     if (devicePositions != null) {
//       final perms = await Addresses.getLocationPermissionsGeolocation(
//           requestIfNotGranted: false);
//       if (perms != null) {
//         MqttHandler mqttHandler = MqttHandler();
//         await mqttHandler.connect();
//         //final location = await Geolocation.getCurrentPosition();
//         const LocationSettings locationSettings = LocationSettings(
//           accuracy: LocationAccuracy.high,
//           distanceFilter: 1,
//         );
//         int numberOfTimes = 0;
//         DeviceLocations devicePositions =
//             (generalBox.get(Keys.devicePositionsList) as DeviceLocations?) ??
//                 DeviceLocations(deviceLocations: []);
//         StreamSubscription<Position> positionStream =
//             Geolocator.getPositionStream(locationSettings: locationSettings)
//                 .listen((Position? position) {
//           print('Position: $position' ?? 'unknown');
//           if (position != null) {
//             final positionData = jsonEncode(position.toJson());
//             print(positionData);
//             final res = mqttHandler.publishDeviceLocation(position.toJson());
//             print('Current position is ${position ?? 'unknown'}}');
//             if (res != null) {
//               devicePositions.add(res);
//               generalBox
//                   .put(Keys.devicePositionsList, devicePositions)
//                   .then((value) {
//                 numberOfTimes += 1;
//               });
//               print('Number of times: $numberOfTimes');
//             }
//           }
//         });
//       }
//     }

//     // Add your background task logic here
//     // For example, handle location updates and save them

//     return Future.value(true);
//   });
// }

// class BackgroundProcessing {
//   // Singleton instance
//   static final BackgroundProcessing _instance =
//       BackgroundProcessing._internal();

//   // Named constructor
//   BackgroundProcessing._internal() {
//     // Initialization code
//     _initializeWorkManager();
//   }

//   // Factory method to get the singleton instance
//   factory BackgroundProcessing() => _instance;

//   // Method to initialize WorkManager
//   void _initializeWorkManager() {
//     Workmanager()
//         .initialize(
//           callbackDispatcher,
//           isInDebugMode: true,
//         )
//         .then((value) => print('Workmanager initialized'));
//   }

//   // Method to handle authentication changes with user
//   void handleAuthChangeWithUser(User user) {
//     if (user.isAnonymous) {
//       // Handle anonymous user
//     } else {
//       // TODO: Add code to trigger background tasks based on user authentication
//       // For example, you can schedule a periodic background task here
//     }
//   }
// }
