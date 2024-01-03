import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/adapters.dart';
part 'custom_auth_provider.g.dart';

@HiveType(typeId: 17)
class CustomAuthProvider {
  @HiveField(0)
  final String? providerId;
  @HiveField(1)
  final String? uid;
  @HiveField(2)
  final String? displayName;
  @HiveField(3)
  final String? photoUrl;
  @HiveField(4)
  final String? email;
  @HiveField(5)
  final String? phoneNumber;

  CustomAuthProvider({
    required this.providerId,
    required this.uid,
    this.displayName,
    this.photoUrl,
    this.email,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'uid': uid,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  factory CustomAuthProvider.fromJson(Map<String, dynamic> json) {
    return CustomAuthProvider(
      providerId: json['providerId'],
      uid: json['uid'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }

  static CustomAuthProvider fromUserInfo(UserInfo userInfo) {
    return CustomAuthProvider(
      providerId: userInfo.providerId,
      uid: userInfo.uid,
      displayName: userInfo.displayName,
      photoUrl: userInfo.photoURL,
      email: userInfo.email,
      phoneNumber: userInfo.phoneNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomAuthProvider &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          providerId == other.providerId &&
          photoUrl == other.photoUrl &&
          uid == other.uid &&
          displayName == other.displayName);
}
