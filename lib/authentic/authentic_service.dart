import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'package:google_sign_in/google_sign_in.dart';
//esta biblioteca é para fazer log de erros
//neste ficheiro teremos a logic of the sign in and sign up


class AuthenticService {
  final _authentic = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();//this is my google instance so that we can log out of google too

  Future<UserCredential?> loginwithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn(); 
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );// aqui estamos a buscar id tokaen and access token do google para guardar na nossa variavel credential
      return await _authentic.signInWithCredential(credential);// e aqui vai mandar mandar oque queremos para o firebase
    } catch (e) {
      log(e.toString());
    }
    return null;
  }
  
  
  
  
  //o sign up/register
  Future<User?> createUserwithEmailAndPassword(
      String email, String password) async {
        try{       
          final credent= await _authentic.createUserWithEmailAndPassword(
          email: email, password: password);//if this is suceesfull it will create a user (we have to put await cus of the async function)
          return credent.user;//this will return the user that was created
        } on FirebaseAuthException catch (e) {
          exceptionHandler(e.code);//this will call the exception handler and pass the error code to it
        }
         
        catch(e) {
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
        }on FirebaseAuthException catch (e) {
          exceptionHandler(e.code);//this will call the exception handler and pass the error code to it
        } catch(e) {
          log("Something went wrong:");
        }
        return null;
      }

  //agora o nosso sign out method
  Future<void> signOut() async {
    try {
      await _authentic.signOut();//this will sign out the user    // Sign out from Firebase
      await _googleSignIn.signOut();//this will sign out the user from google too
    } catch (e) {
      log("Unable to Sign Out:");//this will log the error if it fails to sign out
    }
  }

  //Error Handling
  //here we can have some firebase errror handeling tipo
  //malta weak pass, invalid credential or email already in use
  exceptionHandler(String code){
    switch(code){//eset code e retornado pelo firebase
      case 'weak-password':
         log('The password provided is too weak.');
      case 'email-already-in-use':
        log('The account already exists for that email.');
      case 'invalid-credential':
        log('The credentials provided are invalid.');
      default:
        log('An undefined Error happened.');
    }
  }
}