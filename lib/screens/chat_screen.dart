import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  TextEditingController _textController = TextEditingController();

  bool _isTagging = false;
  String? _taggedMessageId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        // If the user scrolls to the bottom of the chat, mark all messages as read
        FirestoreDB.chatsRef.doc(widget.chatId).update({'unreadMessages': 0});
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _messageController.clear();
      await FirestoreDB.chatsRef.doc(widget.chatId).collection('messages').add({
        'sender': 'User A', // Replace with actual sender name
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (_isTagging) {
        // If the user is tagging a message, add the tag to the message
        await FirestoreDB.chatsRef
            .doc(widget.chatId)
            .collection('messages')
            .doc(_taggedMessageId)
            .collection('tags')
            .add({
          'text': message,
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          _isTagging = false;
        });
      }
    }
  }

  Widget _buildMessage(DocumentSnapshot messageSnapshot) {
    final message = messageSnapshot.data() as Map<String, dynamic>;
    final isTaggedMessage = message['isTagged'] ?? false;
    return GestureDetector(
      onTap: () {
        if (!isTaggedMessage) {
          // If the message is not already tagged, allow the user to tag it
          setState(() {
            _isTagging = true;
            _taggedMessageId = messageSnapshot.id;
            _messageController.text = '@${message['sender']} ';
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isTaggedMessage ? Colors.grey[300] : Colors.blue,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isTaggedMessage ? 20 : 0),
            bottomRight: Radius.circular(isTaggedMessage ? 0 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['sender'],
              style: TextStyle(
                color: isTaggedMessage ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message['text'],
              style: TextStyle(
                color: isTaggedMessage ? Colors.black : Colors.white,
              ),
            ),
            if (isTaggedMessage)
              StreamBuilder<QuerySnapshot>(
                stream: FirestoreDB.chatsRef
                    .doc(widget.chatId)
                    .collection('messages')
                    .doc(messageSnapshot.id)
                    .collection('tags')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const SizedBox(
                        height: 8,
                        child: LinearProgressIndicator(),
                      );
                    default:
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final tag = snapshot.data!.docs[index];
                          return Text(
                            '${tag['text']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          );
                        },
                      );
                  }
                },
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${DateTime.fromMillisecondsSinceEpoch(message['timestamp'].millisecondsSinceEpoch).toLocal().hour}:${DateTime.fromMillisecondsSinceEpoch(message['timestamp'].millisecondsSinceEpoch).toLocal().minute}',
                  style: TextStyle(
                    color: isTaggedMessage ? Colors.black : Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreDB.chatsRef
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const SizedBox(
                      height: 8,
                      child: LinearProgressIndicator(),
                    );
                  default:
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // Scroll to the bottom of the chat when new messages arrive
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        final messageSnapshot = snapshot.data!.docs[index];
                        return _buildMessage(messageSnapshot);
                      },
                    );
                }
              },
            ),
          ),
          if (_isTagging)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey),
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Text(
                    'Replying to:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirestoreDB.chatsRef
                          .doc(widget.chatId)
                          .collection('messages')
                          .doc(_taggedMessageId!)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return const Text('Loading...');
                          default:
                            final taggedMessage = snapshot.data!;
                            return Text(
                              '${taggedMessage['text']}',
                              overflow: TextOverflow.ellipsis,
                            );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      setState(() {
                        _isTagging = false;
                        _taggedMessageId = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.tag),
                  onPressed: () async {
                    setState(() {
                      _isTagging = true;
                    });

                    final taggedMessageId = await Navigator.of(context)
                        .push(MaterialPageRoute<String>(
                      builder: (BuildContext context) => TagMessageScreen(
                        chatId: widget.chatId,
                      ),
                    ));

                    setState(() {
                      _isTagging = false;
                      _taggedMessageId = taggedMessageId;
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (message) {
                      _sendMessage();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TagMessageScreen extends StatefulWidget {
  final String chatId;

  const TagMessageScreen({super.key, required this.chatId});

  @override
  TagMessageScreenState createState() => TagMessageScreenState();
}

class TagMessageScreenState extends State<TagMessageScreen> {
  QueryDocumentSnapshot? _selectedMessage;

  Widget _buildMessage(QueryDocumentSnapshot messageSnapshot) {
    final message = messageSnapshot.data()! as Map<String, dynamic>;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMessage = messageSnapshot;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: const Border(
            bottom: BorderSide(color: Colors.grey),
          ),
          color: _selectedMessage?.id == messageSnapshot.id
              ? Colors.grey[200]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${message['senderName']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              message['text'],
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${DateTime.fromMillisecondsSinceEpoch(message['timestamp'].millisecondsSinceEpoch).toLocal().hour}:${DateTime.fromMillisecondsSinceEpoch(message['timestamp'].millisecondsSinceEpoch).toLocal().minute}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text('Tag Message'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreDB.chatsRef
            .doc(widget.chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Text('Loading...');
            default:
              final messages = snapshot.data!.docs;
              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  //final message = messages[index].data();
                  return _buildMessage(messages[index]);
                },
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedMessage != null) {
            Navigator.of(context).pop(_selectedMessage!.id);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
