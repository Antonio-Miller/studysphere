import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send message to a forum post chat
  Future<void> sendMessage(String postId, String message) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    final data= userDoc.data();
    final senderName = data?['full_name'] ?? data?['fullName']?? currentUser.email;

    Message newMessage = Message(
      senderId: currentUser.uid,
      senderEmail: senderName, // Display full name instead of email
      receiverId: '',
      message: message,
      timestamp: Timestamp.now(),
    );

    await _firestore
        .collection('forumRoom')
        .doc(postId)
        .collection('messages')
        .add(newMessage.tomap())
        .then((_)=>print('Message sent successfully')) //to see if we were able to write to firebase
        .catchError((error) => print('Failed to send message: $error'));
         
  }

  // Get messages for a specific post
  Stream<QuerySnapshot> getMessages(String postId) {
    return _firestore
        .collection('forumRoom')
        .doc(postId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }


  //this method is used to send messages in the room chat
  Future<void> sendRoomMessage(String roomId, String message) async {
  final currentUser = _auth.currentUser;
  if (currentUser == null) return;

  
  final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
  final data = userDoc.data();
  final senderName = data?['full_name'] ?? data?['fullName']?? currentUser.email;

  Message newMessage = Message(
    senderId: currentUser.uid,
    senderEmail: senderName,
    receiverId: '',
    message: message,
    timestamp: Timestamp.now(),
  );

  await _firestore //wait and confrim that we stored the roomID with its message
      .collection('StudyRoom')
      .doc(roomId)
      .collection('messages')
      .add(newMessage.tomap());
}

Stream<QuerySnapshot> getRoomMessages(String roomId) {
  return _firestore
      .collection('StudyRoom')
      .doc(roomId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots();
}


}
