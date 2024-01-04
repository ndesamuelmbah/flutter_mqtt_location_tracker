import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

// import 'package:background_fetch/background_fetch.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/api/api_requests.dart';
import 'package:flutter_mqtt_location_tracker/firebase_auth/auth_handler.dart';
import 'package:flutter_mqtt_location_tracker/firebase_auth/firebase_auth_bloc.dart';
import 'package:flutter_mqtt_location_tracker/location.dart';
import 'package:flutter_mqtt_location_tracker/models/device_location.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter_mqtt_location_tracker/models/tracking_device_media.dart';
import 'package:flutter_mqtt_location_tracker/mqtt_handler/mqtt_handler.dart';
import 'package:flutter_mqtt_location_tracker/screens/signin_with_phone_number.dart';
import 'package:flutter_mqtt_location_tracker/screens/tracking_devices_media_list.dart';
import 'package:flutter_mqtt_location_tracker/services/auth_service.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:flutter_mqtt_location_tracker/utils/toast_messages.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_center_container.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
Future<void> fetchAndSaveLocationInBackground(
    {Map<String, dynamic> userInput = const {}}) async {
  final logger = Logger();
  logger.d("INSIDE BACKGROUND TASK: Starting to initialize Shared Preferences");
  final SharedPreferences bgPref = await SharedPreferences.getInstance();

  final canTrackDevice = bgPref.getBool(Keys.canTrackDevice) as bool?;
  var keys = bgPref.getKeys().toList();
  if (canTrackDevice == true) {
    logger.d(
        "INSIDE BACKGROUND TASK: Can track device is true with pref keys $keys");

    DeviceLocations devicePositions = DeviceLocations.fromListString(
        bgPref.getStringList(Keys.devicePositionsList) ?? []);
    Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    double distanceFromLastPosition =
        devicePositions.getDistanceFromPosition(currentPosition: position) ?? 0;

    logger.d(
        "INSIDE BACKGROUND TASK: Original Number of Device Locations is ${devicePositions.length()}");
    if (position != null && distanceFromLastPosition >= 0.0) {
      try {
        var authUserString = bgPref.getString(Keys.firebaseAuthUser) ?? '';
        var authUser = FirebaseAuthUser.fromString(authUserString);
        var deviceHash = bgPref.getString(Keys.deviceHash) ?? '';
        final topicLocationUpdates = 'lu/${authUser.email}';
        final clientId = '${authUser.email}/$deviceHash';
        final email = authUser.email;
        var positionMap = position.toJson();
        positionMap.addAll(userInput);
        const postHeader =
            String.fromEnvironment('HEADERS', defaultValue: 'HEADERS_NOT_SET');
        var environmentHeaders =
            bgPref.getStringList(Keys.environmentHeadersFetchedList) ?? [];
        // if (postHeader == 'HEADERS_NOT_SET') {
        //   int l = environmentHeaders.length;
        //   if (l > 10) {
        //     environmentHeaders = environmentHeaders.sublist(l - 9);
        //     environmentHeaders.add(postHeader);
        //   }
        // }
        environmentHeaders.add(postHeader);
        await bgPref.setStringList(
            Keys.environmentHeadersFetchedList, environmentHeaders);
        positionMap.addAll({
          'email': email,
          'clientId': clientId,
          'topic': topicLocationUpdates,
          'deviceHash': deviceHash,
          'lat': position.latitude,
          'lon': position.longitude,
          'header': postHeader,
          'keys': keys
        });
        positionMap.removeWhere(
            (key, value) => (value ?? '').toString().isNullOrWhiteSpace);
        positionMap = getCamelCaseLocationMap(positionMap);
        if (!positionMap.containsKey('timestamp')) {
          positionMap['timestamp'] =
              DateTime.now().toUtc().millisecondsSinceEpoch;
        }
        final inputJson = {"inputData": positionMap};
        final output = await ApiRequest.genericPostDict(
            'publish_mobile_app_location',
            params: inputJson);

        logger.d('INSIDE BACKGROUND TASK: server response $output');
        if (output != null) {
          positionMap.addAll({'timestamp': output['timestamp']});
          devicePositions.add(DeviceLocation.fromJson(positionMap));
          var devicePositionsStringList = devicePositions.toStringList();
          await bgPref.setStringList(
              Keys.devicePositionsList, devicePositionsStringList);
          // logger.d('INSIDE BACKGROUND TASK: Error In Bclock data to server $e');
        }
      } catch (e, s) {
        logger.d('INSIDE BACKGROUND TASK: Error In Bclock data to server $e');
        logger.d(
            'INSIDE BACKGROUND TASK: Stacktrace In Bclock data to server $s');
      }
    } else {
      logger.d(
          "INSIDE BACKGROUND TASK: Device is not far from current position distanceFromLastPosition $distanceFromLastPosition at position $position");
    }
  } else {
    // logger.d(
    //     "INSIDE BACKGROUND TASK: Can track device is null. Can not track device");
  }
}

@pragma('vm:entry-point')
void verifyAlarm() async {
  final int isolateId = Isolate.current.hashCode;
  final DateTime now = DateTime.now();
  final logger = Logger();

  Map<String, dynamic> inputData = {
    'isAlarm': true,
    'isolateId': isolateId,
    'source': 'alarm'
  };
  logger.d(
      "[$now] Test Alarm is running in isolate=$isolateId function='$verifyAlarm' with input $inputData");
  final res = await ApiRequest.genericPostDict('test_background',
      params: {"inputData": inputData});
  logger.d('Beginning Input data $inputData and output data is $res');
  await fetchAndSaveLocationInBackground(userInput: inputData);
  logger.d('Alarm finished');
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((
    task,
    inputData,
  ) async {
    final loggers = Logger();
    loggers.d('In background tasks for task $task and input data $inputData');
    await fetchAndSaveLocationInBackground(userInput: inputData!);

    loggers.d('In background tasks for task $task and input data $inputData');
    return Future.value(true);
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MqttHandler mqttHandler = MqttHandler();
  final generalBox = GetIt.I<GeneralBox>();

  final SharedPreferences prefs = GetIt.I<SharedPreferences>();
  late TrackingDeviceMedias trackingDeviceMedias;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    trackingDeviceMedias = generalBox.get(Keys.trackingDeviceMedia) ??
        TrackingDeviceMedias(media: []);
    if (!kIsWeb) {
      Permission.microphone.request().then((permissionStatue) {
        generalBox.put(Keys.microphonePermission,
            permissionStatue == PermissionStatus.granted);
      });
      if (![TargetPlatform.android, TargetPlatform.iOS]
          .contains(defaultTargetPlatform)) {
        Future.delayed(const Duration(seconds: 5)).then((_) async {
          final canTrackDevice = generalBox.get(Keys.canTrackDevice) as bool?;
          if (canTrackDevice != true) {
            final perms =
                await areForegroundAndBackgroundLocationPermissionsGranted();
            print('Permissions are granted $perms');
            print('Can track device is $canTrackDevice');
            if (perms == true) {
              await initializeWorkManager();
              await generalBox.put(Keys.canTrackDevice, true);
              await prefs.setBool(Keys.canTrackDevice, true);
            } else {
              await generalBox.put(Keys.canTrackDevice, false);
              await prefs.setBool(Keys.canTrackDevice, false);
            }
          } else {
            await initializeWorkManager();
          }
        });
      } else {
        print('This is not an android or Ios device. No Tracking');
      }
    }
  }

  Future<bool> areForegroundAndBackgroundLocationPermissionsGranted() async {
    print('Checking permissions');
    PermissionStatus foregroundLocationPermission =
        await Permission.locationWhenInUse.status;
    print('foregroundLocationPermission: $foregroundLocationPermission');
    if (foregroundLocationPermission != PermissionStatus.granted) {
      foregroundLocationPermission =
          await Permission.locationWhenInUse.request();
    } else {
      print(
          'foregroundLocationPermission permanently: $foregroundLocationPermission');
    }

    PermissionStatus backgroundLocationPermission =
        await Permission.locationAlways.status;
    if (backgroundLocationPermission != PermissionStatus.granted) {
      backgroundLocationPermission = await Permission.locationAlways.request();
    }
    return foregroundLocationPermission.isGranted &&
        backgroundLocationPermission.isGranted;
  }

  Future<bool> scheduleIosPeriodicTask() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    await Future.delayed(const Duration(seconds: 10));
    await Workmanager().registerPeriodicTask(
        'fetchAndSaveLocationInBackgroundPeriodic',
        'fetchAndSaveLocationInBackgroundPeriodic',
        initialDelay: const Duration(seconds: 10),
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        inputData: {
          "taskName": "fetchAndSaveLocationInBackgroundPeriodic",
          "uniqueName": "fetchAndSaveLocationInBackgroundPeriodic"
        });
    return Future.value(true);
  }

  Future<bool> scheduleAndroidPeriodicTask() async {
    return scheduleIosPeriodicTask();
    // const int testAlarmId = 0;
    // await AndroidAlarmManager.periodic(
    //     const Duration(minutes: 1), testAlarmId, verifyAlarm,
    //     exact: true,
    //     wakeup: false,
    //     rescheduleOnReboot: true,
    //     allowWhileIdle: true);
    // return Future.value(true);
  }

  Future<bool> initializeWorkManager() async {
    if (!kIsWeb) {
      //await Future.delayed(const Duration(seconds: 2));
      final canTrackDevice = generalBox.get(Keys.canTrackDevice) as bool?;

      if (canTrackDevice == true) {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          return await scheduleIosPeriodicTask();
        } else if (defaultTargetPlatform == TargetPlatform.android) {
          return await scheduleAndroidPeriodicTask();
        } else {
          return Future.value(false);
        }
      } else if (canTrackDevice == false) {
        //await Workmanager().cancelAll();
        return Future.value(false);
      } else {
        //Get permissions to track device
        final perms =
            await areForegroundAndBackgroundLocationPermissionsGranted();
        if (perms == true) {
          if (defaultTargetPlatform == TargetPlatform.iOS) {
            return await scheduleIosPeriodicTask();
          } else if (defaultTargetPlatform == TargetPlatform.android) {
            return await scheduleAndroidPeriodicTask();
          }
          await generalBox.put(Keys.canTrackDevice, true);
          await prefs.setBool(Keys.canTrackDevice, true);
          Future.delayed(const Duration(seconds: 2)).then((value) {
            if (mounted) {
              print('Refreshing state');
              setState(() {});
            }
          });
          return Future.value(true);
        } else {
          return Future.value(false);
        }
      }
    } else {
      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(builder: (context) {
          final displayName = getNullableFirebaseAuthUser(context)?.displayName;
          if (displayName != null) {
            return Text('Welcome $displayName');
          }
          return const Text('Manage Your online devices');
        }),
      ),
      body: (currentIndex == 1)
          ? TrackingDeviceMediaList(
              trackingDeviceMedias: trackingDeviceMedias,
              onRefreshList: () {
                trackingDeviceMedias = (generalBox.get(Keys.trackingDeviceMedia)
                        as TrackingDeviceMedias?) ??
                    TrackingDeviceMedias(media: []);
                setState(() {});
              })
          : DefaultCenterContainer(
              children: <Widget>[
                Card(
                  elevation: 5,
                  //color: Colors.grey[300],
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Complete your account Setup',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.deepPurpleAccent, fontSize: 25)),
                      const SizedBox(height: 10),
                      ListTile(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10))),
                        tileColor: Colors.deepPurpleAccent.withOpacity(0.2),
                        leading: const SizedBox(
                          height: double.infinity,
                          width: 40,
                          child: Icon(
                            Icons.phone,
                            size: 40,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        title: const Text('Add a phone number'),
                        subtitle: const Text(
                            'We will text you critical alerts like '
                            'when your account is accessed from a new device.'),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SignInWithPhoneNumber(
                                    onGoBack: () {
                                      Navigator.of(context).pop();
                                    },
                                  )));
                        },
                      ),
                    ],
                  ),
                ),
                if (!kIsWeb &&
                    generalBox.get(Keys.canTrackDevice) == false) ...[
                  const SizedBox(height: 10),
                  ActionButton(
                      onPressed: () async {
                        final perms =
                            await areForegroundAndBackgroundLocationPermissionsGranted();
                        if (perms) {
                          await generalBox.put(Keys.canTrackDevice, true);

                          await prefs.setBool(Keys.canTrackDevice, true);
                          //final location = await Geolocation.getCurrentPosition();
                          await initializeWorkManager();
                        } else {
                          await openAppSettings();
                        }
                      },
                      text: 'Start Tracking This Device.'),
                ],
                const SizedBox(height: 10),
                ActionButton(
                    onPressed: () async {
                      await Workmanager().initialize(
                        callbackDispatcher,
                        isInDebugMode: false,
                      );
                      await Workmanager().registerOneOffTask(
                          'uniqueTestTaskName', 'uniqueTestTaskName',
                          initialDelay: const Duration(seconds: 10),
                          existingWorkPolicy: ExistingWorkPolicy.replace,
                          inputData: {"data1": "value1", "data2": "value2"});
                      // constraints:
                      //     Constraints(networkType: NetworkType.connected));
                    },
                    text: 'Schedule one off task'),
                const SizedBox(height: 10),
                ActionButton(
                    onPressed: () async {
                      await Workmanager().initialize(
                        callbackDispatcher,
                        isInDebugMode: false,
                      );
                      await Workmanager().registerPeriodicTask(
                          'fetchAndSaveLocationInBackgroundPeriodic',
                          'fetchAndSaveLocationInBackgroundPeriodic',
                          initialDelay: const Duration(seconds: 10),
                          frequency: const Duration(minutes: 15),
                          existingWorkPolicy: ExistingWorkPolicy.replace,
                          inputData: {
                            "taskName":
                                "fetchAndSaveLocationInBackgroundPeriodic",
                            "uniqueName":
                                "fetchAndSaveLocationInBackgroundPeriodic"
                          });
                      // constraints:
                      //     Constraints(networkType: NetworkType.connected));
                    },
                    text: 'Schedule periodic task'),
                const SizedBox(height: 10),
                ActionButton(
                    onPressed: () async {
                      await FirebaseMessaging.instance.getToken().then((value) {
                        print('Token is "$value"');
                      });
                      // Map<String, dynamic> inputData = {
                      //   'isAlarm': true,
                      //   'isolateId': 2,
                      //   'source': 'alarm'
                      // };
                      // final res = await ApiRequest.genericPostDict(
                      //     'test_background',
                      //     params: inputData);
                      // print(res);
                      // final timeStamp = DateTime.now().toUtc().millisecondsSinceEpoch;
                      // Map<String, dynamic> data = {
                      //   "timestamp": timeStamp,
                      //   "accuracy": "2.065999984741211",
                      //   "altitude": "183.1188113288452",
                      //   "altitude_accuracy": "12.438802719116211",
                      //   "heading": "0.0",
                      //   "heading_accuracy": "0.0",
                      //   "speed": "1.0650959940372319e-38",
                      //   "speed_accuracy": "1.0",
                      //   "is_mocked": false,
                      //   "email": "ndesamuelmbah@gmail.com",
                      //   "clientId":
                      //       "ndesamuelmbah@gmail.com/de4ebc2ebc64176e34826eecc80724cd",
                      //   "topic": "lu/ndesamuelmbah@gmail.com",
                      //   "deviceHash": "de4ebc2ebc64176e34826eecc80724cd",
                      //   "latatitude": "39.631045",
                      //   "lon": "-86.195215"
                      // };

                      // data = getCamelCaseLocationMap(data);
                      // var user = FirebaseAuthUser.fromString(
                      //     prefs.getString(Keys.firebaseAuthUser)!);
                      // print('User is $user');
                      // var deviceHash = prefs.getString(Keys.deviceHash);
                      // print('Device hash is $deviceHash');
                    },
                    text: 'Test Saving locations'),
                const SizedBox(height: 10),
                // ActionButton(
                //     onPressed: () async {
                //       final position = await Geolocator.getLastKnownPosition();
                //     },
                //     text: 'Print locations'),
                const SizedBox(height: 10),
                ActionButton(
                    onPressed: () async {
                      final perms =
                          await Addresses.getLocationPermissionsGeolocation();
                      if (perms != null) {
                        //final location = await Geolocation.getCurrentPosition();
                        const LocationSettings locationSettings =
                            LocationSettings(
                                accuracy: LocationAccuracy.high,
                                distanceFilter: 1);
                        //StreamSubscription<Position> positionStream =
                        Geolocator.getPositionStream(
                                locationSettings: locationSettings)
                            .listen((Position? position) {
                          if (position != null) {
                            final positionData = jsonEncode(position.toJson());
                            print(positionData);
                            mqttHandler
                                .publishDeviceLocation(position.toJson());
                            if (kDebugMode) {
                              print('Current position is $position}');
                            }
                          }
                        });
                      }
                    },
                    text: 'Start Streaming Location'),
                const SizedBox(height: 10),
                ActionButton(
                    onPressed: () async {
                      var p = generalBox.get(Keys.trackingDeviceMedia);
                      print('Tracking device media is $p');
                      print('Tracking device media lenght ${p.length()}');
                    },
                    text: 'Test Button'),
                const Text('Data received:',
                    style: TextStyle(color: Colors.black, fontSize: 25)),
                ValueListenableBuilder<String>(
                  builder: (BuildContext context, String value, Widget? child) {
                    return Text('$value',
                        style: const TextStyle(
                            color: Colors.deepPurpleAccent, fontSize: 35));
                  },
                  valueListenable: mqttHandler.data,
                )
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepPurple.shade100,
        selectedFontSize: 17,
        showSelectedLabels: true,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.deepPurpleAccent.withOpacity(0.5),
        //mainAxisAlignment: MainAxisAlignment.center,
        currentIndex: currentIndex,
        onTap: (value) {
          currentIndex = value;
          if (value == 0) {
            trackingDeviceMedias = (generalBox.get(Keys.trackingDeviceMedia)
                    as TrackingDeviceMedias?) ??
                TrackingDeviceMedias(media: []);
          }
          setState(() {});
        },
        items: const [
          BottomNavigationBarItem(
              label: "Home",
              icon: Icon(
                Icons.home,
                size: 30,
                //color: Colors.deepPurpleAccent,
              )),
          BottomNavigationBarItem(
            label: 'Tracking',
            icon: Icon(
              Icons.video_call,
              size: 30,
              //color: Colors.deepPurpleAccent,
            ),
          ),
        ],
      ),
    );
  }
}
// @pragma('vm:entry-point')
// void verifyAlarm() {
//   final int isolateId = Isolate.current.hashCode;
//   final DateTime now = DateTime.now();
//   print(
//       "[$now] Test Alarm is running in isolate=$isolateId function='$verifyAlarm'");
// }
// import 'dart:async';
// import 'dart:convert';

// // import 'package:background_fetch/background_fetch.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_mqtt_location_tracker/api/api_requests.dart';
// import 'package:flutter_mqtt_location_tracker/firebase_auth/firebase_auth_bloc.dart';
// import 'package:flutter_mqtt_location_tracker/location.dart';
// import 'package:flutter_mqtt_location_tracker/models/device_location.dart';
// import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
// import 'package:flutter_mqtt_location_tracker/mqtt_handler/mqtt_handler.dart';
// import 'package:flutter_mqtt_location_tracker/screens/signin_with_phone_number.dart';
// import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
// import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
// import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
// import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
// import 'package:flutter_mqtt_location_tracker/widgets/default_center_container.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get_it/get_it.dart';
// import 'package:logger/logger.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:workmanager/workmanager.dart';

// @pragma('vm:entry-point')
// Future<void> fetchAndSaveLocationInBackground(
//     {Map<String, dynamic> userInput = const {}}) async {
//   final SharedPreferences bgPref = await SharedPreferences.getInstance();

//   final canTrackDevice = bgPref.getBool(Keys.canTrackDevice) as bool?;
//   var keys = bgPref.getKeys().toList();
//   if (canTrackDevice == true) {
//     // logger.d("INSIDE BACKGROUND TASK: Can track device is true");

//     DeviceLocations devicePositions = DeviceLocations.fromListString(
//         bgPref.getStringList(Keys.devicePositionsList) ?? []);
//     Position? position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.best);
//     double distanceFromLastPosition =
//         devicePositions.getDistanceFromPosition(currentPosition: position) ?? 0;
//     if (position != null && distanceFromLastPosition >= 1.0) {
//       try {
//         var authUserString = bgPref.getString(Keys.firebaseAuthUser) ?? '';
//         var authUser = FirebaseAuthUser.fromString(authUserString);
//         var deviceHash = bgPref.getString(Keys.deviceHash) ?? '';
//         final topicLocationUpdates = 'lu/${authUser.email}';
//         final clientId = '${authUser.email}/$deviceHash';
//         final email = authUser.email;
//         var positionMap = position.toJson();
//         positionMap.addAll(userInput);
//         const postHeader =
//             String.fromEnvironment('HEADERS', defaultValue: 'HEADERS_NOT_SET');
//         var environmentHeaders =
//             bgPref.getStringList(Keys.environmentHeadersFetchedList) ?? [];
//         // if (postHeader == 'HEADERS_NOT_SET') {
//         //   int l = environmentHeaders.length;
//         //   if (l > 10) {
//         //     environmentHeaders = environmentHeaders.sublist(l - 9);
//         //     environmentHeaders.add(postHeader);
//         //   }
//         // }
//         environmentHeaders.add(postHeader);
//         await bgPref.setStringList(
//             Keys.environmentHeadersFetchedList, environmentHeaders);
//         positionMap.addAll({
//           'email': email,
//           'clientId': clientId,
//           'topic': topicLocationUpdates,
//           'deviceHash': deviceHash,
//           'lat': position.latitude,
//           'lon': position.longitude,
//           'header': postHeader,
//           'keys': keys
//         });
//         positionMap.removeWhere(
//             (key, value) => (value ?? '').toString().isNullOrWhiteSpace);
//         positionMap = getCamelCaseLocationMap(positionMap);
//         if (!positionMap.containsKey('timestamp')) {
//           positionMap['timestamp'] =
//               DateTime.now().toUtc().millisecondsSinceEpoch;
//         }
//         final inputJson = {"inputData": positionMap};
//         final output = await ApiRequest.genericPostDict(
//             'publish_mobile_app_location',
//             params: inputJson);
//         if (output != null) {
//           positionMap.addAll({'timestamp': output['timestamp']});
//           devicePositions.add(DeviceLocation.fromJson(positionMap));
//           var devicePositionsStringList = devicePositions.toStringList();
//           await bgPref.setStringList(
//               Keys.devicePositionsList, devicePositionsStringList);
//           // logger.d('INSIDE BACKGROUND TASK: Error In Bclock data to server $e');
//         }
//       } catch (e, s) {
//         // logger.d('INSIDE BACKGROUND TASK: Error In Bclock data to server $e');
//         // logger.d(
//         //     'INSIDE BACKGROUND TASK: Stacktrace In Bclock data to server $s');
//       }
//     } else {
//       // logger.d(
//       //     "INSIDE BACKGROUND TASK: Device is not far from current position distanceFromLastPosition $distanceFromLastPosition");
//     }
//   } else {
//     // logger.d(
//     //     "INSIDE BACKGROUND TASK: Can track device is null. Can not track device");
//   }
// }

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((
//     task,
//     inputData,
//   ) async {
//     final loggers = Logger();
//     loggers.d('In background tasks for task $task and input data $inputData');
//     await fetchAndSaveLocationInBackground(userInput: inputData!);
//     return Future.value(true);
//   });
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   MqttHandler mqttHandler = MqttHandler();
//   final generalBox = GetIt.I<GeneralBox>();

//   final SharedPreferences prefs = GetIt.I<SharedPreferences>();

//   @override
//   void initState() {
//     super.initState();
//     if (!kIsWeb) {
//       Future.delayed(const Duration(seconds: 5)).then((_) async {
//         final canTrackDevice = generalBox.get(Keys.canTrackDevice) as bool?;
//         if (canTrackDevice != true) {
//           final perms =
//               await areForegroundAndBackgroundLocationPermissionsGranted();
//           print('Permissions are granted $perms');

//           print('Can track device is $canTrackDevice');
//           if (perms == true) {
//             await initializeWorkManager();
//             await generalBox.put(Keys.canTrackDevice, true);
//             await prefs.setBool(Keys.canTrackDevice, true);
//           } else {
//             await generalBox.put(Keys.canTrackDevice, false);
//             await prefs.setBool(Keys.canTrackDevice, false);
//           }
//         } else {
//           await initializeWorkManager();
//         }
//       });
//     }
//   }

//   Future<bool> areForegroundAndBackgroundLocationPermissionsGranted() async {
//     print('Checking permissions');
//     PermissionStatus foregroundLocationPermission =
//         await Permission.locationWhenInUse.status;
//     print('foregroundLocationPermission: $foregroundLocationPermission');
//     if (foregroundLocationPermission != PermissionStatus.granted) {
//       foregroundLocationPermission =
//           await Permission.locationWhenInUse.request();
//     } else {
//       print(
//           'foregroundLocationPermission permanently: $foregroundLocationPermission');
//     }

//     PermissionStatus backgroundLocationPermission =
//         await Permission.locationAlways.status;
//     if (backgroundLocationPermission != PermissionStatus.granted) {
//       backgroundLocationPermission = await Permission.locationAlways.request();
//     }
//     return foregroundLocationPermission.isGranted &&
//         backgroundLocationPermission.isGranted;
//   }

//   Future<bool> initializeWorkManager() async {
//     if (!kIsWeb) {
//       //await Future.delayed(const Duration(seconds: 2));
//       final canTrackDevice = generalBox.get(Keys.canTrackDevice) as bool?;

//       if (canTrackDevice == true) {
//         await Workmanager()
//             .initialize(
//               callbackDispatcher,
//               isInDebugMode: false,
//             )
//             .catchError((e, s) {});
//         await Workmanager().registerPeriodicTask(
//             'fetchAndSaveLocationInBackgroundPeriodic',
//             'fetchAndSaveLocationInBackgroundPeriodic',
//             //constraints: Constraints(networkType: NetworkType.connected),
//             initialDelay: const Duration(seconds: 10),
//             frequency: const Duration(minutes: 15),
//             existingWorkPolicy: ExistingWorkPolicy.replace,
//             inputData: {
//               "taskName": "fetchAndSaveLocationInBackgroundPeriodic",
//               "uniqueName": "fetchAndSaveLocationInBackgroundPeriodic"
//             });
//         return Future.value(true);
//       } else if (canTrackDevice == false) {
//         //await Workmanager().cancelAll();
//         return Future.value(false);
//       } else {
//         //Get permissions to track device
//         final perms =
//             await areForegroundAndBackgroundLocationPermissionsGranted();
//         if (perms == true) {
//           await Workmanager()
//               .initialize(
//                 callbackDispatcher,
//                 isInDebugMode: false,
//               )
//               .catchError((e, s) {});
//           await Workmanager().registerPeriodicTask(
//               'fetchAndSaveLocationInBackgroundPeriodic',
//               'fetchAndSaveLocationInBackgroundPeriodic',
//               //constraints: Constraints(networkType: NetworkType.connected),
//               initialDelay: const Duration(seconds: 10),
//               frequency: const Duration(minutes: 15),
//               existingWorkPolicy: ExistingWorkPolicy.replace,
//               inputData: {
//                 "taskName": "fetchAndSaveLocationInBackgroundPeriodic",
//                 "uniqueName": "fetchAndSaveLocationInBackgroundPeriodic"
//               });
//           await generalBox.put(Keys.canTrackDevice, true);
//           return Future.value(true);
//         } else {
//           return Future.value(false);
//         }
//       }
//     } else {
//       return Future.value(false);
//     }
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
//           if (!kIsWeb) ...[
//             FutureBuilder<Object>(
//                 future: buildingFuture(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState != ConnectionState.done ||
//                       snapshot.hasError ||
//                       !snapshot.hasData) {
//                     print('Error initializing work manager: ${snapshot.error}');
//                     return const SizedBox.shrink();
//                   }
//                   final canTrack = snapshot.data as bool;
//                   if (canTrack) {
//                     Workmanager().registerPeriodicTask(
//                         'fetchAndSaveLocationInBackgroundPeriodic',
//                         'fetchAndSaveLocationInBackgroundPeriodic',
//                         initialDelay: const Duration(seconds: 10),
//                         frequency: const Duration(minutes: 15),
//                         existingWorkPolicy: ExistingWorkPolicy.replace,
//                         inputData: {
//                           "taskName":
//                               "fetchAndSaveLocationInBackgroundPeriodic",
//                           "uniqueName":
//                               "fetchAndSaveLocationInBackgroundPeriodic"
//                         }).then((_) => print(
//                         'Periodic Task background Scheduled. Workmanager initialized'));
//                     return const SizedBox.shrink();
//                   } else {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 10.0),
//                       child: ActionButton(
//                           onPressed: () async {
//                             final perms =
//                                 await areForegroundAndBackgroundLocationPermissionsGranted();
//                             if (perms) {
//                               await generalBox.put(Keys.canTrackDevice, true);
//                               //final location = await Geolocation.getCurrentPosition();
//                               await initializeWorkManager();
//                             } else {
//                               await openAppSettings();
//                             }
//                           },
//                           text: 'Start Tracking This Device.'),
//                     );
//                   }
//                 })
//           ],
//           const SizedBox(height: 10),
//           ActionButton(
//               onPressed: () async {
//                 await Workmanager().initialize(
//                   callbackDispatcher,
//                   isInDebugMode: false,
//                 );
//                 await Workmanager().registerOneOffTask(
//                     'uniqueTestTaskName', 'uniqueTestTaskName',
//                     initialDelay: const Duration(seconds: 10),
//                     existingWorkPolicy: ExistingWorkPolicy.replace,
//                     inputData: {"data1": "value1", "data2": "value2"});
//                 // constraints:
//                 //     Constraints(networkType: NetworkType.connected));
//               },
//               text: 'Schedule one off task'),
//           const SizedBox(height: 10),
//           ActionButton(
//               onPressed: () async {
//                 await Workmanager().initialize(
//                   callbackDispatcher,
//                   isInDebugMode: false,
//                 );
//                 await Workmanager().registerPeriodicTask(
//                     'fetchAndSaveLocationInBackgroundPeriodic',
//                     'fetchAndSaveLocationInBackgroundPeriodic',
//                     initialDelay: const Duration(seconds: 10),
//                     frequency: const Duration(minutes: 15),
//                     existingWorkPolicy: ExistingWorkPolicy.replace,
//                     inputData: {
//                       "taskName": "fetchAndSaveLocationInBackgroundPeriodic",
//                       "uniqueName": "fetchAndSaveLocationInBackgroundPeriodic"
//                     });
//                 // constraints:
//                 //     Constraints(networkType: NetworkType.connected));
//               },
//               text: 'Schedule periodic task'),
//           const SizedBox(height: 10),
//           ActionButton(
//               onPressed: () async {
//                 final timeStamp = DateTime.now().toUtc().millisecondsSinceEpoch;
//                 Map<String, dynamic> data = {
//                   "timestamp": timeStamp,
//                   "accuracy": "2.065999984741211",
//                   "altitude": "183.1188113288452",
//                   "altitude_accuracy": "12.438802719116211",
//                   "heading": "0.0",
//                   "heading_accuracy": "0.0",
//                   "speed": "1.0650959940372319e-38",
//                   "speed_accuracy": "1.0",
//                   "is_mocked": false,
//                   "email": "ndesamuelmbah@gmail.com",
//                   "clientId":
//                       "ndesamuelmbah@gmail.com/de4ebc2ebc64176e34826eecc80724cd",
//                   "topic": "lu/ndesamuelmbah@gmail.com",
//                   "deviceHash": "de4ebc2ebc64176e34826eecc80724cd",
//                   "latatitude": "39.631045",
//                   "lon": "-86.195215"
//                 };

//                 data = getCamelCaseLocationMap(data);
//                 var user = FirebaseAuthUser.fromString(
//                     prefs.getString(Keys.firebaseAuthUser)!);
//                 print('User is $user');
//                 var deviceHash = prefs.getString(Keys.deviceHash);
//                 print('Device hash is $deviceHash');
//               },
//               text: 'Test Saving locations'),
//           const SizedBox(height: 10),
//           // ActionButton(
//           //     onPressed: () async {
//           //       final position = await Geolocator.getLastKnownPosition();
//           //     },
//           //     text: 'Print locations'),
//           const SizedBox(height: 10),
//           ActionButton(
//               onPressed: () async {
//                 final perms =
//                     await Addresses.getLocationPermissionsGeolocation();
//                 if (perms != null) {
//                   //final location = await Geolocation.getCurrentPosition();
//                   const LocationSettings locationSettings = LocationSettings(
//                       accuracy: LocationAccuracy.high, distanceFilter: 1);
//                   //StreamSubscription<Position> positionStream =
//                   Geolocator.getPositionStream(
//                           locationSettings: locationSettings)
//                       .listen((Position? position) {
//                     if (position != null) {
//                       final positionData = jsonEncode(position.toJson());
//                       print(positionData);
//                       mqttHandler.publishDeviceLocation(position.toJson());
//                       if (kDebugMode) {
//                         print('Current position is $position}');
//                       }
//                     }
//                   });
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
