import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'RoomChatScreen.dart';
import 'room_details_screen.dart'; // 

class MyRoomsScreen extends StatefulWidget {
  const MyRoomsScreen({super.key});

  @override
  State<MyRoomsScreen> createState() => _MyRoomsScreenState();
}

class _MyRoomsScreenState extends State<MyRoomsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> _userRooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRooms();
  }

  Future<void> _fetchUserRooms() async {
    if (user == null) return;
    final uid = user!.uid;

    try {
      final allRooms = await FirebaseFirestore.instance.collection('StudyRoom').get();
      List<Map<String, dynamic>> userRooms = [];

      for (var room in allRooms.docs) {
        final participant = await FirebaseFirestore.instance
            .collection('StudyRoom')
            .doc(room.id)
            .collection('Participants')
            .doc(uid)
            .get();

        if (participant.exists) {
          final data = room.data();
          data['roomId'] = room.id;
          userRooms.add(data);
        }
      }

      setState(() {
        _userRooms = userRooms;
        _loading = false;
      });
    } catch (e) {
      print('Error fetching user rooms: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // go to room dettails depois
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomDetailsScreen(
                roomId: room['roomId'],
                roomData: room,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // aqui vai ter as informacoes expandidas da sala
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room['name'] ?? 'No Name',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(Icons.book, 'Subject: ${room['subject']}'),
                    _buildDetailRow(Icons.calendar_today, 'Date: ${room['date']}'),
                    _buildDetailRow(Icons.person, 'Creator: ${room['creatorName']}'),
                  ],
                ),
              ),

              
              IconButton(
                icon: const Icon(Icons.chat, color: Colors.blueAccent),
                tooltip: 'Go to Chat Room',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomChatScreen(
                        roomId: room['roomId'],
                        roomName: room['name'] ?? 'No Name',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rooms'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _userRooms.isEmpty
              ? const Center(child: Text('You have not joined any rooms.'))
              : ListView.builder(
                  itemCount: _userRooms.length,
                  itemBuilder: (context, index) {
                    return _buildRoomCard(_userRooms[index]);
                  },
                ),
    );
  }
}
