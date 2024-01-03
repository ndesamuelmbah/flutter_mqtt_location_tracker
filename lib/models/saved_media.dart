import 'package:hive/hive.dart';

part 'saved_media.g.dart';

@HiveType(typeId: 8)
class SavedMedia extends HiveObject {
  @HiveField(0)
  DateTime submissionDate;

  @HiveField(1)
  String submittedByName;

  @HiveField(2)
  String submittedByUid;

  @HiveField(3)
  String mediaDescription;

  @HiveField(4)
  String mediaUrl;

  @HiveField(5)
  String submittedByRole;

  @HiveField(6)
  String extension;

  @HiveField(7)
  String mediaAbout;

  SavedMedia(
      {required this.submissionDate,
      required this.submittedByName,
      required this.submittedByUid,
      required this.mediaDescription,
      required this.mediaUrl,
      required this.submittedByRole,
      required this.extension,
      required this.mediaAbout});

  factory SavedMedia.fromJson(Map<String, dynamic> json) {
    return SavedMedia(
        submissionDate: DateTime.parse(json['submissionDate']),
        submittedByName: json['submittedByName'],
        submittedByUid: json['submittedByUid'],
        mediaDescription: json['mediaDescription'],
        mediaUrl: json['mediaUrl'],
        submittedByRole: json['submittedByRole'],
        extension: json['extension'],
        mediaAbout: json['mediaAbout'] ?? 'Loans & Njangi');
  }

  Map<String, dynamic> toJson() {
    return {
      'submissionDate': submissionDate.toIso8601String(),
      'submittedByName': submittedByName,
      'submittedByUid': submittedByUid,
      'mediaDescription': mediaDescription,
      'mediaUrl': mediaUrl,
      'submittedByRole': submittedByRole,
      'extension': extension,
      'mediaAbout': mediaAbout
    };
  }
}

@HiveType(typeId: 9)
class SavedMediaFiles extends HiveObject {
  @HiveField(0)
  List<SavedMedia> mediaFiles;
  SavedMediaFiles({required this.mediaFiles});
}
