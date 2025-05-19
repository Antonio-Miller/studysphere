import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/authentic/authentic_service.dart';
import 'package:flutter_application_1/authentic/login_page.dart';
import 'package:flutter_application_1/bottom_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authen = AuthenticService();
  String? _userName;
  double? _averageRating;
  int _roomsCreated = 0;
  int _roomsJoined = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('User').doc(uid).get();
    final data = userDoc.data();
    _userName = data?['full_name'] ?? data?['fullName'] ?? 'No name';

    // Fetch rooms created
    final roomsCreatedSnapshot = await FirebaseFirestore.instance
        .collection('StudyRoom')
        .where('creatorUid', isEqualTo: uid)
        .get();
    _roomsCreated = roomsCreatedSnapshot.docs.length;

    // Fetch rooms joined
    final allRooms = await FirebaseFirestore.instance.collection('StudyRoom').get();
    int joinedCount = 0;

    for (final room in allRooms.docs) {
      final participantDoc = await FirebaseFirestore.instance
          .collection('StudyRoom')
          .doc(room.id)
          .collection('Participants')
          .doc(uid)
          .get();

      if (participantDoc.exists) {
        joinedCount++;
      }
    }

    _roomsJoined = joinedCount;

    // Fetch and calculate average rating
    final ratingSnapshot = await FirebaseFirestore.instance
        .collection('StudyRoom')
        .where('creatorUid', isEqualTo: uid)
        .get();

    double totalRating = 0;
    int ratingCount = 0;

    for (final roomDoc in ratingSnapshot.docs) {
      final participantsSnapshot = await FirebaseFirestore.instance
          .collection('StudyRoom')
          .doc(roomDoc.id)
          .collection('Participants')
          .get();

      for (final participantDoc in participantsSnapshot.docs) {
        final rating = participantDoc.data()['rating'];
        if (rating != null && rating is num) {
          totalRating += rating.toDouble();
          ratingCount++;
        }
      }
    }

    _averageRating = ratingCount > 0 ? totalRating / ratingCount : null;


    setState(() {});
  }

  void _signOut() async {
    await _authen.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Center(
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                FirebaseAuth.instance.currentUser?.email ?? 'No email',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text("Sign Out"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _userName == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.person_rounded,
                      size: 100, color: Colors.blueAccent),
                  const SizedBox(height: 10),

                  // Dynamic Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final rating = _averageRating ?? 0;
                      if (rating >= index + 1) {
                        return const Icon(Icons.star, color: Colors.amber);
                      } else if (rating > index && rating < index + 1) {
                        return const Icon(Icons.star_half, color: Colors.amber);
                      } else {
                        return const Icon(Icons.star_border, color: Colors.grey);
                      }
                    }),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    _userName!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard("$_roomsCreated", "Rooms Created"),
                        _buildStatCard("$_roomsJoined", "Rooms Joined"),
                        _buildStatCard("100", "Hours Studying"), // You can also make this dynamic
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: const [
                        _buildSubjectTile("ES", "Engenharia de Software"),
                        _buildSubjectTile("DA", "Desenho de Algoritmos"),
                        _buildSubjectTile("LTW", "Laboratório de Tecnologias Web"),
                        _buildSubjectTile("LC", "Laboratório de Computadores"),
                        _buildSubjectTile("ME", "Métodos Estatísticos"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      bottomNavigationBar: BottomBar(parentContext: context),
    );
  }
}

Widget _buildStatCard(String number, String label) {
  return Column(
    children: [
      Text(
        number,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.grey)),
    ],
  );
}

class _buildSubjectTile extends StatelessWidget {
  final String acronym;
  final String name;

  const _buildSubjectTile(this.acronym, this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blueAccent,
        child: Text(acronym, style: const TextStyle(color: Colors.white)),
      ),
      title: Text(name),
      trailing:
          const Icon(Icons.check_box, color: Color.fromARGB(255, 63, 93, 213)),
    );
  }
}

