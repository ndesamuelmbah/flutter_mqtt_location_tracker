// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_njangi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayNjangiAdapter extends TypeAdapter<PlayNjangi> {
  @override
  final int typeId = 6;

  @override
  PlayNjangi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayNjangi(
        playDate: fields[0] as DateTime,
        enteredAmount: fields[1] as double,
        imageUrl: fields[2] as String,
        submittedByUid: fields[3] as String,
        beneficiaryDetails: fields[4] as String,
        playedBy: fields[5] as String,
        adminComment: fields[6] as String?,
        njangiType: fields[7] as String,
        documentId: fields[8] as String,
        njangiAmount: fields[9] as double,
        sharesAmount: fields[10] as double);
  }

  @override
  void write(BinaryWriter writer, PlayNjangi obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.playDate)
      ..writeByte(1)
      ..write(obj.enteredAmount)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.submittedByUid)
      ..writeByte(4)
      ..write(obj.beneficiaryDetails)
      ..writeByte(5)
      ..write(obj.playedBy)
      ..writeByte(6)
      ..write(obj.adminComment)
      ..writeByte(7)
      ..write(obj.njangiType)
      ..writeByte(8)
      ..write(obj.documentId)
      ..writeByte(9)
      ..write(obj.njangiAmount)
      ..writeByte(10)
      ..write(obj.sharesAmount);
  }
}
