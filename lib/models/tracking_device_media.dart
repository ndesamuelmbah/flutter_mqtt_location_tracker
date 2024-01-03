import 'package:hive/hive.dart';

part 'tracking_device_media.g.dart';

@HiveType(typeId: 21)
class TrackingDeviceMedia {
  @HiveField(0)
  String description;

  @HiveField(1)
  String s3Url;

  @HiveField(2)
  String userName;

  @HiveField(3)
  DateTime utcTimeStamp;

  @HiveField(4)
  String? localPath;

  TrackingDeviceMedia({
    required this.description,
    required this.s3Url,
    required this.userName,
    required this.utcTimeStamp,
    this.localPath,
  });

  factory TrackingDeviceMedia.fromJson(Map<String, dynamic> json) {
    return TrackingDeviceMedia(
        description: json['description'] as String,
        s3Url: json['s3Url'] as String,
        localPath: json['localPath'] as String?,
        userName: json['userName'] as String,
        utcTimeStamp: DateTime.fromMillisecondsSinceEpoch(
            DateTime.parse(json['utcTimeStamp'].toString())
                .millisecondsSinceEpoch,
            isUtc: true));
  }

  DateTime get localTimeStamp => utcTimeStamp.toLocal();

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      's3Url': s3Url,
      'userName': userName,
      'utcTimeStamp': utcTimeStamp.toIso8601String(),
      'localPath': localPath
    };
  }
}

@HiveType(typeId: 22)
class TrackingDeviceMedias {
  @HiveField(0)
  List<TrackingDeviceMedia> media;
  TrackingDeviceMedias({
    required this.media,
  });

  factory TrackingDeviceMedias.fromJson(Map<String, dynamic> json) {
    return TrackingDeviceMedias(
      media: (json['media'] as List<dynamic>)
          .map((e) => TrackingDeviceMedia.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media': media.map((e) => e.toJson()).toList(),
    };
  }

  bool get isEmpty => media.isEmpty;
  bool get isNotEmpty => media.isNotEmpty;
  int length() => media.length;
  void add(TrackingDeviceMedia media) {
    int length = this.length();
    if (length > 300) {
      this.media = this.media.sublist(length - 300, length);
    }
    this.media.add(media);
  }

  bool contains(TrackingDeviceMedia media) {
    for (var item in this.media) {
      if (item.s3Url == media.s3Url) {
        return true;
      }
    }
    return false;
  }
}
