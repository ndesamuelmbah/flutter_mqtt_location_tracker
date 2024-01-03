import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/models/chat_message.dart';

class ChatService {
  Stream<List<ChatMessage>> getChats(String userId) {
    return FirestoreDB.chatsRef
        .where('userIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ChatMessage.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> sendMessage(String chatId, ChatMessage message) async {
    final messageDocRef =
        FirestoreDB.chatsRef.doc(chatId).collection('messages').doc();

    final messageData = message.toJson();
    messageData['id'] = messageDocRef.id;

    await messageDocRef.set(messageData);

    final members = messageData['members'] as List<String>;

    for (final memberId in members) {
      if (memberId != messageData['senderId']) {
        await _markMessagesAsUnread(chatId, memberId, [messageData['id']]);
      }
    }
  }

  // Stream<List<ChatMessage>> getMessages(String chatId, String userId) {
  //   final chatRef = _db.collection('chats').doc(chatId);

  //   // Update the lastReadTimestamp field for the current user when the chat screen becomes visible
  //   WidgetsBinding.instance.addObserver(_ChatScreenState(chatRef, userId));

  //   return chatRef
  //       .collection('messages')
  //       .orderBy('timestamp', descending: true)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs.map((doc) => ChatMessage.fromDoc(doc, userId)).toList());
  // }

  Future<void> markAllMessagesAsRead(String chatId, String userId) async {
    final chatRef = FirestoreDB.chatsRef.doc(chatId);
    final currentUserRef = chatRef.collection('users').doc(userId);

    await currentUserRef.update({'lastReadTimestamp': Timestamp.now()});

    // Remove all unread messages for the current user
    final unreadMessages = await _getUnreadMessages(chatId, userId);
    await _removeUnreadMessages(chatId, userId, unreadMessages);
  }

  Future<void> _markMessagesAsUnread(
      String chatId, String userId, List<String> messages) async {
    final currentUserRef = _getChatRef(chatId, userId);
    await currentUserRef
        .update({'unreadMessages': FieldValue.arrayUnion(messages)});
  }

  Future<Set<String>> _getUnreadMessages(String chatId, String userId) async {
    final currentUserRef = _getChatRef(chatId, userId);
    final doc = await currentUserRef.get();

    final unreadMessages = doc['unreadMessages'] as List<dynamic>;
    return Set.from(unreadMessages.map((id) => id as String));
  }

  Future<void> _removeUnreadMessages(
      String chatId, String userId, Set<String> messages) async {
    final currentUserRef = _getChatRef(chatId, userId);
    await currentUserRef
        .update({'unreadMessages': FieldValue.arrayRemove(messages.toList())});
  }

  DocumentReference _getChatRef(String chatId, String userId) {
    return FirestoreDB.chatsRef.doc(chatId).collection('users').doc(userId);
  }
}
