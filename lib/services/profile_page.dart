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

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('User').doc(uid).get();
    setState(() {
      _userName = doc['fullName'];
    });
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  const Icon(Icons.person_rounded, size: 100, color: Colors.blueAccent),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star_border, color: Colors.grey),
                    ],
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
                        _buildStatCard("15", "Rooms Created"),
                        _buildStatCard("26", "Rooms Joined"),
                        _buildStatCard("100", "Hours Studying"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Subject list
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

// Stat Card
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

// Subject Tile
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
      trailing: const Icon(Icons.check_box, color: Color.fromARGB(255, 63, 93, 213)),
    );
  }
}