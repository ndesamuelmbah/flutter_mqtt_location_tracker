import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_mqtt_location_tracker/screens/signin_with_phone_number.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';

class SignoutScreen extends StatelessWidget {
  const SignoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('You are now Signed Out'),
      ),
      body: Center(
        child: Container(
          constraints: mobileScreenBox,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You have successfully already signed out.'),
              const SizedBox(height: 306),
              ActionButton(
                text: 'Sign In',
                color: Colors.green,
                onPressed: () async {
                  await FirebaseAuth.instance
                      .signInAnonymously()
                      .then((value) => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) {
                                return SignInWithPhoneNumber(
                                  onGoBack: () {},
                                );
                              },
                            ),
                          ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
