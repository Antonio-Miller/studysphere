import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoomDetailsScreen extends StatefulWidget {
  final String roomId;
  final Map<String, dynamic> roomData;

  const RoomDetailsScreen({
    super.key,
    required this.roomId,
    required this.roomData,
  });

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  List<Map<String, dynamic>> _participants = [];
  bool _loading = true;
  bool _isCompleted = false;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    _fetchParticipants();
    _checkIfCompleted();
  }

  Future<void> _fetchParticipants() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('StudyRoom')
        .doc(widget.roomId)
        .collection('Participants')
        .get();

    setState(() {
      _participants = snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id; // vai actualizar as classificacoes dos participantes da room
        return data;
      }).toList();
      _loading = false;
    });
  }

  Future<void> _checkIfCompleted() async {
    final doc = await FirebaseFirestore.instance
        .collection('StudyRoom')
        .doc(widget.roomId)
        .get();

    setState(() {
      _isCompleted = doc.data()?['completed'] ?? false;
    });
  }

  Future<void> _markSessionCompleted() async {
    await FirebaseFirestore.instance
        .collection('StudyRoom')
        .doc(widget.roomId)
        .update({'completed': true});

    setState(() {
      _isCompleted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session marked as completed')),
    );
  }

  Future<void> _updateRating(String participantId, int newRating) async {
  final participantRef = FirebaseFirestore.instance
      .collection('StudyRoom')
      .doc(widget.roomId)
      .collection('Participants')
      .doc(participantId);

  final doc = await participantRef.get();

  if (!doc.exists) return;

  final data = doc.data()!;
  final currentRating = (data['rating'] ?? 0).toDouble();
  final ratingCount = (data['ratingCount'] ?? 0);

  // calcula a media de ratings
  final updatedCount = ratingCount + 1;
  final updatedRating = ((currentRating * ratingCount) + newRating) / updatedCount;

  await participantRef.update({
    'rating': updatedRating,
    'ratingCount': updatedCount,
  });

  setState(() {
    final index = _participants.indexWhere((p) => p['uid'] == participantId);
    if (index != -1) {
      _participants[index]['rating'] = updatedRating;
      _participants[index]['ratingCount'] = updatedCount;
    }
  });
}


  @override
  Widget build(BuildContext context) {
    final room = widget.roomData;

    return Scaffold(
      appBar: AppBar(
        title: Text(room['name'] ?? 'Room Details'),
        backgroundColor: const Color(0xFF4A6CFF),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject: ${room['subject']}', style: const TextStyle(fontSize: 16)),
                  Text('Date: ${room['date']}', style: const TextStyle(fontSize: 16)),
                  Text('Creator: ${room['creatorName']}', style: const TextStyle(fontSize: 16)),
                  Text('Duration: ${room['duration']}', style: const TextStyle(fontSize: 16)),
                  Text('Max Students: ${room['maxStudents']}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  const Text('Participants:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._participants.map((p) {
                    final isCurrentUser = p['email'] == _currentUserEmail;
                    final rating = p['rating'] ?? 0;

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(p['email'] ?? 'Unknown'),
                        subtitle: isCurrentUser
                            ? null
                            : Row(
                                children: List.generate(5, (starIndex) {
                                  final filled = rating > starIndex;
                                  final isDisabled = _isCompleted;

                                  return IconButton(
                                    icon: Icon(
                                      filled ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    onPressed: isDisabled
                                        ? null
                                        : () => _updateRating(p['uid'], starIndex + 1),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  );
                                }),
                              ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  if (!_isCompleted && room['creatorUid'] == FirebaseAuth.instance.currentUser?.uid)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Mark Session as Completed'),
                        onPressed: _markSessionCompleted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A6CFF),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    )
                  else if (_isCompleted)
                    const Center(
                      child: Text(
                        'Session Completed\nRatings are locked.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A6CFF),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
