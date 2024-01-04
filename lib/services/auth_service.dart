import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_mqtt_location_tracker/api/api_requests.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/models/envvars.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:flutter_mqtt_location_tracker/utils/password_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> setUserOnlineStatus(bool isOnline) async {
    final user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      final userRef = FirestoreDB.customersRef.doc(uid);
      await userRef.update({'isOnline': isOnline});
    }
  }

  void listenToAuthChanges() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        //also save the uid so that one can use it to update offline status
        setUserOnlineStatus(true);
      } else {
        setUserOnlineStatus(false);
      }
    });
  }

  static Future<void> completeSignInWithEmailAndPasswordCleanUp(
      User user, String email, String password) async {
    final generalBox = GetIt.I<GeneralBox>();
    final prefs = GetIt.I<SharedPreferences>();
    final EnvVars envVars = generalBox.get(Keys.envVars);
    final passwordHash =
        encryptWithEncrypt(envVars.EMAIL_PASSWORD_HASH_KEY, password);
    final currentHash = generalBox.get(Keys.passwordHash);
    if (currentHash != passwordHash) {
      await generalBox.put(Keys.passwordHash, passwordHash);
      prefs.setString(Keys.passwordHash, passwordHash).then((value) => null);
    } else {
      final lastLinkedPasswordHash =
          generalBox.get(Keys.lastLinkedPasswordHash);
      if (lastLinkedPasswordHash == passwordHash) {
        return;
      }
    }
    FirebaseAuthUser firebaseAuthUser = FirebaseAuthUser.fromCurrentUser(user);
    firebaseAuthUser.passwordHash = passwordHash;
    await generalBox.put(Keys.firebaseAuthUser, firebaseAuthUser);
    prefs
        .setString(Keys.firebaseAuthUser, firebaseAuthUser.toString())
        .then((value) => null);
    final lastLinkedPasswordHash = generalBox.get(Keys.lastLinkedPasswordHash);
    if (lastLinkedPasswordHash != passwordHash) {
      String? deviceToken = await FirebaseMessaging.instance.getToken();
      if (deviceToken == null) {
        await generalBox.put(Keys.firebaseMessagingToken, deviceToken);
      }
      await ApiRequest.genericPostDict('save_mosquitto_user', params: {
        "completeSignInMetaData": {
          'email': email,
          'password': password,
          'firebaseMessagingTokens': deviceToken ?? '',
          'username': user.email ?? '',
          'uid': user.uid,
          'phoneNumber': user.phoneNumber ?? '',
          'displayName': user.displayName ?? 'NOT SET',
        }
      }).then((resp) async {
        print('save_mosquitto_user response is $resp');
        if (resp != null) {
          if (resp['NumberOfSuccessfulAdds'] > 0) {
            await generalBox.put(Keys.lastLinkedPasswordHash, passwordHash);
            await prefs
                .setString(Keys.lastLinkedPasswordHash, passwordHash)
                .then((value) => print('lastLinkedPasswordHash hash saved'));
          }
        }
      });
    }
  }
}
