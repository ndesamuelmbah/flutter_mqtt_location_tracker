// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_gaurantor_approver.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanGuarantorApproverAdapter extends TypeAdapter<LoanGuarantorApprover> {
  @override
  final int typeId = 5;

  @override
  LoanGuarantorApprover read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanGuarantorApprover(
      gaurantorApprovalDate: fields[0] as DateTime,
      gaurantorSignature: fields[1] as String,
      gaurantorUid: fields[2] as String,
      gaurantorName: fields[3] as String,
      loanId: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LoanGuarantorApprover obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.gaurantorApprovalDate)
      ..writeByte(1)
      ..write(obj.gaurantorSignature)
      ..writeByte(2)
      ..write(obj.gaurantorUid)
      ..writeByte(3)
      ..write(obj.gaurantorName)
      ..writeByte(4)
      ..write(obj.loanId);
  }
}
