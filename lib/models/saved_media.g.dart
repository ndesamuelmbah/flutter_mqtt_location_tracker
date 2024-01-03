// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_media.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedMediaAdapter extends TypeAdapter<SavedMedia> {
  @override
  final int typeId = 8;

  @override
  SavedMedia read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedMedia(
      submissionDate: fields[0] as DateTime,
      submittedByName: fields[1] as String,
      submittedByUid: fields[2] as String,
      mediaDescription: fields[3] as String,
      mediaUrl: fields[4] as String,
      submittedByRole: fields[5] as String,
      extension: fields[6] as String,
      mediaAbout: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SavedMedia obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.submissionDate)
      ..writeByte(1)
      ..write(obj.submittedByName)
      ..writeByte(2)
      ..write(obj.submittedByUid)
      ..writeByte(3)
      ..write(obj.mediaDescription)
      ..writeByte(4)
      ..write(obj.mediaUrl)
      ..writeByte(5)
      ..write(obj.submittedByRole)
      ..writeByte(6)
      ..write(obj.extension)
      ..writeByte(7)
      ..write(obj.mediaAbout);
  }
}

class SavedMediaFilesAdapter extends TypeAdapter<SavedMediaFiles> {
  @override
  final int typeId = 9;

  @override
  SavedMediaFiles read(BinaryReader reader) {
    var numberOfFiles = reader.readByte();
    var mediaFiles = <SavedMedia>[];
    for (var i = 0; i < numberOfFiles; i++) {
      mediaFiles.add(reader.read() as SavedMedia);
    }
    return SavedMediaFiles(mediaFiles: mediaFiles);
  }

  @override
  void write(BinaryWriter writer, SavedMediaFiles obj) {
    writer.writeByte(obj.mediaFiles.length);
    obj.mediaFiles.forEach(writer.write);
  }
}
