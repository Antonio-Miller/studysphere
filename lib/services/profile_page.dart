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
  double _studyTimeHours = 0;

  int _selectedYear = 1;
  final Map<int, List<Map<String, String>>> _subjectsByYear = {
    1: [
      {"acronym": "AM I", "name": "Análise Matemática I"},
      {"acronym": "FP", "name": "Fundamentos de Programação"},
      {"acronym": "FSC", "name": "Fundamentos de Sistemas de Computação"},
      {"acronym": "ALGA", "name": "Álgebra Linear e Geometria Analítica"},
      {"acronym": "MD", "name": "Matemática Discreta"},
      {"acronym": "AM II", "name": "Análise Matemática II"},
      {"acronym": "AC", "name": "Arquitetura de Computadores"},
      {"acronym": "F I", "name": "Física I"},
      {"acronym": "TC", "name": "Teoria da Computação"},
      {"acronym": "AED", "name": "Algoritmos e Estruturas de Dados"},
    ],
    2: [
      {"acronym": "BD", "name": "Bases de Dados"},
      {"acronym": "F II", "name": "Física II"},
      {"acronym": "SO", "name": "Sistemas Operativos"},
      {"acronym": "LDTS", "name": "Laboratório de Desenvolvimento de Tecnologias de Software"},
      {"acronym": "LC", "name": "Laboratório de Computadores"},
      {"acronym": "DA", "name": "Desenho de Algoritmos"},
      {"acronym": "ES", "name": "Engenharia de Software"},
      {"acronym": "ME", "name": "Métodos Estatísticos"},
      {"acronym": "LTW", "name": "Laboratório de Tecnologias Web"},
    ],
  };
  final Set<String> _selectedSubjects = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('User').doc(uid).get();
    final data = userDoc.data();
    _userName = data?['full_name'] ?? data?['fullName'] ?? 'No name';

    final selected = data?['selectedSubjects'];
    if (selected is List) {
      _selectedSubjects.clear();
      _selectedSubjects.addAll(selected.cast<String>());
    }

    final roomsCreatedSnapshot = await FirebaseFirestore.instance
        .collection('StudyRoom')
        .where('creatorUid', isEqualTo: uid)
        .get();
    _roomsCreated = roomsCreatedSnapshot.docs.length;

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

    final statsDoc = await FirebaseFirestore.instance.collection('StudentStatistics').doc(uid).get();
    if (statsDoc.exists) {
      final statsData = statsDoc.data();
      _studyTimeHours = (statsData?['studyTimeHours'] ?? 0).toDouble();
    }

    double totalRating = 0;
    int ratingCount = 0;
    for (final roomDoc in roomsCreatedSnapshot.docs) {
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

  Future<void> _saveSelectedSubjects() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('User').doc(uid).set(
      {
        'selectedSubjects': _selectedSubjects.toList(),
      },
      SetOptions(merge: true),
    );
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6CFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: const Color(0xFF4A6CFF)),
              child: const Center(
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                FirebaseAuth.instance.currentUser?.email ?? 'No email',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text("Sign Out"),
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
                  const SizedBox(height: 40),
                  const Icon(Icons.person_rounded, size: 100),
                  const SizedBox(height: 10),
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
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),

                  // Statistics
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(child: _buildStatCard("$_roomsCreated", "Rooms\nCreated")),
                            Expanded(child: _buildStatCard("$_roomsJoined", "Rooms\nJoined")),
                            Expanded(child: _buildStatCard(_studyTimeHours.toStringAsFixed(1), "Hours\nStudying")),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Subject selection
                  const Text(
                    "Escolha de Cadeiras",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<int>(
                          title: const Text("1º Ano"),
                          value: 1,
                          groupValue: _selectedYear,
                          onChanged: (value) {
                            setState(() {
                              _selectedYear = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<int>(
                          title: const Text("2º Ano"),
                          value: 2,
                          groupValue: _selectedYear,
                          onChanged: (value) {
                            setState(() {
                              _selectedYear = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _subjectsByYear[_selectedYear]!.length,
                    itemBuilder: (context, index) {
                      final subject = _subjectsByYear[_selectedYear]![index];
                      final isSelected = _selectedSubjects.contains(subject["acronym"]);
                      return CheckboxListTile(
                        title: Text("${subject["acronym"]} - ${subject["name"]}"),
                        value: isSelected,
                        activeColor: colorScheme.primary,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedSubjects.add(subject["acronym"]!);
                            } else {
                              _selectedSubjects.remove(subject["acronym"]!);
                            }
                          });
                          _saveSelectedSubjects();
                        },
                      );
                    },
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
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 6),
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          number,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A6CFF)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
