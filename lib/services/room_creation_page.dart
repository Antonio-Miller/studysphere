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
        backgroundColor: Colors.blueAccent,
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
                backgroundColor: Colors.blueAccent,
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

    //O criador da sala é adicionado como participante
    await roomRef.collection('Participants').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'joinedAt': Timestamp.now(),
    });

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RoomsListScreen()),
    );
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
