class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final String? parentId;
  final String? parentText;
  final bool isDeleted;

  ChatMessage(
      {required this.id,
      required this.senderId,
      required this.receiverId,
      required this.text,
      required this.timestamp,
      this.parentId,
      this.parentText,
      this.isDeleted = false});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      text: json['text'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      parentId: json['parentId'],
      parentText: json['parentText'],
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'parentId': parentId,
      'parentText': parentText,
      'isDeleted': isDeleted
    };
  }
}
