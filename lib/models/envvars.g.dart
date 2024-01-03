// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'envvars.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnvVarsAdapter extends TypeAdapter<EnvVars> {
  @override
  final int typeId = 12;

  @override
  EnvVars read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnvVars(
      HEADER: fields[0] as String,
      EMAIL_PASSWORD: fields[1] as String,
      WEB_API_KEY: fields[2] as String,
      APP_NAME: fields[3] as String,
      AWS_ACCESS_KEY: fields[4] as String,
      AWS_SECRET_KEY: fields[5] as String,
      FIREBASE_MESSAGING_VPID: fields[6] as String,
      EMAIL_PASSWORD_HASH_KEY: fields[7] as String,
      EXPIRATION_TIMESTAMP: fields[8] as int,
      MQTT_SERVER_IP: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EnvVars obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.HEADER)
      ..writeByte(1)
      ..write(obj.EMAIL_PASSWORD)
      ..writeByte(2)
      ..write(obj.WEB_API_KEY)
      ..writeByte(3)
      ..write(obj.APP_NAME)
      ..writeByte(4)
      ..write(obj.AWS_ACCESS_KEY)
      ..writeByte(5)
      ..write(obj.AWS_SECRET_KEY)
      ..writeByte(6)
      ..write(obj.FIREBASE_MESSAGING_VPID)
      ..writeByte(7)
      ..write(obj.EMAIL_PASSWORD_HASH_KEY)
      ..writeByte(8)
      ..write(obj.EXPIRATION_TIMESTAMP)
      ..writeByte(9)
      ..write(obj.MQTT_SERVER_IP);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvVarsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
