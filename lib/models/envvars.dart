// ignore_for_file: non_constant_identifier_names

import 'dart:convert' show jsonEncode, jsonDecode;

import 'package:hive/hive.dart';

part 'envvars.g.dart';

@HiveType(typeId: 12)
class EnvVars extends HiveObject {
  @HiveField(0)
  String HEADER;

  @HiveField(1)
  String EMAIL_PASSWORD;

  @HiveField(2)
  String WEB_API_KEY;

  @HiveField(3)
  String APP_NAME;

  @HiveField(4)
  String AWS_ACCESS_KEY;

  @HiveField(5)
  String AWS_SECRET_KEY;

  @HiveField(6)
  String FIREBASE_MESSAGING_VPID;

  @HiveField(7)
  String EMAIL_PASSWORD_HASH_KEY;

  @HiveField(7)
  int EXPIRATION_TIMESTAMP;

  @HiveField(8)
  String MQTT_SERVER_IP;

  EnvVars(
      {required this.HEADER,
      required this.EMAIL_PASSWORD,
      required this.WEB_API_KEY,
      required this.APP_NAME,
      required this.AWS_ACCESS_KEY,
      required this.AWS_SECRET_KEY,
      required this.FIREBASE_MESSAGING_VPID,
      required this.EMAIL_PASSWORD_HASH_KEY,
      required this.EXPIRATION_TIMESTAMP,
      required this.MQTT_SERVER_IP});

  factory EnvVars.fromJson(Map<String, dynamic> json) {
    return EnvVars(
        HEADER: json['HEADER'] ?? '',
        EMAIL_PASSWORD: json['EMAIL_PASSWORD'] ?? '',
        WEB_API_KEY: json['WEB_API_KEY'] ?? '',
        APP_NAME: json['APP_NAME'] ?? '',
        AWS_ACCESS_KEY: json['AWS_ACCESS_KEY'] ?? '',
        AWS_SECRET_KEY: json['AWS_SECRET_KEY'] ?? '',
        FIREBASE_MESSAGING_VPID: json['FIREBASE_MESSAGING_VPID'] ?? '',
        EMAIL_PASSWORD_HASH_KEY: json['EMAIL_PASSWORD_HASH_KEY'] ?? '',
        EXPIRATION_TIMESTAMP: json['EXPIRATION_TIMESTAMP'] ??
            DateTime.now().toUtc().millisecondsSinceEpoch,
        MQTT_SERVER_IP: json['MQTT_SERVER_IP'] ?? '');
  }

  factory EnvVars.fromString(String value) {
    final json = jsonDecode(value) as Map<String, dynamic>;
    return EnvVars(
        HEADER: json['HEADER'] ?? '',
        EMAIL_PASSWORD: json['EMAIL_PASSWORD'] ?? '',
        WEB_API_KEY: json['WEB_API_KEY'] ?? '',
        APP_NAME: json['APP_NAME'] ?? '',
        AWS_ACCESS_KEY: json['AWS_ACCESS_KEY'] ?? '',
        AWS_SECRET_KEY: json['AWS_SECRET_KEY'] ?? '',
        FIREBASE_MESSAGING_VPID: json['FIREBASE_MESSAGING_VPID'] ?? '',
        EMAIL_PASSWORD_HASH_KEY: json['EMAIL_PASSWORD_HASH_KEY'] ?? '',
        EXPIRATION_TIMESTAMP: json['EXPIRATION_TIMESTAMP'] ??
            DateTime.now().toUtc().millisecondsSinceEpoch,
        MQTT_SERVER_IP: json['MQTT_SERVER_IP'] ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'HEADER': HEADER,
      'EMAIL_PASSWORD': EMAIL_PASSWORD,
      'WEB_API_KEY': WEB_API_KEY,
      'APP_NAME': APP_NAME,
      'AWS_ACCESS_KEY': AWS_ACCESS_KEY,
      'AWS_SECRET_KEY': AWS_SECRET_KEY,
      'FIREBASE_MESSAGING_VPID': FIREBASE_MESSAGING_VPID,
      'EMAIL_PASSWORD_HASH_KEY': EMAIL_PASSWORD_HASH_KEY,
      'EXPIRATION_TIMESTAMP': EXPIRATION_TIMESTAMP,
      'MQTT_SERVER_IP': MQTT_SERVER_IP,
    };
    return data;
  }

  //Envers would have expired when it has been more than 30 minutes to expiration time
  bool get isExpired {
    return DateTime.now().toUtc().millisecondsSinceEpoch -
            EXPIRATION_TIMESTAMP >
        60000 * 30;
  }

  //Convert envars to a string
  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
