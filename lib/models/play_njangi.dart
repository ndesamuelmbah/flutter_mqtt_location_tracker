import 'package:hive/hive.dart';

part 'play_njangi.g.dart';

@HiveType(typeId: 6)
class PlayNjangi extends HiveObject {
  @HiveField(0)
  DateTime playDate;

  @HiveField(1)
  double enteredAmount;

  @HiveField(2)
  String imageUrl;

  @HiveField(3)
  String submittedByUid;

  @HiveField(4)
  String beneficiaryDetails;

  @HiveField(5)
  String playedBy;

  @HiveField(6)
  String? adminComment;

  @HiveField(7)
  String njangiType;

  @HiveField(8)
  String documentId;

  @HiveField(9)
  double njangiAmount;

  @HiveField(10)
  double sharesAmount;

  PlayNjangi({
    required this.playDate,
    required this.enteredAmount,
    required this.imageUrl,
    required this.submittedByUid,
    required this.beneficiaryDetails,
    required this.playedBy,
    this.adminComment,
    required this.njangiType,
    required this.documentId,
    required this.sharesAmount,
    required this.njangiAmount,
  });

  factory PlayNjangi.fromJson(Map<String, dynamic> json) => PlayNjangi(
      playDate: DateTime.parse(json['playDate']),
      enteredAmount: json['enteredAmount'],
      imageUrl: json['imageUrl'],
      submittedByUid: json['submittedByUid'],
      beneficiaryDetails: json['beneficiaryDetails'],
      playedBy: json['playedBy'],
      adminComment: json['adminComment'],
      njangiType: json['njangiType'],
      documentId: json['documentId'],
      njangiAmount: json['njangiAmount'] ?? 0,
      sharesAmount: json['sharesAmount'] ?? 0);

  Map<String, dynamic> toJson() => {
        'playDate': playDate.toIso8601String(),
        'enteredAmount': enteredAmount,
        'imageUrl': imageUrl,
        'submittedByUid': submittedByUid,
        'beneficiaryDetails': beneficiaryDetails,
        'adminComment': adminComment,
        'playedBy': playedBy,
        'njangiType': njangiType,
        'documentId': documentId,
        'sharesAmount': sharesAmount,
        'njangiAmount': njangiAmount
      };
}
