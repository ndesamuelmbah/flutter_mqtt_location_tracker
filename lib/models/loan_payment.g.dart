// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_payment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanPaymentAdapter extends TypeAdapter<LoanPayment> {
  @override
  final int typeId = 3;

  @override
  LoanPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanPayment(
      paymentDate: fields[0] as int,
      outStandingBalance: fields[1] as double,
      newStandingBalance: fields[2] as double,
      amountPaid: fields[3] as double,
      recordedByDisplayName: fields[4] as String,
      recordedByUserId: fields[5] as String,
      paymentMessage: fields[6] as String,
      other: fields[7] as String?,
      paymentMethod: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LoanPayment obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.paymentDate)
      ..writeByte(1)
      ..write(obj.outStandingBalance)
      ..writeByte(2)
      ..write(obj.newStandingBalance)
      ..writeByte(3)
      ..write(obj.amountPaid)
      ..writeByte(4)
      ..write(obj.recordedByDisplayName)
      ..writeByte(5)
      ..write(obj.recordedByUserId)
      ..writeByte(6)
      ..write(obj.paymentMessage)
      ..writeByte(7)
      ..write(obj.other)
      ..writeByte(8)
      ..write(obj.paymentMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
