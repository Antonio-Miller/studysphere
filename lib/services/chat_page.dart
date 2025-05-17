//this will be our room page
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/chat/chat_service.dart';
import '../forum/forum_page.dart';
import 'package:flutter_application_1/authentic/authentic_service.dart';
import 'package:flutter_application_1/authentic/login_page.dart';
import 'package:flutter_application_1/bottom_bar.dart';

class ChatRoom extends StatefulWidget {
  final String title;//this will be the name on top of the room
  final String receiveremail;
  final String receiverId;

  const ChatRoom({super.key,
      required this.receiveremail, 
      required this.receiverId,
      required this.title,
  });

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom>{
  //okay so now lets start building the design of our chat room
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;


  void sendMessage() async {
    String message = _messageController.text.trim();
    //vai garantir que nao podemos mandar mensagens vazias
    if (message.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverId,_messageController.text);
      _messageController.clear();//clean the controller after clicking send
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar (title: Text(widget.title),
        backgroundColor: Colors.blueAccent,
        centerTitle: true),
      body: Column(
        children: [Expanded(
          child: _buildMessageList(),
          

         ),
        
        _buildMessageInput(),
        
        ],

      ),
   
    );
  }
  //message list
  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessage(_auth.currentUser!.uid, widget.receiverId),
      builder: (context, snapshot) {
        if(snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar mensagens.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhuma mensagem ainda.'));
        }
        final messages = snapshot.data!.docs;
        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(messages[index]);
          },
        );
      },
    );
  }

  //message item
  Widget _buildMessageItem(DocumentSnapshot documnet){
    Map<String, dynamic> data = documnet.data() as Map<String, dynamic>;
  var aligment =(data['senderId'] == _auth.currentUser!.uid) 
  ?Alignment.centerRight 
  : Alignment.centerLeft;
  
  return Container(
    alignment: aligment,
    child: Column(
      children: [
        Text(data['senderEmail']?? 'Email desconhecido',),
        Text(data['message']?? 'Mensagem vazia',),
      ],
    ),
  );
  
  
  
  
  }

  //message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Digite sua mensagem...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }




}
