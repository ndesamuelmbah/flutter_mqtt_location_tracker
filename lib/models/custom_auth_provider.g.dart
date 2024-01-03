// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_auth_provider.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomAuthProviderAdapter extends TypeAdapter<CustomAuthProvider> {
  @override
  final int typeId = 17;

  @override
  CustomAuthProvider read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomAuthProvider(
      providerId: fields[0] as String?,
      uid: fields[1] as String?,
      displayName: fields[2] as String?,
      photoUrl: fields[3] as String?,
      email: fields[4] as String?,
      phoneNumber: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomAuthProvider obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.providerId)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.phoneNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomAuthProviderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
