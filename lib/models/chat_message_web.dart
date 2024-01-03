class ChatMessageWeb {
  final String message;
  final DateTime time;
  final String sentBy;
  final bool sentByAdmin;
  final bool isRead;
  final Map<String, dynamic> response;

  ChatMessageWeb(
      {required this.message,
      required this.time,
      required this.sentBy,
      this.sentByAdmin = false,
      this.isRead = false,
      this.response = const {}});

  factory ChatMessageWeb.fromJson(Map<String, dynamic> json) {
    return ChatMessageWeb(
        message: json['message'],
        time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
        sentBy: json['sentBy'],
        isRead: json['isRead'] ?? false,
        sentByAdmin: json['sentByAdmin'] ?? false,
        response: json['response'] ?? const {});
  }
  static List<ChatMessageWeb> defaulChatMessages = [];
}
