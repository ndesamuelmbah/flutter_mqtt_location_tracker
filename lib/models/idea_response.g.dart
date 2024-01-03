// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idea_response.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IdeaResponseAdapter extends TypeAdapter<IdeaResponse> {
  @override
  final int typeId = 1;

  @override
  IdeaResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdeaResponse(
      responseBy: fields[0] as String,
      responseTimestamp: fields[1] as int,
      responseText: fields[2] as String,
      thumbsUp: fields[3] as int,
      thumbsDown: fields[4] as int,
      displayName: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, IdeaResponse obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.responseBy)
      ..writeByte(1)
      ..write(obj.responseTimestamp)
      ..writeByte(2)
      ..write(obj.responseText)
      ..writeByte(3)
      ..write(obj.thumbsUp)
      ..writeByte(4)
      ..write(obj.thumbsDown)
      ..writeByte(5)
      ..write(obj.displayName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
