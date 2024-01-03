import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:get_it/get_it.dart';

import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/get_device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHandler {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Constructor
  AuthHandler() {
    // Listen to the onAuthStateChanged stream
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is signed in, run your method here
        // This method will be triggered every time a user successfully signs in
        handleAuthChangeWithUser(user);
      }
    });
  }

  // Method to be triggered on successful sign-in
  void handleAuthChangeWithUser(User user) {
    if (user.isAnonymous) {
    } else {
      saveDeviceLoginInfo(user);
    }
  }

  Future saveDeviceLoginInfo(User user) async {
    final generalBox = GetIt.I<GeneralBox>();
    final sp = GetIt.I<SharedPreferences>();
    var deviceInfo = generalBox.get(Keys.deviceInfo);
    if (deviceInfo?.containsKey('phoneNumber') == true ||
        deviceInfo?.containsKey('email') == true) {
      if ((deviceInfo?['phoneNumber'] ?? '') == (user.phoneNumber ?? '') &&
          (deviceInfo?['email'] ?? '') == (user.email ?? '') &&
          deviceInfo?['uid'] == user.uid &&
          (deviceInfo?['displayName'] ?? '') == (user.displayName ?? '')) {
        return;
      }
    }
    deviceInfo = await getDeviceInfo();
    deviceInfo['phoneNumber'] = user.phoneNumber;
    deviceInfo['uid'] = user.uid;
    deviceInfo['email'] = user.email;
    deviceInfo['displayName'] = user.displayName;
    final authUser = FirebaseAuthUser.fromCurrentUser(user);
    Map<String, dynamic> userData = authUser.toJson();
    await generalBox.put(Keys.deviceHash, deviceInfo['deviceHash']);
    String? firebaseMessagingToken;
    try {
      firebaseMessagingToken = await FirebaseMessaging.instance.getToken();
      if (firebaseMessagingToken != null) {
        userData['firebaseMessagingToken'] = firebaseMessagingToken;
      }
    } catch (e) {}
    await FirestoreDB.updateUser(userData, user.uid);
    sp
        .setString(Keys.deviceHash, deviceInfo['deviceHash'])
        .then((value) => null);
    final updatedUser =
        await FirestoreDB.getUserInfoByFirebaseId(user.uid, 'uid');
    if (updatedUser != null) {
      await generalBox.put(
          Keys.firebaseAuthUser, FirebaseAuthUser.fromJson(updatedUser));
    } else {
      //await generalBox.put(Keys.firebaseAuthUser, authUser);
    }
    deviceInfo['LastLogin'] = DateTime.now().toUtc();
    await generalBox.put(Keys.deviceInfo, deviceInfo);
    //deviceInfo['LastLogin'] = FieldValue.serverTimestamp();
    await FirestoreDB.userDevicesRef
        .doc(deviceInfo['deviceHash'])
        .set(deviceInfo, SetOptions(merge: true));
    print('New User saved');
  }
}
