import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';
import 'package:flutter_mqtt_location_tracker/api/api_requests.dart';
import 'package:flutter_mqtt_location_tracker/api/app_version.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/main.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_mqtt_location_tracker/services/firebase_services.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:flutter_mqtt_location_tracker/utils/password_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/strings.dart';

import '../models/envvars.dart';

part 'firebase_auth_event.dart';

part 'firebase_auth_state.dart';

final getIt = GetIt.instance;

class FirebaseAuthBloc extends Bloc<AuthEvent, AuthState> {
  FirebaseAuthBloc() : super(AuthUnknown()) {
    on<AutoLogin>(_onAutoLogin);
    on<Login>(_onLogin);
    on<Logout>(_onLogout);
    on<Refresh>(_onRefresh);
    on<UpdateUser>(_onUpdateUser);
  }
  static final firebaseInstance = getIt<FirebaseService>().firebaseAuthInst;
  final generalBox = getIt<GeneralBox>();
  final Logger logger = Logger('authBlock');

  // Future updateUserPosition(FirebaseAuthUser firebaseAuthUser, Position? position) async {
  //   position ??= await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);

  //   firebaseAuthUser.lat = position.latitude;
  //   firebaseAuthUser.lng = position.longitude;
  //   updateDriverLocation(position, firebaseAuthUser.userId);
  //   await sf.write(key: Keys.firebaseAuthUser, value: jsonEncode(firebaseAuthUser.toMap()));
  // }

  // Future updateDriverLocation(Position position, num userId) async {
  //   ApiRequest.genericPost('update_driver_location', params: {
  //     'lat': position.latitude.toString(),
  //     'lng': position.longitude.toString(),
  //     'userId': userId.toString()
  //   }).then((value) => null);
  // }

  Future<void> _onAutoLogin(event, emit) async {
    EnvVars? envVars = generalBox.get(Keys.envVars) as EnvVars?;
    if (envVars == null) {
      try {
        int startTime = DateTime.now().millisecondsSinceEpoch;
        await firebaseInstance.signInAnonymously();
        final resp = await FirestoreDB.getEnvVars();
        Map<String, dynamic> environment = {};
        if (resp == null) {
          emit(UnAuthenticated());
          return;
        } else {
          resp.forEach((key, value) {
            if (key == 'EXPIRATION_TIMESTAMP') {
              environment[key] = value as int;
            } else {
              environment[key] = value.toString();
            }
          });
        }
        int endTime = DateTime.now().millisecondsSinceEpoch;
        print('Loaded Environment variables in ${endTime - startTime} ms}');

        envVars = EnvVars.fromJson(environment);
        await generalBox.put(Keys.envVars, envVars);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(Keys.envVars, envVars.toString()).then((value) => null);
      } catch (e, stackTrace) {
        logger.severe(e, stackTrace);
        emit(UnAuthenticated());
        return;
      }

      // try {
      //   var response = await http.get(Uri.parse(Keys.appConfigUrl));
      //   print('Response');
      //   print(response.body);
      //   var jsonMap = jsonDecode(response.body);

      //   final map = Map<String, String>.from(jsonMap as Map<String, dynamic>);
      //   envVars = EnvVars.fromJson(map);
      //   generalBox.put(Keys.envVars, envVars);
      // } catch (e, stackTrace) {
      //   logger.severe(e, stackTrace);
      //   emit(UnAuthenticated());
      //   return;
      // }
    } else {
      checkIfEnvVarsAreExpired(envVars);
    }
    //await Future.delayed(const Duration(milliseconds: 2000));
    final firebaseAuthUser =
        generalBox.get(Keys.firebaseAuthUser) as FirebaseAuthUser?;
    if (firebaseAuthUser == null) {
      await firebaseInstance.signInAnonymously();
      emit(UnAuthenticated());
      return;
    } else {
      try {
        try {
          if (!firebaseAuthUser.passwordHash.isNullOrWhiteSpace &&
              !firebaseAuthUser.email.isNullOrWhiteSpace) {
            firebaseInstance.signInWithEmailAndPassword(
                email: firebaseAuthUser.email!,
                password: decryptWithEncrypt(envVars.EMAIL_PASSWORD_HASH_KEY,
                    firebaseAuthUser.passwordHash!));
          } else {
            logger.severe(
                'No Password Hash for ${firebaseAuthUser.uid} at sign in',
                'investigate');
            emit(UnAuthenticated());
            return;
          }
        } catch (e, stackTrace) {
          logger.severe(e, stackTrace);
          emit(UnAuthenticated());
          return;
        }

        emit(Authenticated(firebaseAuthUser));
        final p = generalBox.get(Keys.authenticatedTime) ?? 0;
        final lastAuthenticatedTime =
            p > 1000 ? p : DateTime.now().millisecondsSinceEpoch;
        if (lastAuthenticatedTime +
                (const Duration(minutes: 30).inMilliseconds) <
            DateTime.now().millisecondsSinceEpoch) {
          add(Refresh());
        }
      } catch (e, stackTrace) {
        logger.severe(e, stackTrace);
        emit(UnAuthenticated());
      }
    }
  }

  Future<void> checkIfEnvVarsAreExpired(envVars) async {
    if (!envVars.isExpired) {
      return;
    }
    // final now = DateTime.now();
    // final lastUpdated = envVars.EXPIRATION_TIMESTAMP;
    // final diff = now.difference(lastUpdated);
    // if (diff.inDays > 0) {
    //   try {
    //     final resp = await FirestoreDB.getEnvVars();
    //     Map<String, String> environment = {};
    //     if (resp == null) {
    //       return;
    //     } else {
    //       resp.forEach((key, value) {
    //         environment[key] = value.toString();
    //       });
    //     }
    //     envVars = EnvVars.fromJson(environment);
    //     generalBox.put(Keys.envVars, envVars);
    //   } catch (e, stackTrace) {
    //     logger.severe(e, stackTrace);
    //   }
    // }
  }

  Future<void> _onLogin(event, emit) async {
    FirebaseAuthUser thisUser = event.firebaseAuthUser;
    generalBox.put(Keys.firebaseAuthUser, thisUser);
    emit(Authenticated(thisUser));
  }

  Future<void> _onLogout(event, emit) async {
    generalBox.delete(Keys.firebaseAuthUser);
    generalBox.delete(Keys.authenticatedTime);
    generalBox.delete(Keys.envVars);
    await firebaseInstance.signOut();
    emit(UnAuthenticated());
  }

  Future<void> _onRefresh(event, emit) async {
    var authState = state;
    if (authState is Authenticated) {
      emit(AuthRefreshing(authState.firebaseAuthUser));
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.isAnonymous == false) {
          final userDoc = await FirestoreDB.customersRef.doc(user.uid).get();
          var refrehedUser = userDoc.data()! as Map<String, dynamic>;

          final firebaseAuthUser = FirebaseAuthUser.fromJson(refrehedUser);

          generalBox.put(Keys.firebaseAuthUser, firebaseAuthUser);
          emit(Authenticated(firebaseAuthUser));
        }
      } catch (e) {
        emit(UnAuthenticated());
      }
    }
  }

  Future<void> _onUpdateUser(event, emit) async {
    FirebaseAuthUser firebaseAuthUser = event.firebaseAuthUser;
    generalBox.put(Keys.firebaseAuthUser, firebaseAuthUser);
    emit(Authenticated(firebaseAuthUser));
  }

  Future<String?> getApiAppVersion() async {
    final platform = Platform.isAndroid ? 'android' : 'ios';
    final res = await ApiRequest.genericGet('get_app_version/$platform');
    return res?['currentVersion'];
  }

  void checkVersion() async {
    var lastUpdatePromptedTime = generalBox.get(Keys.updatePromptTime) ?? 0;

    if (lastUpdatePromptedTime > 100 &&
        (lastUpdatePromptedTime + const Duration(hours: 24).inMilliseconds) >
            DateTime.now().millisecondsSinceEpoch) {
      return;
    }

    var versions =
        await Future.wait([AppVersion.getAppVersion(), getApiAppVersion()]);

    if (!versions.contains(null) && versions[0] != versions[1]) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      Uri uri = Platform.isAndroid
          ? Uri.https("play.google.com", "/store/apps/details",
              {"id": packageInfo.packageName})
          : Uri.https("itunes.apple.com", "/lookup",
              {"bundleId": packageInfo.packageName});

      showDialog(
        barrierDismissible: false,
        context: navigatorKey.currentState!.context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: const Text(Strings.updateDialogTitle),
              content: Text(Strings.updateAppMessage
                  .replaceAll('100', versions.first!)
                  .replaceAll('200', versions.last!)),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (await canLaunchUrl(Uri.parse(uri.toString()))) {
                      generalBox.put(Keys.updatePromptTime,
                          DateTime.now().millisecondsSinceEpoch);
                      await launchUrl(Uri.parse(uri.toString()));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    Strings.letsUpdate,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    generalBox.put(Keys.updatePromptTime,
                        DateTime.now().millisecondsSinceEpoch);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    Strings.maybeLater,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}

String getUserId(BuildContext context) {
  // return (context.read<FirebaseAuthBloc>().state as Authenticated)
  //     .firebaseAuthUser
  //     .uid;

  return (GetIt.I<GeneralBox>().get(Keys.firebaseAuthUser) as FirebaseAuthUser)
      .uid;
}

FirebaseAuthUser getFirebaseAuthUser(BuildContext context) {
  return GetIt.I<GeneralBox>().get(Keys.firebaseAuthUser);
  // return (context.read<FirebaseAuthBloc>().state as Authenticated)
  //     .firebaseAuthUser;
}

FirebaseAuthUser? getNullableFirebaseAuthUser(BuildContext context) {
  return GetIt.I<GeneralBox>().get(Keys.firebaseAuthUser);
  // final state = (context.read<FirebaseAuthBloc>().state);
  // if (state is Authenticated) {
  //   return state.firebaseAuthUser;
  // }
  // return null;
}
