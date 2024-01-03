import 'package:hive/hive.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter_mqtt_location_tracker/models/idea_response.dart';

part 'investment_idea.g.dart';

@HiveType(typeId: 0)
class InvestmentIdea {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  FirebaseAuthUser submittedBy;

  @HiveField(3)
  int submissionTime;

  @HiveField(4)
  String ideaOwnerId;

  @HiveField(5)
  String ownerName;

  @HiveField(6)
  String submitionDateTime;

  @HiveField(7)
  Map<String, IdeaResponse> responses;

  @HiveField(8)
  String documentId;

  @HiveField(9)
  List<dynamic> thumbsUpList;

  InvestmentIdea(
      {required this.title,
      required this.description,
      required this.submittedBy,
      required this.submissionTime,
      required this.ideaOwnerId,
      required this.ownerName,
      required this.submitionDateTime,
      required this.responses,
      required this.documentId,
      required this.thumbsUpList});

  factory InvestmentIdea.fromJson(Map<String, dynamic> json) {
    var responses = ((json['responses'] ?? {}) as Map).map((key, value) =>
        MapEntry(key.toString(),
            IdeaResponse.fromJson(value as Map<String, dynamic>)));
    return InvestmentIdea(
        title: json['title'] as String,
        description: json['description'] as String,
        submittedBy: FirebaseAuthUser.fromJson(
            json['submittedBy'] as Map<String, dynamic>),
        submissionTime: json['submissionTime'] as int,
        ideaOwnerId: json['ideaOwnerId'] as String,
        ownerName: json['ownerName'] as String,
        submitionDateTime: json['submitionDateTime'] as String,
        responses: responses,
        documentId: json['documentId'],
        thumbsUpList: (json['thumbsUpList'] ?? []) as List<dynamic>);
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'submittedBy': submittedBy.toJson(),
        'submissionTime': submissionTime,
        'ideaOwnerId': ideaOwnerId,
        'ownerName': ownerName,
        'submitionDateTime': submitionDateTime,
        'responses':
            responses.map((key, value) => MapEntry(key, value.toJson())),
        'documentId': documentId,
        'thumbsUpList': thumbsUpList,
      };
}
