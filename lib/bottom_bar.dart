import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

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
            icon: Icon(Icons.show_chart, color: Colors.blueAccent),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum, color: Colors.blueAccent),
            label: 'Forum',
          ),
        ],
        onTap: (index) {
          // Logic for the bar navigation yet to be added
        },
      ),
    );
  }
}
