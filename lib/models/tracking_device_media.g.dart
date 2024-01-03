// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_device_media.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackingDeviceMediaAdapter extends TypeAdapter<TrackingDeviceMedia> {
  @override
  final int typeId = 21;

  @override
  TrackingDeviceMedia read(BinaryReader reader) {
    return TrackingDeviceMedia(
      description: reader.read() as String,
      s3Url: reader.read() as String,
      userName: reader.read() as String,
      utcTimeStamp: reader.read() as DateTime,
      localPath: reader.read() as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TrackingDeviceMedia obj) {
    writer
      ..write(obj.description)
      ..write(obj.s3Url)
      ..write(obj.userName)
      ..write(obj.utcTimeStamp)
      ..write(obj.localPath);
  }
}

class TrackingDeviceMediasAdapter extends TypeAdapter<TrackingDeviceMedias> {
  @override
  final int typeId = 22;

  @override
  TrackingDeviceMedias read(BinaryReader reader) {
    var numbTrackingIncidents = reader.readByte();
    var media = <TrackingDeviceMedia>[];
    for (var i = 0; i < numbTrackingIncidents; i++) {
      media.add(reader.read() as TrackingDeviceMedia);
    }
    return TrackingDeviceMedias(media: media);
  }

  @override
  void write(BinaryWriter writer, TrackingDeviceMedias obj) {
    writer.writeByte(obj.media.length);
    obj.media.forEach(writer.write);
  }

  // @override
  // TrackingDeviceMedias read(BinaryReader reader) {
  //   return TrackingDeviceMedias(
  //     media: (reader.read() as List).cast<List<TrackingDeviceMedia>>(),
  //   );
  // }

  // @override
  // void write(BinaryWriter writer, TrackingDeviceMedias obj) {
  //   writer.write(obj.media);
  // }
}
