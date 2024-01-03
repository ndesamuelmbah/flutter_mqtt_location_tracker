import 'package:flutter_mqtt_location_tracker/models/chat_message.dart';

class Conversation {
  final String id;
  final List<ChatMessage> messages;

  Conversation({
    required this.id,
    required this.messages,
  });
}
