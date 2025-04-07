import 'package:flutter/material.dart';
import 'package:flutter_application_1/authentic/authentic_service.dart';
import 'login_page.dart';
class SignoutPage extends StatefulWidget {
  const SignoutPage({super.key});

  @override
  State<SignoutPage> createState() => _SignOut();
}

class _SignOut extends State<SignoutPage> {
  // You can add any state variables you need here
  String _message = 'Welcome to the Home Page!';
  final _authen = AuthenticService();

  // Example function to change the message (not used in the current UI)
  void _updateMessage(String newMessage) {
    setState(() {
      _message = newMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authen.signOut(); // Call the sign-out method
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ); // Navigate to the login screen after signing out
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _signOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  _signOut() async {
    await _authen.signOut(); // Call the sign-out method
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    ); // vai a pagina de login depois do sign out
  }

}