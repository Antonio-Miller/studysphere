import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat/chat_service.dart';
import '../models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoom extends StatefulWidget {
  final String postId;
  final String title;

  const ChatRoom({super.key, required this.postId, required this.title});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    final text = _messageController.text.trim();	
    if (text.isEmpty) return;
    print('Sending message: $text');//this is for debugging
    await _chatService.sendMessage(widget.postId, _messageController.text.trim());
    _messageController.clear();
  }

 Widget _buildMessageList() {
  return StreamBuilder<QuerySnapshot>(
    stream: _chatService.getMessages(widget.postId),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        print('Stream error: ${snapshot.error}');
        return const Center(child: Text('Something went wrong...'));
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      // No data
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text('No messages yet.'));
      }

      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: snapshot.data!.docs.map((doc) {
          try {
            final message = Message.fromMap(doc.data() as Map<String, dynamic>);
            final isCurrentUser = message.senderId == _firebaseAuth.currentUser?.uid;

            return Align(
              alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.blue[200] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment:
                      isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.senderEmail,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.message,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          } catch (e) {
            print('Error building message from Firestore: $e');
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Could not load message.'),
            );
          }
        }).toList(),
      );
    },
  );
}


  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              hintText: 'Type your message...',
              contentPadding: EdgeInsets.all(10),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: sendMessage,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildMessageInput(),
          ),
        ],
      ),
    );
  }
}
