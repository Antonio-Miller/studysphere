//okay so here we will have our profile page
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottom_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<String?> _fetchUserName() async {
    //it seems we gotta give it a little delay to update the data of current user
    await Future.delayed(const Duration(milliseconds: 500));
    final uid = FirebaseAuth.instance.currentUser?.uid;//aqui vai confirmar o userID do current user na nossa colecao do firebase
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('User').doc(uid).get();
    return doc['fullName'];//aqui ja vamos pescar no nosso userDoc o campo FullName
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: FutureBuilder<String?>(
      future: _fetchUserName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('User not found'));
        }

        final userName = snapshot.data!;
        return SingleChildScrollView(
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
                userName,
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
        );
      },
    ),
     bottomNavigationBar: BottomBar(parentContext: context),
  );
}
}


//aqui teremos as nossas funcoes para criar os cards de stats e as materias
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
        child: Text(acronym, style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
      ),
      title: Text(name),
      trailing: const Icon(Icons.check_box, color: Color.fromARGB(255, 63, 93, 213)),
    );
  }
}