import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/message.dart';

// we are going to have our chat service
class ChatService extends ChangeNotifier {

  //o state da nossa base de dados firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //get username


  // Function to send a message
  Future<void> sendMessage(String receiverId, String message) async {
    //get current user info
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp =Timestamp.now();//para podermos mostrar as mensagens em ordem
  
    //creamos a nossa mensagem
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );
    
    //now for us to have the room ID
    List<String> userIds = [currentUserId, receiverId];
    userIds.sort(); // Sort to ensure consistent room ID
    String forumroomId = userIds.join('_'); // Create a unique room ID e combina os dois users

    // e agora salvar a mesnagem no database
    await _firestore
    .collection('forumRoom')//create new collection forum room in firebase
    .doc(forumroomId)//add the doc roomID
    .collection('messages')//a new collection messages
    .add(newMessage.tomap());

  }  
  //now we need one to read the messages to then show them in the chat_page.dart
  //we are going to have a stream builder in the chat page
  //and we are going to use this function to get the messages
  Stream<QuerySnapshot> getMessage(String userId, String receiverId) {
      List<String> userIds = [userId, receiverId];
      userIds.sort(); // Sort to ensure consistent room ID
      String forumroomId = userIds.join('_'); // Create a unique room ID

      return _firestore
          .collection('forumRoom')
          .doc(forumroomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots();
    }
  
}
