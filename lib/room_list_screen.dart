import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomsListScreen extends StatelessWidget {
  const RoomsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 190, 206, 245),
      appBar: AppBar(
        title: const Text('Available Rooms'),
        backgroundColor: const Color(0xFF4A6CFF),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('StudyRoom')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No study rooms available.'));
          }

          final rooms = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final data = rooms[index].data() as Map<String, dynamic>;
              final docId = rooms[index].id;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(data['name'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subject: ${data['subject']}'),
                      Text('Date: ${data['date']}'),
                      Text('Creator: ${data['creatorName']}'),
                      Text('Duration: ${data['duration']}'),
                      Text('Max Students: ${data['maxStudents']}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _joinRoom(context, docId, data),
                    child: const Text('Join'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _joinRoom(BuildContext context, String roomId, Map<String, dynamic> roomData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final participantRef = FirebaseFirestore.instance
        .collection('StudyRoom')
        .doc(roomId)
        .collection('Participants')
        .doc(user.uid);

    final participantDoc = await participantRef.get();

    if (!participantDoc.exists) {
      await participantRef.set({
        'uid': user.uid,
        'email': user.email,
        'joinedAt': Timestamp.now(),
      });

      await updateStudyStatistics(
        user.uid,
        isCreator: false,
        durationStr: roomData['duration'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined ${roomData['name']}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already joined this room.')),
      );
    }
  }

  Future<void> updateStudyStatistics(String uid, {required bool isCreator, required String durationStr}) async {
    final statsRef = FirebaseFirestore.instance.collection('StudentStatistics').doc(uid);
    final snapshot = await statsRef.get();

    double parseDuration(String text) {
      final lower = text.toLowerCase().replaceAll(' ', '');
      double hours = 0;
      double minutes = 0;

      final hourMatch = RegExp(r'(\d+(\.\d+)?)h').firstMatch(lower);
      final minMatch = RegExp(r'(\d+(\.\d+)?)m').firstMatch(lower);

      if (hourMatch != null) {
        hours = double.tryParse(hourMatch.group(1)!) ?? 0;
      }
      if (minMatch != null) {
        minutes = double.tryParse(minMatch.group(1)!) ?? 0;
      }

      return hours + (minutes / 60);
    }

    final duration = parseDuration(durationStr);
    if (duration == 0) return;

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      await statsRef.update({
        'roomsCreated': data['roomsCreated'] + (isCreator ? 1 : 0),
        'roomsJoined': data['roomsJoined'] + (isCreator ? 0 : 1),
        'studyTimeHours': (data['studyTimeHours'] as double) + duration,
      });
    } else {
      await statsRef.set({
        'roomsCreated': isCreator ? 1 : 0,
        'roomsJoined': isCreator ? 0 : 1,
        'studyTimeHours': duration,
      });
    }
  }
}
