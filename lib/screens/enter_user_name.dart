import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_mqtt_location_tracker/screens/home_screen_with_bg.dart';
import 'package:get_it/get_it.dart';

import 'package:logging/logging.dart';
import 'package:flutter_mqtt_location_tracker/api/api_requests.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter_mqtt_location_tracker/models/registered_phone_numbers.dart';
import 'package:flutter_mqtt_location_tracker/screens/home_screen.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/form_validators.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:flutter_mqtt_location_tracker/utils/toast_messages.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_center_container.dart';
import 'package:flutter_mqtt_location_tracker/widgets/progress_indicator.dart';

class EnterUserNameScreen extends StatefulWidget {
  const EnterUserNameScreen({super.key});

  @override
  EnterUserNameScreenState createState() => EnterUserNameScreenState();
}

class EnterUserNameScreenState extends State<EnterUserNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  final generalBox = GetIt.I<GeneralBox>();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void updateUserName(String userName) async {
    _isLoading = true;
    setState(() {});

    try {
      // Update user profile data in Firestore
      User? user = FirebaseAuth.instance.currentUser;
      userName = bautifyName(userName);
      if (user != null) {
        final userRef = FirestoreDB.customersRef.doc(user.uid);
        final savedUser = generalBox.get(Keys.firebaseAuthUser) ??
            FirebaseAuthUser.fromCurrentUser(user);
        Map<String, dynamic> firebaseAuthUserMap = savedUser.toJson();

        generalBox.put(Keys.firebaseAuthUser,
            FirebaseAuthUser.fromJson(firebaseAuthUserMap));
        // getFirebaseAuthUser(context).isTreasury
        // print('User Extracted and saved as $firebaseAuthUserMap');
        //await Future.delayed(const Duration(seconds: 5));
        await userRef.set(firebaseAuthUserMap, SetOptions(merge: true));
        // ApiRequest.genericPost('update_user_claims', params: params)
        //     .then((value) {});
        await user.updateDisplayName(userName);
        var updatedUser = await userRef.get();
        final firebaseUserMap = updatedUser.data()! as Map<String, dynamic>;
        // print('final firebaseUserMap $firebaseUserMap');
        generalBox.put(
            Keys.firebaseAuthUser, FirebaseAuthUser.fromJson(firebaseUserMap));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
      }
    } catch (error, stackTrace) {
      showErrorToast('Failed to update profile');
      Logger('enterUserName').severe(error, stackTrace);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          'Add Your Name',
          textAlign: TextAlign.center,
        )),
      ),
      body: SingleChildScrollView(
          child: DefaultCenterContainer(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  decoration: containerDecoration,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _usernameController,
                    keyboardType: TextInputType.name,
                    decoration: //InputDecoration(labelText: 'Username'),
                        const InputDecoration(
                      labelText: 'Enter Your Name',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8.0),
                    ),
                    validator: validateName,
                  ),
                ),
                const SizedBox(height: 16.0),
                _isLoading
                    ? const LoadingProgressIndicator()
                    : ActionButton(
                        text: 'Save Your Name',
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                        radius: 15,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            String userName = _usernameController.text;
                            updateUserName(userName);
                          }
                        },
                      ),
              ],
            ),
          )
        ],
      )),
    );
  }
}
