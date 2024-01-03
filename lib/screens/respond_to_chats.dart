import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/firebase_auth/firebase_auth_bloc.dart';
import 'package:flutter_mqtt_location_tracker/models/chat_message_web.dart';
import 'package:flutter_mqtt_location_tracker/models/chat_room_details.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_loading_shimmer.dart';

class RespondToChatScreen extends StatefulWidget {
  final ChatRoomDetails chatRoomDetails;

  const RespondToChatScreen({Key? key, required this.chatRoomDetails})
      : super(key: key);

  @override
  State<RespondToChatScreen> createState() => _RespondToChatScreenState();
}

class _RespondToChatScreenState extends State<RespondToChatScreen> {
  TextEditingController textEditingController = TextEditingController();

  ScrollController scrollController = ScrollController();

  Size? screenSize;

  final getIt = GetIt.I;

  final Logger logger = Logger('respondToChats');

  @override
  void dispose() {
    textEditingController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollDown() {
    scrollController.animateTo(800,
        duration: const Duration(milliseconds: 900),
        curve: Curves.fastLinearToSlowEaseIn);
  }

  onNewMessage(String message, String phoneNumber) async {
    message = message.trim();
    if (message.length > 1) {
      textEditingController.clear();
      await addStoreMessage(message, phoneNumber);
      _scrollDown();
    }
  }

  Future<bool> addStoreMessage(String message, String phoneNumber) async {
    try {
      int time = DateTime.now().millisecondsSinceEpoch;
      await FirestoreDB.chatsRef
          .doc(widget.chatRoomDetails.customerPhone)
          .collection('messages')
          .doc(getChatMessageId(time))
          .set({
        'message': message,
        'time': time,
        'sentBy': phoneNumber,
        'sentByAdmin': getFirebaseAuthUser(context).isAdmin,
        'isRead': false,
      });
      return Future.value(true);
    } catch (e, stackTrace) {
      logger.severe(e, stackTrace);
      return Future.value(false);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStoreChatMessages(
      String phoneNumber) {
    int startTime =
        DateTime.now().add(const Duration(days: -14)).millisecondsSinceEpoch;
    return FirestoreDB.chatsRef
        .doc(widget.chatRoomDetails.customerPhone)
        .collection('messages')
        .where('time', isGreaterThan: startTime)
        .orderBy('time', descending: true)
        .limit(20)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb
          ? null
          : AppBar(
              title: const Text('Respond to Chat'),
              centerTitle: true,
            ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  elevation: 9,
                  color: Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Customer Name: ${widget.chatRoomDetails.customerName}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Customer Phone: ${widget.chatRoomDetails.customerPhone}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Last Updated: ${DateFormat('E, MMM d, y, h:mm a').format(DateTime.fromMillisecondsSinceEpoch(widget.chatRoomDetails.lastUpdated))}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            if (widget.chatRoomDetails.lastContactMessage !=
                                null) ...[
                              Text(
                                'Last Message: ${widget.chatRoomDetails.lastContactMessage}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ]),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: StreamBuilder<Object>(
                      stream: getStoreChatMessages(
                          widget.chatRoomDetails.customerPhone),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LoadingWidgetsListView();
                        } else {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: Text('There are no messages'),
                            );
                          }
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                  'Sorry! An error has occurred. Please Try Refreshing.'),
                            );
                          } else {
                            final storeChats = (snapshot.data! as QuerySnapshot)
                                .docs
                                .map((e) {
                                  var data = e.data()! as Map<String, dynamic>;
                                  data['messageId'] = e.id;
                                  return ChatMessageWeb.fromJson(data);
                                })
                                .toList()
                                .reversed
                                .toList();
                            if (storeChats.isEmpty) {
                              return const Center(
                                child: Text('There are no messages'),
                              );
                            }
                            return ListView.builder(
                                //shrinkWrap: true,
                                itemCount: storeChats.length,
                                padding: const EdgeInsets.all(8.0),
                                physics: const BouncingScrollPhysics(),
                                controller: scrollController,
                                itemBuilder: (context, index) {
                                  final message = storeChats[index];
                                  final isMe = message.sentBy ==
                                      FirebaseAuth
                                          .instance.currentUser!.phoneNumber;
                                  return Align(
                                    alignment: isMe
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? Colors.blue
                                            : Colors.grey.shade700,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message.message,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            DateFormat('hh:mm a')
                                                .format(message.time),
                                            style: const TextStyle(
                                                color: Colors.white60,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          }
                        }
                      }),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey[200],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: textEditingController,
                              decoration: InputDecoration(
                                hintText: 'Type your message',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                contentPadding: const EdgeInsets.all(8),
                              ),
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              onNewMessage(
                                  textEditingController.text,
                                  FirebaseAuth
                                      .instance.currentUser!.phoneNumber!);
                            },
                            color: Colors.blue.shade100,
                            elevation: 6.0,
                            minWidth: 50.0,
                            height: 50.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Transform.rotate(
                              angle: -20 * 3.141 / 180,
                              child: const Center(
                                child: Icon(
                                  Icons.send,
                                  color: Colors.blue,
                                  size: 35,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ]),
        ),
      ),
    );
  }
}
