// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_update.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanUpdateAdapter extends TypeAdapter<LoanUpdate> {
  @override
  final int typeId = 2;

  @override
  LoanUpdate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanUpdate(
      updateDate: fields[0] as int,
      outstandingBalance: fields[1] as double,
      updatedByDisplayName: fields[2] as String,
      updatedByUserId: fields[3] as String,
      updateMessage: fields[4] as String,
      other: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LoanUpdate obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.updateDate)
      ..writeByte(1)
      ..write(obj.outstandingBalance)
      ..writeByte(2)
      ..write(obj.updatedByDisplayName)
      ..writeByte(3)
      ..write(obj.updatedByUserId)
      ..writeByte(4)
      ..write(obj.updateMessage)
      ..writeByte(5)
      ..write(obj.other);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanUpdateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
