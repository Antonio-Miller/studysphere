import 'package:flutter/material.dart';
import 'package:flutter_application_1/authentic/authentic_service.dart';
import 'package:flutter_application_1/services/room_creation_page.dart';
import 'register_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //estes fields vao guaradar o estado dos inputs do utilizador
  //aqui is basically the same as the register but instead of create with email and pass its gon be singin
  final _athen= AuthenticService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    //aqui faremos o dispose para evitar memory leaks
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
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
              Icons.person,
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
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username: up202309344@up.pt',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password: ************',
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
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
//this is gon be my signin with google button
   const SizedBox(height: 5),
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () async{
                        await _athen.loginwithGoogle();
                      },//aqui vamos ter o nosso metodo do google sign in
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 196, 202, 212),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Sigin In with Google',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),


                 //aqui vamos fazer o sign in com google
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        }, //eset vai nos levar a register page
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.blueAccent,
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

  
    gotTorRoomCreationScreen(BuildContext context){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const RoomCreationScreen(),//faz com que va para a pagina de room creation
        ),
      );
    }
  //aqui faremos metodo login do utilizador
  _login() async{
    final user= await _athen.loginUserwithEmailAndPassword(_usernameController.text, _passwordController.text);
      if(user != null){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login successfull")));
        gotTorRoomCreationScreen(context);//this is gonna take us to the room creation page
      }else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login failed")));
      }
    }
  
}