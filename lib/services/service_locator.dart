// ignore_for_file: non_constant_identifier_names

import 'dart:io' show Directory;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart' as hive;
import 'package:flutter_mqtt_location_tracker/services/firebase_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceLocator {
  static GetIt get serviceLocator => GetIt.instance;
  Future setupLocator() async {
    serviceLocator
        .registerLazySingleton<FirebaseService>(() => FirebaseService());
    serviceLocator.registerSingletonAsync<GeneralBox>(() async {
      final GeneralBox box = GeneralBox();
      await box.openBox();
      return box;
    }, signalsReady: false);
    serviceLocator.registerSingletonAsync<SharedPreferences>(() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs;
    }, signalsReady: false);
  }
}

class GetChatsDir {
  String? mediaDir;
  String getMediaDir() {
    if (mediaDir != null) {
      return mediaDir!;
    } else {
      setDir().then((value) => null);
      return mediaDir!;
    }
  }

  Future setDir() async {
    if (!kIsWeb) {
      if (mediaDir == null) {
        var dir = await getApplicationDocumentsDirectory();
        await setMediaDir(dir);
      }
    }
  }

  Future setMediaDir(Directory dir) async {
    mediaDir =
        dir.path.endsWith('/') ? '${dir.path}dGMedia/' : '${dir.path}/dGMedia/';
    final v = await Directory(mediaDir!).exists();
    if (v != true) {
      await Directory(mediaDir!).create();
    }
  }
}

class GeneralBox {
  hive.Box<dynamic>? box;
  static String boxName = "generalBoxName";
  static String notificationsList = "notificationsList";
  Future<hive.Box<dynamic>> openBox() async {
    if (box == null) {
      box = await hive.Hive.openBox(boxName);
      return box!;
    } else {
      //print('Reusing Box');
      return box!;
    }
  }

  put(String key, dynamic value) {
    box!.put(key, value);
  }

  delete(String key) {
    box!.delete(key);
  }

  get<T>(String key) {
    final val = box!.get(key) as T?;
    return val;
  }

  clear() async {
    final wasCleared = await box!.clear();
    print('wasCleared: $wasCleared');
  }

  get1(String key) {
    final val = box!.get(key);
    return val;
  }

  Future<bool> modifyNotifications(
      {Map<String, dynamic> notification = const {},
      bool isNewNotification = true,
      num receiveTime = 0}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    var pastNots = box!.get(notificationsList) ?? [];
    if (isNewNotification) {
      notification['receiveTime'] = now;
      if (pastNots.isNotEmpty) {
        pastNots
            .removeWhere((element) => now - element['receiveTime'] > 604800000);
      }
      pastNots.add(notification);
      box!.put(notificationsList, pastNots);
      return true;
    } else if (pastNots.isNotEmpty) {
      pastNots.removeWhere((element) => element['receiveTime'] == receiveTime);

      box!.put(notificationsList, pastNots);
      return true;
    } else {
      return false;
    }
  }

  getNotifications() => box!.get(notificationsList) ?? [];
}
