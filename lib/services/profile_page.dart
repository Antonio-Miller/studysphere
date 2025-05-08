//okay so here we will have our profile page
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          return Column(
            children: [
              const SizedBox(height: 100),
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 10),
              Text(
                userName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Add stats and courses here
              const Text("You can build out stats and subject list here."),
            ],
          );
        },
      ),
    );
  }
}