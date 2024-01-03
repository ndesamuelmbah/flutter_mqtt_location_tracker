// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_menu.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoreMenuItemAdapter extends TypeAdapter<StoreMenuItem> {
  @override
  final int typeId = 10;

  @override
  StoreMenuItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreMenuItem(
      itemId: fields[1] as int,
      itemName: fields[2] as String,
      itemDescription: fields[3] as String,
      itemPrice: fields[4] as double,
      image: fields[5] as String,
      storeId: fields[6] as num,
      isInStock: fields[7] as int,
      quantityInStock: fields[8] as int,
      deliveryPrice: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, StoreMenuItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(1)
      ..write(obj.itemId)
      ..writeByte(2)
      ..write(obj.itemName)
      ..writeByte(3)
      ..write(obj.itemDescription)
      ..writeByte(4)
      ..write(obj.itemPrice)
      ..writeByte(5)
      ..write(obj.image)
      ..writeByte(6)
      ..write(obj.storeId)
      ..writeByte(7)
      ..write(obj.isInStock)
      ..writeByte(8)
      ..write(obj.quantityInStock)
      ..writeByte(9)
      ..write(obj.deliveryPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreMenuItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
