// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_authentications.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingAuthenticationsAdapter
    extends TypeAdapter<PendingAuthentications> {
  @override
  final int typeId = 11;

  @override
  PendingAuthentications read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingAuthentications(
      isSignedIn: fields[0] as bool,
      timeStamp: fields[1] as int,
      uid: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PendingAuthentications obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.isSignedIn)
      ..writeByte(1)
      ..write(obj.timeStamp)
      ..writeByte(2)
      ..write(obj.uid);
  }
}
