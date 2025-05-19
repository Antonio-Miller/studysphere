import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                  padding: const EdgeInsets.all(16),
                  itemCount: _userRooms.length,
                  itemBuilder: (context, index) {
                    final room = _userRooms[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(room['name'] ?? 'No Name'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Subject: ${room['subject']}'),
                            Text('Date: ${room['date']}'),
                            Text('Creator: ${room['creatorName']}'),
                            Text('Duration: ${room['duration']}'),
                            Text('Max Students: ${room['maxStudents']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
