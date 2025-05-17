//este file tem como objectivo guaradr os data of our user
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/authentic/login_page.dart';
import 'package:flutter_application_1/services/home_page.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>( // Specify the type of the stream data
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error')); // algo correu mal quando fomos buscar o data of user
          } else {
            if (snapshot.data == null) { // aqui o user is loggedoff so he goes to loginScreen
              return const LoginScreen();
            } else {
              return const HomePage(); // aqui o user is logged in(we have its data) so he goes to the room creation page
            }
          }
        },
      ),
    );
  }
}