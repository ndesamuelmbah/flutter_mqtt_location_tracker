import 'package:hive/hive.dart';

part 'pending_authentications.g.dart';

@HiveType(typeId: 11)
class PendingAuthentications extends HiveObject {
  @HiveField(0)
  bool isSignedIn;

  @HiveField(1)
  int timeStamp;

  @HiveField(2)
  String uid;

  PendingAuthentications({
    required this.isSignedIn,
    required this.timeStamp,
    required this.uid,
  });

  factory PendingAuthentications.fromJson(Map<String, dynamic> json) {
    return PendingAuthentications(
      isSignedIn: json['isSignedIn'] ?? false,
      timeStamp: json['timeStamp'],
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSignedIn': isSignedIn,
      'timeStamp': timeStamp,
      'uid': uid,
    };
  }
}
