import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';

const columnNamesToExclude = [
  'digitalProductId',
];
const deviceInfoIds = [
  "id",
  "host",
  "product",
  "fingerprint",
  "model",
  "product",
  "model",
  "name",
  "isPhysicalDevice",
  "systemName",
  "systemVersion",
  "identifierForVendor",
  "localizedModel",
  "version",
  "id",
  "machineId",
  "buildId",
  "prettyName",
  "browserName",
  "platform",
  "product",
  "userAgent",
  "computerName",
  "hostName",
  "systemGuid",
  "osRelease",
  "deviceId",
  "productId"
];
Future<Map<String, dynamic>> getDeviceId() async {
  DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
  // final info = await infoPlugin.deviceInfo;
  // return info.data;
  if (kIsWeb) {
    var web = await infoPlugin.webBrowserInfo;
    return web.data;
  }
  if (Platform.isAndroid) {
    var androidInfo = await infoPlugin.androidInfo;
    return androidInfo.data;
  } else if (Platform.isIOS) {
    var iosInfo = await infoPlugin.iosInfo;
    return iosInfo.data;
  } else if (Platform.isWindows) {
    var androidInfo = await infoPlugin.windowsInfo;
    return androidInfo.data;
  } else if (Platform.isLinux) {
    var iosInfo = await infoPlugin.linuxInfo;
    return iosInfo.data;
  } else if (Platform.isMacOS) {
    var iosInfo = await infoPlugin.macOsInfo;
    return iosInfo.data;
  } else {
    var iosInfo = await infoPlugin.deviceInfo;
    return iosInfo.data;
  }
}

Future<Map<String, dynamic>> getDeviceInfo(
    {String customHashPrefix = ""}) async {
  DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
  final info = await infoPlugin.deviceInfo;
  Map<String, dynamic> output = <String, dynamic>{};
  info.data.forEach((key, value) {
    if (!value.toString().isNullOrWhiteSpace &&
        !columnNamesToExclude.contains(key)) {
      output[key] = value.toString();
    }
  });
  String deviceInfoString = '$customHashPrefix';
  for (var item in output.entries) {
    if (deviceInfoIds.contains(item.key)) {
      deviceInfoString += '${item.value}';
    }
  }
  var bytes1 = utf8.encode(deviceInfoString); // data being hashed
  var digest1 = md5.convert(bytes1); // Hashing Process
  output['deviceHash'] = digest1.toString();
  String readableDeviceName = getReadableDeviceName(output);
  output['deviceName'] = readableDeviceName;
  return output;
}

String getReadableDeviceName(Map<String, dynamic> deviceInfo) {
  var name = 'Unknown';
  if (kIsWeb) {
    name =
        "${(deviceInfo['browserName'] ?? '').toString().split('.').last.toTitleCase} ON ${deviceInfo['platform'] ?? ''} ${deviceInfo['product'] ?? ''} ${deviceInfo['appName'] ?? ''}";
    return name;
  }
  if (Platform.isAndroid) {
    name =
        "${deviceInfo['brand'] ?? ''} ${(deviceInfo['device'] ?? '').toUpperCase()} ID:${deviceInfo['model'] ?? ''}";
  } else if (Platform.isIOS) {
    name = deviceInfo['name'];
  } else if (Platform.isWindows) {
    name = deviceInfo['productName'].toString();
    if (!deviceInfo['computerName'].toString().isNullOrWhiteSpace) {
      name += ' ID: ${deviceInfo['computerName'].toString()}';
    }
    if (!deviceInfo['registeredOwner'].toString().isNullOrWhiteSpace) {
      name += ' Owner: ${deviceInfo['registeredOwner'].toString()}';
    }
    if (!deviceInfo['userName'].toString().isNullOrWhiteSpace) {
      name += ' Used By: ${deviceInfo['userName'].toString()}';
    }
  } else if (Platform.isLinux) {
    name = deviceInfo['prettyName'] ?? deviceInfo['name'] ?? name;
  } else if (Platform.isMacOS) {
    name = deviceInfo['computerName'] ?? deviceInfo['hostName'] ?? name;
  }
  return name.toString().toTitleCase;
}
