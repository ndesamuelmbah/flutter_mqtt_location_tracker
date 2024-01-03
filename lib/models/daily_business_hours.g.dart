// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_business_hours.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyBusinessHoursAdapter extends TypeAdapter<DailyBusinessHours> {
  @override
  final int typeId = 13;

  @override
  DailyBusinessHours read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyBusinessHours(
      day: fields[0] as String,
      isOPenOnDay: fields[1] as bool,
      closingTime: fields[3] as String,
      openingTime: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DailyBusinessHours obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.isOPenOnDay)
      ..writeByte(2)
      ..write(obj.openingTime)
      ..writeByte(3)
      ..write(obj.closingTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyBusinessHoursAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
