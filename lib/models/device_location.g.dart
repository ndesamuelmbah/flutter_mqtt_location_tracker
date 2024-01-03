// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_location.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeviceLocationAdapter extends TypeAdapter<DeviceLocation> {
  @override
  final int typeId = 19;

  @override
  DeviceLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeviceLocation(
      email: fields[0] as String,
      deviceHash: fields[1] as String,
      lon: fields[2] as double,
      lat: fields[3] as double,
      timestamp: fields[4] as int,
      accuracy: fields[5] as double?,
      altitude: fields[6] as double?,
      altitudeAccuracy: fields[7] as double?,
      floor: fields[8] as int?,
      heading: fields[9] as double?,
      headingAccuracy: fields[10] as double?,
      speed: fields[11] as double?,
      speedAccuracy: fields[12] as double?,
      isMocked: fields[13] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, DeviceLocation obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.deviceHash)
      ..writeByte(2)
      ..write(obj.lon)
      ..writeByte(3)
      ..write(obj.lat)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.accuracy)
      ..writeByte(6)
      ..write(obj.altitude)
      ..writeByte(7)
      ..write(obj.altitudeAccuracy)
      ..writeByte(8)
      ..write(obj.floor)
      ..writeByte(9)
      ..write(obj.heading)
      ..writeByte(10)
      ..write(obj.headingAccuracy)
      ..writeByte(11)
      ..write(obj.speed)
      ..writeByte(12)
      ..write(obj.speedAccuracy)
      ..writeByte(13)
      ..write(obj.isMocked);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId);
}

class DeviceLocationsAdapter extends TypeAdapter<DeviceLocations> {
  @override
  final int typeId = 20;

  @override
  DeviceLocations read(BinaryReader reader) {
    var numOfDevices = reader.readByte();
    var deviceLocations = <DeviceLocation>[];
    for (var i = 0; i < numOfDevices; i++) {
      deviceLocations.add(reader.read() as DeviceLocation);
    }
    return DeviceLocations(deviceLocations: deviceLocations);
  }

  @override
  void write(BinaryWriter writer, DeviceLocations obj) {
    writer.writeByte(obj.deviceLocations.length);
    obj.deviceLocations.forEach(writer.write);
  }
}
