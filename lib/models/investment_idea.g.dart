// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_idea.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvestmentIdeaAdapter extends TypeAdapter<InvestmentIdea> {
  @override
  final int typeId = 0;

  @override
  InvestmentIdea read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvestmentIdea(
      title: fields[0] as String,
      description: fields[1] as String,
      submittedBy: fields[2] as FirebaseAuthUser,
      submissionTime: fields[3] as int,
      ideaOwnerId: fields[4] as String,
      ownerName: fields[5] as String,
      submitionDateTime: fields[6] as String,
      responses: (fields[7] as Map).cast<String, IdeaResponse>(),
      documentId: fields[8] as String,
      thumbsUpList: (fields[9] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, InvestmentIdea obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.submittedBy)
      ..writeByte(3)
      ..write(obj.submissionTime)
      ..writeByte(4)
      ..write(obj.ideaOwnerId)
      ..writeByte(5)
      ..write(obj.ownerName)
      ..writeByte(6)
      ..write(obj.submitionDateTime)
      ..writeByte(7)
      ..write(obj.responses)
      ..writeByte(8)
      ..write(obj.documentId)
      ..writeByte(9)
      ..write(obj.thumbsUpList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestmentIdeaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
