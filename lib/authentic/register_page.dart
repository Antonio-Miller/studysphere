import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/authentic/authentic_service.dart';
import 'login_page.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //this basically mema coisa com o login
  //but here we wanna keep the name of the User too so that we can display it in the profile page
  final _authen = AuthenticService();
  final TextEditingController _nameController = TextEditingController();//already have our text editing
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A6CFF),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text(
            'StudySphere',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person_add,
              size: 50,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email: upXXXXXXXXX@up.pt',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      //here eu vou chamar um metodo chamado signUp que vai fazer o register
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A6CFF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: const Color(0xFF4A6CFF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  }
//okay depois de nos registarmos temos de ir para o login
//so we make a methood easy
  goTologin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
  //isto vai fazer o user ir para a pagina de login



  _signUp() async{
    //esta variavel user e que vao ter os dados do utilizador que se registou
     final user= await _authen.createUserwithEmailAndPassword(_emailController.text, _passwordController.text); 
    //agora temos de verificar se o user nao e null as we do in Lcom
    if(user!=null){
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${_nameController.text} registered successfully!"),
        backgroundColor: const Color.fromARGB(255, 76, 155, 175),
      ),
    );

    //okay so before we go to the login also gotta keep them user Data
    //now we call our adduser full name to database before we go to login
    _addUserDetails(_nameController.text,_emailController.text);//aqui estamos a passar o nome e email do user

      goTologin(context);//isto vai fazer o utilizador ir para a pagina de login
   
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Something went wrong!, please try again"),
        backgroundColor: const Color.fromARGB(255, 211, 98, 89),
      ),
    );//isto vai fazer log do erro que aconteceu
    }
  }

  //okay we have to develop our method to get user name and keep it for this we gotta use the doc


  _addUserDetails(String fullName, String email) async {
    final user= FirebaseAuth.instance.currentUser;//aqui estamos a manter a obter info do current
    if(user != null){
    //aqui estamos a fazer o add do user ao firestore
      await FirebaseFirestore.instance.collection('User').doc(user.uid).set({
        'full_name': fullName,
        'email': email,
      });
    }
  }

}