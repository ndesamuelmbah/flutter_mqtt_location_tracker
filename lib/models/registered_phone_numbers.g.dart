// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registered_phone_numbers.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RegisteredPhoneNumbersAdapter
    extends TypeAdapter<RegisteredPhoneNumbers> {
  @override
  final int typeId = 18;

  @override
  RegisteredPhoneNumbers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RegisteredPhoneNumbers(
      registeredPhonesNumbers: fields[0] as List<String>,
    );
  }

  @override
  void write(BinaryWriter writer, RegisteredPhoneNumbers obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.registeredPhonesNumbers);
  }
}
