import 'dart:isolate';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_center_container.dart';

// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0

class ChooseAnAuthenticationMethod extends StatelessWidget {
  const ChooseAnAuthenticationMethod(
      {super.key,
      required this.screenHeight,
      required this.onSigninWithEmailAndPassword,
      required this.onSignup,
      required this.onSigninWithPhoneNumber});
  final double screenHeight;
  final VoidCallback onSignup;
  final VoidCallback onSigninWithEmailAndPassword;
  final VoidCallback onSigninWithPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return DefaultCenterContainer(
      children: [
        SizedBox(height: screenHeight * 0.05),
        const Center(
          child: Text(
            'Choose and option to sign in',
            style: TextStyle(fontSize: 20),
          ),
        ),
        // const SizedBox(height: 10),
        // ActionButton(
        //     onPressed: () async {
        //       String env = const String.fromEnvironment('HEADERS');
        //       print(env[1]);
        //       print('Environment is $env');
        //     },
        //     text: 'Test Environment Variables'),
        const SizedBox(height: 16),
        ActionButton(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
          text: 'Sign in with email and password',
          onPressed: () {
            onSigninWithEmailAndPassword();
          },
        ),
        const SizedBox(height: 16),
        ActionButton(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
          text: 'Test Getting isolate',
          onPressed: () {
            print(
                'Test Alarm is running in isolate= ${Isolate.current.hashCode};');
          },
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'OR',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        ActionButton(
          fontWeight: FontWeight.bold,
          text: 'Create a free Account for Me',
          onPressed: () {
            onSignup();
          },
        ),

        const SizedBox(height: 16),
        ActionButton(
            text: 'Test Firebase',
            onPressed: () async {
              print('Test Firebase');
              // final player = AudioPlayer();
              // await player.play(AssetSource('sounds/papaandmama.mp3'));
              // int alarmId = 0;
              // await AndroidAlarmManager.periodic(
              //     const Duration(minutes: 1), alarmId, verifyAlarm);

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
              //   "latitude": "39.631045",
              //   "lon": "-86.195215"
              // };
              // data.forEach((key, value) {
              //   print('$key: ${key.toCamelCase}');
              // });
              // data = getCamelCaseLocationMap(data);
              // final inputJson = {"inputData": data};
              // final inputStr = jsonEncode(inputJson);
              // print('Started ith input $inputStr');
              // final res = await ApiRequest.genericPostDict('test_background',
              //     params: inputJson);
              // print(res);

              // final user = FirebaseAuth.instance.currentUser;
              // if (user != null) {
              //   print(user.uid);
              //   var authUser = FirebaseAuthUser.fromCurrentUser(user);
              //   var jsonUser = authUser.toJson();
              //   print(jsonUser);
              //   jsonUser.removeWhere((key, value) =>
              //       (value ?? '').toString().isNullOrWhiteSpace);
              //   print(jsonUser);
              // }

              // await ApiRequest.genericGet('ping_api').then((value) {
              //   print(value);
              // });
              // var deviceInfo = await getDeviceInfo(customHashPrefix: 'T');
              // print(deviceInfo); // final Uri emailLaunchUri = Uri(
              //   scheme: 'mailto',
              //   path: 'ndesamuelmbah@gmail.com',
              // );
              // print(emailLaunchUri);
              // if (await canLaunchUrl(emailLaunchUri)) {
              //   await launchUrl(emailLaunchUri);
              // }
              print('Test Firebase 2');
            })
      ],
    );
  }
}
