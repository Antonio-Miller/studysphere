
//so when we send a message we want to know
//sender
//receiver
//their emails and IDs
//and the message
//bonus at what time it was sent

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;//quem enviou;
  final String senderEmail; //think we gon use the full names we will see
  final String receiverId; //quem recebeu
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });
  // how we convert the message to a map
  Map<String, dynamic> tomap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}