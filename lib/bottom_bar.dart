import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/profile_page.dart';
import 'package:flutter_application_1/services/home_page.dart';
import 'package:flutter_application_1/forum/forum_page.dart';


//we need to change it so that we can navigate the app with it
class BottomBar extends StatelessWidget {
  //we need to make this a builder
  final BuildContext parentContext;
  const BottomBar({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        iconSize: 35,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.blueAccent),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.blueAccent),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mark_unread_chat_alt, color: Colors.blueAccent),
            label: 'Rooms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum, color: Colors.blueAccent),
            label: 'Forum',
          ),
        ],
        onTap: (index) {
          //agora aqui uma logica simples com os indices da nossa navigation bar
          //0 = profile, 1 = home, 2 = stats, 3 = forum
          switch (index) {
            case 0:
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                  builder: (context) =>const ProfilePage(),
                ),
              );
              break;
            case 1:
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
              break;
            case 2:
              // Navigate to Stats page
              break;
            case 3:
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => const ForumPage(),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}
