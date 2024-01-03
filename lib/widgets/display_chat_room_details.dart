import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/models/chat_room_details.dart';
import 'package:flutter_mqtt_location_tracker/screens/respond_to_chats.dart';

class ChatRoomDetailsWidget extends StatelessWidget {
  final ChatRoomDetails chatRoomDetails;

  const ChatRoomDetailsWidget({
    Key? key,
    required this.chatRoomDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RespondToChatScreen(
              chatRoomDetails: chatRoomDetails,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  chatRoomDetails.customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  DateTime.fromMillisecondsSinceEpoch(
                          chatRoomDetails.lastUpdated)
                      .toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              chatRoomDetails.customerPhone,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            if (chatRoomDetails.lastContactMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                chatRoomDetails.lastContactMessage!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
