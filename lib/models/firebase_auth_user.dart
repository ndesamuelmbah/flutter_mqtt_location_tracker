import 'dart:convert' show jsonEncode, jsonDecode;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_mqtt_location_tracker/models/custom_auth_provider.dart';
part 'firebase_auth_user.g.dart';

@HiveType(typeId: 16)
class FirebaseAuthUser {
  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String? displayName;
  @HiveField(3)
  final String? photoUrl;
  @HiveField(4)
  final bool emailVerified;
  @HiveField(5)
  final int creationTime;
  @HiveField(6)
  final List<CustomAuthProvider> providers;
  @HiveField(7)
  final bool? isAdmin;
  @HiveField(8)
  final String phoneNumber;
  @HiveField(9)
  final bool? isSubscribedToTracking;
  @HiveField(10)
  final String accountNumber;
  @HiveField(11)
  final String? signatureUrl;
  @HiveField(12)
  final String? organizationName;
  @HiveField(13)
  String? frontOfId;
  @HiveField(14)
  String? backOfId;
  @HiveField(15)
  String? firebaseMessagingToken;
  @HiveField(16)
  String? passwordHash;
  @HiveField(17)
  List<String>? deviceIds;

  FirebaseAuthUser(
      {required this.uid,
      required this.email,
      this.displayName,
      this.photoUrl,
      required this.providers,
      required this.creationTime,
      required this.emailVerified,
      required this.phoneNumber,
      this.isSubscribedToTracking,
      this.isAdmin,
      required this.accountNumber,
      this.signatureUrl,
      this.frontOfId,
      this.backOfId,
      this.firebaseMessagingToken,
      this.passwordHash,
      this.organizationName,
      this.deviceIds});

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'providers': providers.map((p) => p.toJson()).toList(),
      'emailVerified': emailVerified,
      'creationTime': creationTime,
      'phoneNumber': phoneNumber,
      'isSubscribedToTracking': isSubscribedToTracking,
      'isAdmin': isAdmin,
      'accountNumber': accountNumber,
      'signatureUrl': signatureUrl,
      'frontOfId': frontOfId,
      'backOfId': backOfId,
      'firebaseMessagingToken': firebaseMessagingToken,
      'passwordHash': passwordHash,
      'organizationName': organizationName,
      'deviceIds': deviceIds,
    };
  }

  @override
  toString() => jsonEncode(toJson());

  factory FirebaseAuthUser.fromJson(Map<String, dynamic> json) {
    final providersList = (json['providers'] as List<dynamic>)
        .map((p) => CustomAuthProvider.fromJson(p))
        .toList();

    final deviceIds = json['deviceIds'] != null
        ? (json['deviceIds'] as List<dynamic>).map((e) => e.toString()).toList()
        : null;

    return FirebaseAuthUser(
        uid: json['uid'],
        email: json['email'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        displayName: json['displayName'],
        photoUrl: json['photoUrl'],
        providers: providersList,
        emailVerified: json['emailVerified'] ?? false,
        creationTime:
            json['creationTime'] ?? DateTime.now().millisecondsSinceEpoch,
        isSubscribedToTracking: json['isSubscribedToTracking'] ?? false,
        isAdmin: json['isAdmin'],
        accountNumber: json['accountNumber'],
        signatureUrl: json['signatureUrl'],
        organizationName: json['organizationName'],
        frontOfId: json['frontOfId'],
        backOfId: json['backOfId'],
        firebaseMessagingToken: json['firebaseMessagingToken'],
        passwordHash: json['passwordHash'],
        deviceIds: deviceIds);
  }

  factory FirebaseAuthUser.fromString(String userString) {
    Map<String, dynamic> json = jsonDecode(userString) as Map<String, dynamic>;
    return FirebaseAuthUser.fromJson(json);
  }
  bool hasCompletedProfileSetup() =>
      signatureUrl != null &&
      frontOfId != null &&
      backOfId != null &&
      photoUrl != null;

  bool hasCompletedIdentificatonSetup() =>
      signatureUrl != null && frontOfId != null && backOfId != null;

  static FirebaseAuthUser fromCurrentUser(User user) {
    // if (user.email == null) {
    //   throw 'Only Users With Emails Can Proceed';
    // }
    final providerData = user.providerData;
    final providers =
        providerData.map((p) => CustomAuthProvider.fromUserInfo(p)).toList();

    return FirebaseAuthUser(
      uid: user.uid,
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      providers: providers,
      emailVerified: user.emailVerified,
      creationTime: user.metadata.creationTime?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
      accountNumber: (user.metadata.creationTime?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch)
          .toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FirebaseAuthUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          phoneNumber == other.phoneNumber &&
          passwordHash == other.passwordHash &&
          providers == other.providers &&
          displayName == other.displayName);
}

@HiveType(typeId: 7)
class FirebaseAuthUsers {
  @HiveField(0)
  List<FirebaseAuthUser> users;

  FirebaseAuthUsers({required this.users});
}
