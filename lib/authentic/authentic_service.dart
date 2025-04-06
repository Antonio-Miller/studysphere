import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';//esta biblioteca é para fazer log de erros
//neste ficheiro teremos a logic of the sign in and sign up


class AuthenticService {
  final _authentic = FirebaseAuth.instance;//esta instacia vai guardar o estado de autenticação do utilizador
  //o sign up/register
  Future<User?> createUserwithEmailAndPassword(
      String email, String password) async {
        try{       
          final credent= await _authentic.createUserWithEmailAndPassword(
          email: email, password: password);//if this is suceesfull it will create a user (we have to put await cus of the async function)
          return credent.user;//this will return the user that was created
        } catch(e) {
          log("Something went wrong:");
        }
        return null;
      }


  //o sign in/login
  Future<User?> loginUserwithEmailAndPassword(
      String email, String password) async {
        try{       
          final credent= await _authentic.signInWithEmailAndPassword(
          email: email, password: password);//if this is suceesfull it will sign in a user already created (we have to put await cus of the async function)
          return credent.user;//this will return the user that was successfully signed in
        } catch(e) {
          log("Something went wrong:");
        }
        return null;
      }

  //agora o nosso sign out method
  Future<void> signOut() async {
    try {
      await _authentic.signOut();//this will sign out the user
    } catch (e) {
      log("Unable to Sign Out:");//this will log the error if it fails to sign out
    }
  }

}