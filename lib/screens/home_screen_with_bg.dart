// import 'dart:async';
// import 'dart:convert';
// import 'dart:isolate';
// import 'dart:ui';

// // import 'package:background_fetch/background_fetch.dart';
// import 'package:app_settings/app_settings.dart';
// import 'package:background_locator_2/background_locator.dart';
// import 'package:background_locator_2/location_dto.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_mqtt_location_tracker/api/api_requests.dart';
// import 'package:flutter_mqtt_location_tracker/background_location_test/file_manager.dart';
// import 'package:flutter_mqtt_location_tracker/background_location_test/location_service_repository.dart';
// import 'package:flutter_mqtt_location_tracker/firebase_auth/firebase_auth_bloc.dart';
// import 'package:flutter_mqtt_location_tracker/location.dart';
// import 'package:flutter_mqtt_location_tracker/models/custom_auth_provider.dart';
// import 'package:flutter_mqtt_location_tracker/models/device_location.dart';
// import 'package:flutter_mqtt_location_tracker/models/envvars.dart';
// import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
// import 'package:flutter_mqtt_location_tracker/models/pending_authentications.dart';
// import 'package:flutter_mqtt_location_tracker/mqtt_handler/mqtt_handler.dart';
// import 'package:flutter_mqtt_location_tracker/screens/signin_with_phone_number.dart';
// import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
// import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
// import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
// import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
// import 'package:flutter_mqtt_location_tracker/widgets/default_center_container.dart';
// // import 'package:geolocator/geolocator.dart';
// import 'package:get_it/get_it.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:logger/logger.dart';
// import 'package:permission_handler/permission_handler.dart';
// //import 'package:hive/hive.dart' as hive;
// import 'package:workmanager/workmanager.dart';

// // Future<void> fetchAndSaveLocationInBackground() async {
// //   //flutter packages pub run build_runner build --delete-conflicting-outputs
// //   var logger = Logger();

// //   logger.d("INSIDE BACKGROUND TASK");
// //   try {
// //     await Hive.initFlutter();
// //     Hive.registerAdapter(CustomAuthProviderAdapter());
// //     Hive.registerAdapter(EnvVarsAdapter());
// //     Hive.registerAdapter(FirebaseAuthUserAdapter());
// //     Hive.registerAdapter(FirebaseAuthUsersAdapter());
// //     Hive.registerAdapter(PendingAuthenticationsAdapter());
// //     Hive.registerAdapter(DeviceLocationAdapter());
// //     Hive.registerAdapter(DeviceLocationsAdapter());
// //     final getItInst = GetIt.instance;
// //     logger.d("INSIDE BACKGROUND TASK: GET IT INSTANCE ");
// //     getItInst.registerSingletonAsync<GeneralBox>(() async {
// //       final GeneralBox box = GeneralBox();
// //       await box.openBox();
// //       return box;
// //     }, signalsReady: false);

// //     await getItInst.allReady();

// //     logger.d("INSIDE BACKGROUND TASK: GET IT INSTANCE READY");
// //   } on HiveError catch (e, s) {
// //     logger.d("INSIDE BACKGROUND TASK: Error HiveError $e");
// //     logger.d("INSIDE BACKGROUND TASK: StackTrace HiveError $s");
// //   } finally {
// //     logger.d("INSIDE BACKGROUND TASK: before calling general box");
// //     final getItInst = GetIt.instance;
// //     final generalBox = getItInst<GeneralBox>();
// //     final canTrackDevice = generalBox.get(Keys.canTrackDevice) as bool?;

// //     logger.d(
// //         "INSIDE BACKGROUND TASK: General box has been used with keys ${generalBox.box!.keys.toList()}");
// //     if (canTrackDevice == true) {
// //       logger.d("INSIDE BACKGROUND TASK: Can track device is true");
// //       final perms = await Addresses.getLocationPermissionsGeolocation(
// //           requestIfNotGranted: false);
// //       logger.d("INSIDE BACKGROUND TASK: Permissions are $perms");
// //       if (perms != null) {
// //         //final location = await Geolocation.getCurrentPosition();
// //         const LocationSettings locationSettings = LocationSettings(
// //           accuracy: LocationAccuracy.high,
// //           distanceFilter: Keys.distanceFilterInMeters,
// //         );
// //         int numberOfTimes = 0;
// //         // final mqttHandler = MqttHandler();
// //         // await mqttHandler.connect();
// //         DeviceLocations devicePositions =
// //             (generalBox.get(Keys.devicePositionsList) as DeviceLocations?) ??
// //                 DeviceLocations(deviceLocations: []);
// //         logger.d(
// //             "INSIDE BACKGROUND TASK: devicePositions gotton from general box");
// //         Position? position = await Geolocator.getLastKnownPosition();
// //         logger.d(
// //             "INSIDE BACKGROUND TASK: Position gotton from geolocator $position");
// //         //final a = await Geolocator.getLastKnownPosition();

// //         // StreamSubscription<Position> positionStream =
// //         //     Geolocator.getPositionStream(locationSettings: locationSettings)
// //         //         .listen((Position? position) {
// //         //   logger.d(
// //         //       "INSIDE BACKGROUND TASK: Position stream gotton from geolocator $position");
// //         if (position != null &&
// //             !devicePositions.isFarFromCurrentPosition(
// //                 currentPosition: position)) {
// //           final authUser =
// //               generalBox.get(Keys.firebaseAuthUser) as FirebaseAuthUser;
// //           final deviceHash = generalBox.get(Keys.deviceHash) as String;

// //           final topicLocationUpdates = 'lu/${authUser.email}';
// //           final clientId = '${authUser.email}/$deviceHash';
// //           final email = authUser.email;
// //           var positionMap = position.toJson();
// //           positionMap.addAll({
// //             'email': email,
// //             'clientId': clientId,
// //             'topic': topicLocationUpdates,
// //             'deviceHash': deviceHash,
// //             'lat': position.latitude,
// //             'lon': position.longitude
// //           });
// //           positionMap.removeWhere((key, value) =>
// //               (key == 'latitude' || key == 'longitude') ||
// //               (value ?? '').toString().isNullOrWhiteSpace);

// //           final postParams = positionMap
// //               .map((key, value) => MapEntry(key, value.toString()))
// //               .cast<String, String>();
// //           logger.d("INSIDE BACKGROUND TASK: Post params $postParams");
// //           final value = await ApiRequest.genericPost(
// //               'publish_mobile_app_location',
// //               params: postParams);
// //           // .then((value) {
// //           logger.d(
// //               "INSIDE BACKGROUND TASK: Location published to server with outcome: $value");
// //           if (value != null) {
// //             positionMap.addAll({
// //               'createdAt': DateTime.fromMillisecondsSinceEpoch(
// //                   positionMap['timestamp'] ??
// //                       DateTime.now().toUtc().millisecondsSinceEpoch)
// //             });
// //             logger.d("INSIDE BACKGROUND TASK: Position map: $positionMap");
// //             devicePositions.add(DeviceLocation.fromJson(positionMap));
// //             generalBox.put(Keys.devicePositionsList, devicePositions).then(() {
// //               numberOfTimes += 1;
// //               logger
// //                   .d("INSIDE BACKGROUND TASK: Number of times: $numberOfTimes");
// //             });
// //           }
// //           // });
// //         } else {
// //           logger.d(
// //               "INSIDE BACKGROUND TASK: Device is not far from current position");
// //         }
// //         // });
// //       } else {
// //         logger.d(
// //             "INSIDE BACKGROUND TASK: Permissions are null. Can not track device");
// //       }
// //     } else {
// //       logger.d(
// //           "INSIDE BACKGROUND TASK: Can track device is null. Can not track device");
// //     }
// //   }
// // }

// // @pragma('vm:entry-point')
// // void callbackDispatcher() {
// //   print('In background tasks');
// //   Workmanager().executeTask((
// //     task,
// //     inputData,
// //   ) async {
// //     print('In background tasks for task $task and input data $inputData');
// //     await fetchAndSaveLocationInBackground();
// //     return Future.value(true);
// //   });
// // }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   MqttHandler mqttHandler = MqttHandler();
//   final generalBox = GetIt.I<GeneralBox>();
//   ReceivePort port = ReceivePort('BackgroundLocationTest');

//   String logStr = '';
//   bool? isRunning;
//   LocationDto? lastLocation;

//   @override
//   void initState() {
//     super.initState();
//     //mqttHandler.connect();
//     if (!kIsWeb) {
//       print('Not Running on the web!');
//     } else {
//       if (IsolateNameServer.lookupPortByName(
//               LocationServiceRepository.isolateName) !=
//           null) {
//         IsolateNameServer.removePortNameMapping(
//             LocationServiceRepository.isolateName);
//       }

//       IsolateNameServer.registerPortWithName(
//           port.sendPort, LocationServiceRepository.isolateName);

//       port.listen(
//         (dynamic data) async {
//           print('RECEIVED Raw Data: ======================================');
//           print(jsonEncode(data));
//           await updateUI(data);
//         },
//       );
//       initPlatformState();
//     }
//     //BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
//   }

//   Future<void> updateUI(dynamic data) async {
//     final log = await FileManager.readLogFile();

//     LocationDto? locationDto =
//         (data != null) ? LocationDto.fromJson(data) : null;
//     if (locationDto != null) {
//       final receivedData = locationDto.toJson();
//       print(
//           'RECEIVED LocationDto Json: ======================================');
//       receivedData.forEach((key, value) {
//         print('"$key": ${receivedData[key]}');
//       });
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

//   Future<bool> initializeWorkManager() async {
//     print('[BackgroundFetch] Headless event received.');

//     if (!kIsWeb) {
//       //await Future.delayed(const Duration(seconds: 2));
//       final canTrackDevice = generalBox.get(Keys.canTrackDevice) as bool?;

//       // if (canTrackDevice == true) {
//       //   print('Started initializing');
//       //   await Workmanager()
//       //       .initialize(
//       //     callbackDispatcher,
//       //     isInDebugMode: true,
//       //   )
//       //       .catchError((e, s) {
//       //     print('Error initializing work manager: $e');
//       //     print('Error initializing work manager: $s');
//       //   });
//       //   print('Started initializing fetchAndSaveLocationInBackground');
//       //   await Workmanager().registerPeriodicTask(
//       //       'fetchAndSaveLocationInBackground',
//       //       'fetchAndSaveLocationInBackground',
//       //       constraints: Constraints(networkType: NetworkType.connected),
//       //       initialDelay: const Duration(seconds: 10),
//       //       frequency: const Duration(hours: 15),
//       //       inputData: {"data1": "value1", "data2": "value2"});
//       //   print('completed initializing fetchAndSaveLocationInBackground');
//       //   return Future.value(true);
//       // } else if (canTrackDevice == false) {
//       //   //await Workmanager().cancelAll();
//       //   return Future.value(false);
//       // } else {
//       //   //Get permissions to track device
//       //   print('Can track device is null');
//       //   final perms = await Addresses.getLocationPermissionsGeolocation(
//       //       requestIfNotGranted: false);
//       //   if (perms != null) {
//       //     await generalBox.put(Keys.canTrackDevice, true);
//       //     return Future.value(true);
//       //   } else {
//       //     return Future.value(false);
//       //   }
//       // }
//       return Future.value(false);
//     } else {
//       return Future.value(false);
//     }
//   }

//   Future showDialogForRequestingCamera() async {
//     await showDialog<String>(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) => AlertDialog(
//         insetPadding: const EdgeInsets.symmetric(horizontal: 0),
//         title: Container(
//           width: 250,
//           height: 50,
//           padding: const EdgeInsets.all(5),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: Colors.indigo.shade200,
//           ),
//           // color: Colors.yellow,
//           child: const Row(
//             children: [
//               Icon(Icons.camera_alt, size: 40, color: Colors.red),
//               Text(
//                 'Location Permissions DENIED',
//                 style: TextStyle(fontSize: 16, color: Colors.red),
//               ),
//             ],
//           ),
//         ),
//         content: const Padding(
//           padding: EdgeInsets.symmetric(vertical: 20.0),
//           child: Text('Do you want to grant the permissions now?'),
//         ),
//         actions: <Widget>[
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ActionButton(
//                   text: "YES",
//                   color: Colors.green,
//                   radius: 5,
//                   minWidth: 100,
//                   backgroundColor: Colors.green.shade100,
//                   fontWeight: FontWeight.bold,
//                   onPressed: () async {
//                     if (kIsWeb) {
//                       await AppSettings.openAppSettings(
//                           type: AppSettingsType.location);
//                     } else {
//                       await openAppSettings().then((value) =>
//                           print('Settings opened with value $value'));
//                     }
//                   }),
//               ActionButton(
//                   text: "NO",
//                   color: Colors.grey,
//                   radius: 5,
//                   minWidth: 100,
//                   backgroundColor: Colors.grey.shade200,
//                   fontWeight: FontWeight.bold,
//                   onPressed: () async {
//                     Navigator.of(context).pop();
//                   }),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> buildingFuture() async {
//     await Future.delayed(const Duration(seconds: 6));
//     return await initializeWorkManager();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Builder(builder: (context) {
//           final displayName = getNullableFirebaseAuthUser(context)?.displayName;
//           if (displayName != null) {
//             return Text('Welcome $displayName');
//           }
//           return const Text('Manage Your online devices');
//         }),
//       ),
//       body: DefaultCenterContainer(
//         children: <Widget>[
//           Card(
//             elevation: 5,
//             //color: Colors.grey[300],
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text('Complete your account Setup',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Colors.deepPurpleAccent, fontSize: 25)),
//                 const SizedBox(height: 10),
//                 ListTile(
//                   shape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(10),
//                           bottomRight: Radius.circular(10))),
//                   tileColor: Colors.deepPurpleAccent.withOpacity(0.2),
//                   leading: const SizedBox(
//                     height: double.infinity,
//                     width: 40,
//                     child: Icon(
//                       Icons.phone,
//                       size: 40,
//                       color: Colors.deepPurpleAccent,
//                     ),
//                   ),
//                   // const Column(
//                   //   mainAxisAlignment: MainAxisAlignment.center,
//                   //   mainAxisSize: MainAxisSize.min,
//                   //   children: [
//                   //     Icon(Icons.phone, size: 40),
//                   //   ],
//                   // ),
//                   title: const Text('Add a phone number'),
//                   subtitle: const Text('We will text you critical alerts like '
//                       'when your account is accessed from a new device.'),
//                   isThreeLine: true,
//                   onTap: () {
//                     Navigator.of(context).push(MaterialPageRoute(
//                         builder: (context) => SignInWithPhoneNumber(
//                               onGoBack: () {
//                                 Navigator.of(context).pop();
//                               },
//                             )));
//                   },
//                 ),
//               ],
//             ),
//           ),
//           FutureBuilder<Object>(
//               future: buildingFuture(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState != ConnectionState.done ||
//                     snapshot.hasError ||
//                     !snapshot.hasData) {
//                   print('Error initializing work manager: ${snapshot.error}');
//                   return const SizedBox.shrink();
//                 }
//                 final canTrack = snapshot.data as bool;
//                 if (canTrack) {
//                   Workmanager().registerPeriodicTask(
//                       'fetchAndSaveLocationInBackground',
//                       'fetchAndSaveLocationInBackground',
//                       initialDelay: const Duration(seconds: 10),
//                       frequency: const Duration(hours: 15),
//                       inputData: {
//                         "data1": "value1",
//                         "data2": "value2"
//                       }).then((_) => print(
//                       'Periodic Task background Scheduled. Workmanager initialized'));
//                   return const SizedBox.shrink();
//                 } else {
//                   return ActionButton(
//                       onPressed: () async {
//                         final perms = await Permission.locationAlways.request();
//                         //     await Addresses.getLocationPermissionsGeolocation(
//                         //         requestIfNotGranted: false);
//                         // LocationDto? locationDto = await Location().getLocation();
//                         print(perms);
//                         if (perms.isGranted) {
//                           await generalBox.put(Keys.canTrackDevice, true);
//                           //final location = await Geolocation.getCurrentPosition();
//                           await initializeWorkManager();
//                         } else {
//                           await openAppSettings();
//                         }
//                       },
//                       text: 'Start Tracking This Device.');
//                 }
//               }),
//           const SizedBox(height: 10),
//           ActionButton(
//               onPressed: () async {
//                 // await Workmanager().initialize(
//                 //   callbackDispatcher,
//                 //   isInDebugMode: true,
//                 // );
//                 // await Workmanager().registerOneOffTask(
//                 //     'uniqueTestTaskName', 'uniqueTestTaskName',
//                 //     initialDelay: const Duration(seconds: 10),
//                 //     inputData: {"data1": "value1", "data2": "value2"},
//                 //     constraints:
//                 //         Constraints(networkType: NetworkType.connected));
//               },
//               text: 'Schedule one off task'),
//           const SizedBox(height: 10),
//           ActionButton(
//               onPressed: () {}, //fetchAndSaveLocationInBackground,
//               text: 'Test Streaming locations'),
//           ActionButton(
//               onPressed: () async {
//                 final perms = await Permission.location.request();
//                 // final perms =
//                 //     await Addresses.getLocationPermissionsGeolocation();
//                 if (perms.isGranted) {
//                   await BackgroundLocator.initialize();
//                   print('Initialization done');
//                   final _isRunning = await BackgroundLocator.isServiceRunning();
//                   //final location = await Geolocation.getCurrentPosition();
//                   // const LocationSettings locationSettings = LocationSettings(
//                   //     accuracy: LocationAccuracy.high, distanceFilter: 1);
//                   // StreamSubscription<Position> positionStream =
//                   //     Geolocator.getPositionStream(
//                   //             locationSettings: locationSettings)
//                   //         .listen((Position? position) {
//                   //   print('Position: $position' ?? 'unknown');
//                   //   if (position != null) {
//                   //     final positionData = jsonEncode(position.toJson());
//                   //     print(positionData);
//                   //     mqttHandler.publishDeviceLocation(position.toJson());
//                   //     print('Current position is ${position ?? 'unknown'}}');
//                   //   }
//                   // });
//                 }
//               },
//               text: 'Start Streaming Location'),
//           const Text('Data received:',
//               style: TextStyle(color: Colors.black, fontSize: 25)),
//           ValueListenableBuilder<String>(
//             builder: (BuildContext context, String value, Widget? child) {
//               return Text('$value',
//                   style: const TextStyle(
//                       color: Colors.deepPurpleAccent, fontSize: 35));
//             },
//             valueListenable: mqttHandler.data,
//           )
//         ],
//       ),
//     );
//   }
// }
