// import 'package:background_locator_2/location_dto.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
// import 'package:location/location.dart';

import 'dart:convert' show jsonEncode, jsonDecode;
// import 'package:geolocator/geolocator.dart';

part 'device_location.g.dart';

@HiveType(typeId: 18)
class DeviceLocation {
  @HiveField(0)
  final String email;
  @HiveField(1)
  final String deviceHash;
  @HiveField(2)
  final double lon;
  @HiveField(3)
  final double lat;
  @HiveField(4)
  final int timestamp;
  @HiveField(5)
  final double? accuracy;
  @HiveField(6)
  final double? altitude;
  @HiveField(7)
  final double? altitudeAccuracy;
  @HiveField(8)
  final int? floor;
  @HiveField(9)
  final double? heading;
  @HiveField(10)
  final double? headingAccuracy;
  @HiveField(11)
  final double? speed;
  @HiveField(12)
  final double? speedAccuracy;
  @HiveField(13)
  final bool? isMocked;

  DeviceLocation({
    required this.email,
    required this.deviceHash,
    required this.lon,
    required this.lat,
    required this.timestamp,
    this.accuracy,
    this.altitude,
    this.altitudeAccuracy,
    this.floor,
    this.heading,
    this.headingAccuracy,
    this.speed,
    this.speedAccuracy,
    this.isMocked,
  });

  factory DeviceLocation.fromJson(Map<String, dynamic> json) {
    return DeviceLocation(
      email: json['email'] as String,
      deviceHash: json['deviceHash'] as String,
      lon: json['lon'] as double,
      lat: json['lat'] as double,
      timestamp: json.containsKey('timestamp')
          ? (json['timestamp'] as int)
          : DateTime.parse(json['createdAt']).toUtc().millisecondsSinceEpoch,
      accuracy: json['accuracy'] as double?,
      altitude: json['altitude'] as double?,
      altitudeAccuracy: json['altitude_accuracy'] as double?,
      floor: json['floor'] as int?,
      heading: json['heading'] as double?,
      headingAccuracy: json['heading_accuracy'] as double?,
      speed: json['speed'] as double?,
      speedAccuracy: json['speed_accuracy'] as double?,
      isMocked: json['is_mocked'] as bool?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'deviceHash': deviceHash,
      'lon': lon,
      'lat': lat,
      'timestamp': timestamp,
      'accuracy': accuracy,
      'altitude': altitude,
      'altitude_accuracy': altitudeAccuracy,
      'floor': floor,
      'heading': heading,
      'heading_accuracy': headingAccuracy,
      'speed': speed,
      'speed_accuracy': speedAccuracy,
      'is_mocked': isMocked,
    };
  }

  DateTime get createdAt =>
      DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true).toLocal();

  Future<Map<String, dynamic>?> getUser() async {
    final userMap = await FirestoreDB.getUserInfoByFirebaseId(email, 'email');
    return userMap;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceLocation &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          deviceHash == other.deviceHash &&
          Geolocator.distanceBetween(lat, lon, other.lat, other.lon) < 1.0);

  @override
  String toString() {
    Map<String, dynamic> deviceLocationMap = toJson();
    return jsonEncode(deviceLocationMap);
  }
}

@HiveType(typeId: 20)
class DeviceLocations {
  @HiveField(0)
  List<DeviceLocation> deviceLocations;

  DeviceLocations({required this.deviceLocations});
  void add(DeviceLocation deviceLocation) {
    deviceLocations.add(deviceLocation);
    int numberOfLocations = deviceLocations.length;
    if (numberOfLocations > 10) {
      deviceLocations = deviceLocations.sublist(numberOfLocations - 10);
    }
  }

  bool get isEmpty => deviceLocations.isEmpty;
  bool get isNotEmpty => deviceLocations.isNotEmpty;
  DeviceLocation? get first => deviceLocations.firstOrNull;
  DeviceLocation? get last => deviceLocations.lastOrNull;

  bool isFarFromCurrentPosition(
      {required Position currentPosition, maxProximity = 1}) {
    if (deviceLocations.isEmpty) {
      return false;
    }
    return (getDistanceFromPosition(currentPosition: currentPosition) ?? 0) >
        maxProximity;
  }

  double? getDistanceFromPosition({required Position currentPosition}) {
    if (deviceLocations.isEmpty) {
      return null;
    }
    final lastDeviceLocation = deviceLocations.last;
    final distanceBetweenInMeters = Geolocator.distanceBetween(
        lastDeviceLocation.lat,
        lastDeviceLocation.lon,
        currentPosition.latitude,
        currentPosition.longitude);

    return distanceBetweenInMeters;
  }
  // bool isFarFromCurrentPosition({required LocationDto currentPosition}) {
  //   if (deviceLocations.isEmpty) {
  //     return false;
  //   }
  //   final lastDeviceLocation = deviceLocations.last;
  //   return (lastDeviceLocation.lat - currentPosition.latitude).abs() <
  //           0.00009 &&
  //       (lastDeviceLocation.lon - currentPosition.longitude).abs() < 0.00009;
  // }

  factory DeviceLocations.fromJson(Map<String, dynamic> json) {
    return DeviceLocations(
      deviceLocations: (json['deviceLocations'] as List<dynamic>)
          .map((e) => DeviceLocation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  factory DeviceLocations.fromListString(List<String> listString) {
    return DeviceLocations(
      deviceLocations: listString
          .map((e) =>
              DeviceLocation.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'deviceLocations': deviceLocations.map((e) => e.toJson()).toList(),
    };
  }

  List<String> toStringList() {
    return deviceLocations.map((e) => e.toString()).toList();
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  int length() {
    return deviceLocations.length;
  }
}
