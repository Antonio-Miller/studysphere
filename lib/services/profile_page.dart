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
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('User').doc(uid).get();
    setState(() {
      final data = doc.data();
      _userName = data?['full_name'] ?? data?['fullName'] ?? 'Error loading name';
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

            // Escolha de Ano e Cadeiras
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 10),
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
                        activeColor: Colors.blueAccent,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedSubjects.add(subject["acronym"]!);
                            } else {
                              _selectedSubjects.remove(subject["acronym"]!);
                            }
                          });
                        },
                      );
                    },
                  ),
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