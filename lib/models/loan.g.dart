// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanAdapter extends TypeAdapter<Loan> {
  @override
  final int typeId = 4;

  @override
  Loan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Loan(
        ownerId: fields[0] as String,
        loanRequestReason: fields[1] as String,
        requestedDate: fields[2] as int,
        proposedRepaymentDate: fields[3] as int,
        outStandingBalance: fields[4] as double,
        payments: (fields[5] as List).cast<LoanPayment>(),
        loanUpdates: (fields[6] as List).cast<LoanUpdate>(),
        approvalDate: fields[7] as int?,
        loanDueDate: fields[8] as int?,
        ownerName: fields[9] as String,
        ownerShares: fields[10] as int,
        gaurantors: (fields[11] as List).cast<FirebaseAuthUser>(),
        requesterSignature: fields[12] as String,
        loanId: fields[13] as String,
        monthlyInterestRate: fields[14] as double,
        submissionDate: fields[15] as int,
        approvedGaurantors: (fields[16] as List).cast<LoanGuarantorApprover>(),
        supportingDocuments: (fields[17] as List).cast<List<String>>());
  }

  @override
  void write(BinaryWriter writer, Loan obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.ownerId)
      ..writeByte(1)
      ..write(obj.loanRequestReason)
      ..writeByte(2)
      ..write(obj.requestedDate)
      ..writeByte(3)
      ..write(obj.proposedRepaymentDate)
      ..writeByte(4)
      ..write(obj.outStandingBalance)
      ..writeByte(5)
      ..write(obj.payments)
      ..writeByte(6)
      ..write(obj.loanUpdates)
      ..writeByte(7)
      ..write(obj.approvalDate)
      ..writeByte(8)
      ..write(obj.loanDueDate)
      ..writeByte(9)
      ..write(obj.ownerName)
      ..writeByte(10)
      ..write(obj.ownerShares)
      ..writeByte(11)
      ..write(obj.gaurantors)
      ..writeByte(12)
      ..write(obj.requesterSignature)
      ..writeByte(13)
      ..write(obj.loanId)
      ..writeByte(14)
      ..write(obj.monthlyInterestRate)
      ..writeByte(15)
      ..write(obj.submissionDate)
      ..writeByte(16)
      ..write(obj.approvedGaurantors)
      ..writeByte(17)
      ..write(obj.supportingDocuments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
