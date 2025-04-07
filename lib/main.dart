import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'wrapper.dart';
//so before we run the app we have to also initialize our firebase database
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
 
  runApp(const StudySphereApp());
}

class StudySphereApp extends StatelessWidget {
  const StudySphereApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Wrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}