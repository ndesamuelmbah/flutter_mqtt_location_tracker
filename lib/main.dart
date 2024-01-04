import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_mqtt_location_tracker/models/device_location.dart';
import 'package:flutter_mqtt_location_tracker/models/tracking_device_media.dart';
import 'package:flutter_mqtt_location_tracker/screens/authentication_screen.dart';
import 'package:flutter_mqtt_location_tracker/screens/home_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mqtt_location_tracker/api/http_overrides.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/firebase_auth/auth_handler.dart';
import 'package:flutter_mqtt_location_tracker/firebase_auth/firebase_auth_bloc.dart';
import 'package:flutter_mqtt_location_tracker/firebase_options.dart';
import 'package:flutter_mqtt_location_tracker/models/custom_auth_provider.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter_mqtt_location_tracker/models/pending_authentications.dart';
import 'package:flutter_mqtt_location_tracker/screens/enter_user_name.dart';
// import 'package:flutter_mqtt_location_tracker/screens/home_screen.dart';
import 'package:flutter_mqtt_location_tracker/screens/splash_screen.dart';
import 'package:flutter_mqtt_location_tracker/services/firebase_services.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:flutter_mqtt_location_tracker/utils/strings.dart';
import 'package:flutter_mqtt_location_tracker/models/envvars.dart';

//flutter clean && flutter pub get && flutter build web --release && firebase deploy
//The method below is used for communicating status of Customers.
//This is only useful when customers are discussing with customer support.
//flutter build apk --release --dart-define-from-file .env/envVars.json
final audioPlayer = AudioPlayer();
Future<void> playNotificationSound(RemoteMessage? message) async {
  if (message != null) {
    var data = message.data;
    if (!data.containsKey('s3Url')) {
      //String? sound = message.notification?.android?.sound;
      var sounds = ['papaandmama', 'papaandshiphrah', 'papaonly'];
      int index = DateTime.now().second % 3;
      var sound = sounds[index];
      await audioPlayer.play(AssetSource('sounds/$sound.mp3'));
    } else {
      await saveNotification(data);
    }

    print(
        'Notification must be played now data = $data and map = ${message.toMap()}');
  }
}

Future<void> saveNotification(Map<String, dynamic>? notificationData) async {
  if (notificationData != null) {
    final generalBox = GeneralBox();
    await generalBox.openBox();
    final notificationMedia = TrackingDeviceMedia.fromJson(notificationData);
    TrackingDeviceMedias savedNotifications =
        (generalBox.get(Keys.trackingDeviceMedia) as TrackingDeviceMedias?) ??
            TrackingDeviceMedias(media: []);
    if (!savedNotifications.contains(notificationMedia)) {
      // final dio = Dio();
      // String downloadedMediaFolder = (await getTemporaryDirectory()).path;
      // if (!downloadedMediaFolder.endsWith('/')) {
      //   downloadedMediaFolder =
      //       '$downloadedMediaFolder/${Keys.downloadedMedia}/';
      // }
      // final filePath =
      //     '$downloadedMediaFolder${notificationMedia.s3Url.split('/').last}';
      // try {
      //   final response = await dio.download(
      //     notificationMedia.s3Url,
      //     filePath,
      //   );
      //   if (response.statusCode == 200) {
      //     notificationMedia.localPath = filePath;
      //   }
      // } catch (e, s) {
      //   //print('Error downloading file $e $s');
      // }
      savedNotifications.add(notificationMedia);
      await generalBox.put(Keys.trackingDeviceMedia, savedNotifications);
    }
  }
}

const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
    'papaonly', // id
    "Notifications With Papa's Voice", // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('papaonly'),
    enableLights: true);

const AndroidNotificationChannel papaAndMama = AndroidNotificationChannel(
    'papaandmama', // id
    "Notifications With Papa and Mama's Voice", // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('papaandmama'),
    enableLights: true);

const AndroidNotificationChannel childrenNotificationChannel =
    AndroidNotificationChannel(
        'papaandshiphrah', // id
        "Notifications With Shiphrah's Voice", // title
        description:
            'We use this channel to inform you when someone sends you a message on Duka Foods', // description
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('papaandshiphrah'),
        enableLights: true);

AndroidNotificationChannel getAndroidNotificationChannel(String sound) {
  var now = DateTime.now();
  int index = now.second % 3;
  if (index == 0) {
    return defaultChannel;
  }
  return index == 1 ? childrenNotificationChannel : papaAndMama;
}

Future notifyOnlineStatus(FirebaseAuthUser user,
    {bool isOnline = true, String message = 'Notifying online Status'}) async {
  FirestoreDB.customersRef.doc(user.uid).update({
    'isOnline': isOnline,
    'lastTimeChecked': getUtcNow().millisecondsSinceEpoch
  });
}

Future setupHive() async {
  //flutter packages pub run build_runner build --delete-conflicting-outputs
  await Hive.initFlutter();
  Hive.registerAdapter(CustomAuthProviderAdapter());
  Hive.registerAdapter(EnvVarsAdapter());
  Hive.registerAdapter(FirebaseAuthUserAdapter());
  Hive.registerAdapter(FirebaseAuthUsersAdapter());
  Hive.registerAdapter(PendingAuthenticationsAdapter());
  Hive.registerAdapter(DeviceLocationAdapter());
  Hive.registerAdapter(DeviceLocationsAdapter());
  Hive.registerAdapter(TrackingDeviceMediaAdapter());
  Hive.registerAdapter(TrackingDeviceMediasAdapter());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background remote notification ${message.notification?.toMap()}');
  playNotificationSound(message);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await setupHive();
  } catch (e, s) {
    print('Error setting up hive $e $s');
  }
  if (!kIsWeb) {
    await setupFlutterLocalNotifications();
    showFlutterLocalNotification(message);
  } else {
    print('Implement handling background remote notification on web');
  }
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
// late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterLocalNotifications() async {
  if (isFlutterLocalNotificationsInitialized || kIsWeb) {
    return;
  }
  if (Platform.isIOS) {
    await getIt<FirebaseService>()
        .firebaseMessaginInst
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  } else if (Platform.isAndroid) {
    var channelList = [
      childrenNotificationChannel,
      defaultChannel,
      papaAndMama
    ];
    await Future.forEach(channelList,
        (AndroidNotificationChannel channel) async {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    });
  }

  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterLocalNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    AndroidNotificationChannel channel =
        getAndroidNotificationChannel(android.sound ?? "");
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'launch_background',
        ),
      ),
    );
    print('Notification must be shown now');
  }
}

AndroidNotificationDetails getAndroidSpecifics(
    AndroidNotificationChannel notifChannel) {
  return AndroidNotificationDetails(notifChannel.id, notifChannel.name,
      channelDescription: notifChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: 'launcher_icon',
      playSound: true,
      enableLights: true,
      sound: notifChannel.sound,
      largeIcon: const DrawableResourceAndroidBitmap('launcher_icon'));
}

void showNotification(NotificationDetails notificationsAndroidSpecifics,
    RemoteNotification? notification, String? payload) {
  flutterLocalNotificationsPlugin.show(notification.hashCode,
      notification?.title, notification?.body, notificationsAndroidSpecifics,
      payload: payload);
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
// late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  int start = DateTime.now().millisecondsSinceEpoch;
  await AndroidAlarmManager.initialize();

  print('Alarm after ${DateTime.now().millisecondsSinceEpoch - start} ms.');
  start = DateTime.now().millisecondsSinceEpoch;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupHive();
  print('GitInit after ${DateTime.now().millisecondsSinceEpoch - start} ms.');
  await ServiceLocator().setupLocator();
  final getIt = GetIt.I;
  await getIt.allReady();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    FirebaseMessaging _firebaseMessaging =
        getIt<FirebaseService>().firebaseMessaginInst;
    AndroidInitializationSettings initialzationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/launcher_icon');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(onDidReceiveLocalNotification: (
      int id,
      String? title,
      String? body,
      String? payload,
    ) async {
      print('onDidReceiveLocalNotification $id $title $body $payload');
      if (payload != null) {
        try {
          final map = json.decode(payload) as Map<String, dynamic>;
          if (map.isNotEmpty) {
            //saveNotification(map);
          }
        } catch (_) {}
      }
    });
    InitializationSettings initializationSettings = InitializationSettings(
        android: initialzationSettingsAndroid, iOS: initializationSettingsIOS);
    if (!kIsWeb) {
      flutterLocalNotificationsPlugin.initialize(initializationSettings);
    }

    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) async {
      await playNotificationSound(message);
      Map<String, dynamic>? notificationData = message?.data;
      print('getInitialMessage notificationData == $notificationData');
      if (notificationData?.isNotEmpty == true) {
        //saveNotification(notificationData!);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('getInitialMessage notificationData == ${message.data}');

      await playNotificationSound(message);

      if (message.data.isNotEmpty == true) {
        //saveNotification(message.data);
      }
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? apple = message.notification?.apple;
      print('Android notification ${android?.toMap()}');
      if (android != null && Platform.isAndroid) {
        AndroidNotificationChannel myChannel =
            getAndroidNotificationChannel(android.sound ?? "");

        AndroidNotificationDetails androidSpecifics =
            getAndroidSpecifics(myChannel);
        NotificationDetails notificationsAndroidSpecifics =
            NotificationDetails(android: androidSpecifics);
        showNotification(notificationsAndroidSpecifics, notification,
            jsonEncode(message.data));
      } else if (apple != null && Platform.isIOS) {
        //AppleNotificationSound appleNotificationSound = const AppleNotificationSound(critical: true, volume: 0.9);
        DarwinNotificationDetails iosNotificationDetails =
            DarwinNotificationDetails(
                presentAlert: true,
                presentSound: true,
                subtitle: apple.subtitle);
        NotificationDetails notificationsAndroidSpecifics =
            NotificationDetails(iOS: iosNotificationDetails);
        showNotification(notificationsAndroidSpecifics, notification,
            jsonEncode(message.data));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      Map<String, dynamic> notificationData = message.data;
      print('onMessageOpenedApp notificationData == $notificationData');

      await playNotificationSound(message);
      // if (notificationData.isNotEmpty) {
      //   saveNotification(notificationData);
      // }
    });

    // _firebaseMessaging.onTokenRefresh
    //     .listen(LoginRepo.saveNewDevicesToDatabase);
    final newStart = DateTime.now().millisecondsSinceEpoch;
    await setupFlutterLocalNotifications();
    print(
        'setupFlutterLocalNotifications after ${DateTime.now().millisecondsSinceEpoch - newStart} ms.');
  }
  print(
      'Firebase.initializeApp after ${DateTime.now().millisecondsSinceEpoch - start}ms.');
  Logger.root.onRecord.listen((record) {
    final data = {
      'level': record.level.name,
      'loggerName': record.loggerName,
      'error': record.error?.toString(),
      'time': record.time.millisecondsSinceEpoch,
      'message': record.message,
      'stackTrace': record.stackTrace?.toString(),
      'zone': record.zone?.toString(),
      'sequenceNumber': record.sequenceNumber,
      'object': record.object?.toString(),
    };
    FirestoreDB.logsRef
        .doc(record.time.toUtc().toString())
        .set(data)
        .catchError((_) async {
      Future.delayed(const Duration(seconds: 5)).then((value) {
        print(
            'Waited for 5 secs ${record.time.millisecondsSinceEpoch} ${DateTime.now().millisecondsSinceEpoch}');
        FirestoreDB.logsRef
            .doc(record.time.millisecondsSinceEpoch.toString())
            .set(data);
      });
    });
  });
  AuthHandler();
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();
final routeObserver = RouteObserver<ModalRoute<void>>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget navigateToHome() {
    final generalbox = GetIt.I<GeneralBox>();
    final user = generalbox.get(Keys.firebaseAuthUser) as FirebaseAuthUser?;
    if (user == null) {
      return const AuthenticationScreen();
      //return const BackgroundLocationTest();
    } else {
      notifyOnlineStatus(user, message: 'Starting app online status');
      final name = user.displayName;
      if (name?.isNullOrWhiteSpace == true) {
        return const EnterUserNameScreen();
      }
      bool hasCompletedAuth = user.email.isNotNullAndNotEmpty;
      if (hasCompletedAuth) {
        return const HomeScreen();
      }
      return const EnterUserNameScreen();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider<FirebaseAuthBloc>(
          create: (BuildContext context) =>
              FirebaseAuthBloc()..add(AutoLogin()),
        ),
      ],
      child: BlocListener<FirebaseAuthBloc, AuthState>(
        listener: (BuildContext context, state) {
          if (state is Authenticated) {
            print('State is Authenticated');
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => navigateToHome()),
              (route) => false,
            );
          }
          if (state is UnAuthenticated) {
            print('State is UnAuthenticated');
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => navigateToHome()),
              (route) => false,
            );
          }
        },
        child: MaterialApp(
          title: Strings.appName,
          navigatorKey: navigatorKey,
          navigatorObservers: [
            routeObserver,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const SplashScreen(appName: Strings.appName),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}


// import 'dart:async';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_mqtt_location_tracker/firebase_options.dart';
// import 'package:flutter_mqtt_location_tracker/location.dart';
// import 'package:flutter_mqtt_location_tracker/mqtt_handler/mqtt_handler.dart';
// import 'package:flutter_mqtt_location_tracker/screens/authentication_screen.dart';
// import 'package:geolocator/geolocator.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//           useMaterial3: true,
//         ),
//         home: AuthenticationScreen() // MyStatefulWidget(),
//         );
//   }
// }

// class MyStatefulWidget extends StatefulWidget {
//   const MyStatefulWidget({super.key});

//   @override
//   State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
// }

// class _MyStatefulWidgetState extends State<MyStatefulWidget> {
//   int _count = 0;
//   MqttHandler mqttHandler = MqttHandler();

//   @override
//   void initState() {
//     super.initState();
//     mqttHandler.connect();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sample Code'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//                 onPressed: () async {
//                   final perms =
//                       await Addresses.getLocationPermissionsGeolocation();
//                   if (perms != null) {
//                     final position = await Geolocator.getCurrentPosition(
//                         desiredAccuracy: LocationAccuracy.high);
//                     mqttHandler.subscribeToLocation();
//                   }
//                 },
//                 child: Text('Subscribe to Location')),
//             ElevatedButton(
//                 onPressed: () async {
//                   //final location = await Geolocation.getCurrentPosition();
//                   final LocationSettings locationSettings = LocationSettings(
//                     accuracy: LocationAccuracy.high,
//                     distanceFilter: 1,
//                   );
//                   StreamSubscription<Position> positionStream =
//                       Geolocator.getPositionStream(
//                               locationSettings: locationSettings)
//                           .listen((Position? position) {
//                     mqttHandler.publishMessage(
//                         (position ?? 'unknown').toString(),
//                         topic: 'LU');
//                     print('Current position is ${position ?? 'unknown'}}');
//                   });
//                   //final location = await mqttHandler.getLocation();
//                 },
//                 child: Text('Start Streaming Location')),
//             const Text('Data received:',
//                 style: TextStyle(color: Colors.black, fontSize: 25)),
//             ValueListenableBuilder<String>(
//               builder: (BuildContext context, String value, Widget? child) {
//                 return Text('$value',
//                     style: const TextStyle(
//                         color: Colors.deepPurpleAccent, fontSize: 35));
//               },
//               valueListenable: mqttHandler.data,
//             )
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => setState(() => _count++),
//         tooltip: 'Increment Counter',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
