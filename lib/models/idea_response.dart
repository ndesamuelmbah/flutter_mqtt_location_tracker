import 'package:hive/hive.dart';
part 'idea_response.g.dart';

@HiveType(typeId: 1)
class IdeaResponse extends HiveObject {
  @HiveField(0)
  String responseBy;

  @HiveField(1)
  int responseTimestamp;

  @HiveField(2)
  String responseText;

  @HiveField(3)
  int thumbsUp;

  @HiveField(4)
  int thumbsDown;

  @HiveField(5)
  String displayName;

  IdeaResponse({
    required this.responseBy,
    required this.responseTimestamp,
    required this.responseText,
    required this.thumbsUp,
    required this.thumbsDown,
    required this.displayName,
  });

  factory IdeaResponse.fromJson(Map<String, dynamic> json) {
    return IdeaResponse(
      responseBy: json['responseBy'] as String,
      responseTimestamp: (json['responseTimestamp'] ?? 0) as int,
      responseText: json['responseText'] as String,
      thumbsUp: (json['thumbsUp'] ?? 0) as int,
      thumbsDown: (json['thumbsDown'] ?? 0) as int,
      displayName: json['displayName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'responseBy': responseBy,
      'responseTimestamp': responseTimestamp,
      'responseText': responseText,
      'thumbsUp': thumbsUp,
      'thumbsDown': thumbsDown,
      'displayName': displayName
    };
    return data;
  }
}
