import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../room_list_screen.dart';

class RoomCreationScreen extends StatefulWidget {
  const RoomCreationScreen({super.key});

  @override
  State<RoomCreationScreen> createState() => _RoomCreationScreenState();
}

class _RoomCreationScreenState extends State<RoomCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _maxStudentsController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Study Room'),
        backgroundColor: const Color(0xFF4A6CFF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildField(_nameController, 'Room Name'),
            _buildField(_subjectController, 'Subject'),
            _buildField(_maxStudentsController, 'Max Students'),
            _buildField(_durationController, 'Duration (e.g., 2h)'),
            _buildField(_dateController, 'Date & Time'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6CFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Create Room'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Future<void> _createRoom() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final roomData = {
      'name': _nameController.text.trim(),
      'subject': _subjectController.text.trim(),
      'maxStudents': _maxStudentsController.text.trim(),
      'duration': _durationController.text.trim(),
      'date': _dateController.text.trim(),
      'creatorUid': user.uid,
      'creatorName': user.email ?? 'Unknown',
      'createdAt': Timestamp.now(),
    };

    final roomRef = await FirebaseFirestore.instance.collection('StudyRoom').add(roomData);

    await roomRef.collection('Participants').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'joinedAt': Timestamp.now(),
    });

    await updateStudyStatistics(
      user.uid,
      isCreator: true,
      durationStr: _durationController.text,
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RoomsListScreen()),
    );
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

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _maxStudentsController.dispose();
    _durationController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
