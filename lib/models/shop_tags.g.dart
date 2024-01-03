// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_tags.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShopTagAdapter extends TypeAdapter<ShopTag> {
  @override
  final int typeId = 14;

  @override
  ShopTag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopTag(
      tagsList: (fields[0] as List).cast<String>(),
      tagGroup: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ShopTag obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.tagsList)
      ..writeByte(1)
      ..write(obj.tagGroup);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopTagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShopTagsAdapter extends TypeAdapter<ShopTags> {
  @override
  final int typeId = 15;

  @override
  ShopTags read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopTags(
      tags: (fields[0] as List).cast<ShopTag>(),
    );
  }

  @override
  void write(BinaryWriter writer, ShopTags obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopTagsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
