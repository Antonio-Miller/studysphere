import 'package:flutter/material.dart';

class Room {
  final String subject;
  final String name;
  final String date;
  final String creator;

  Room({
    required this.subject,
    required this.name,
    required this.date,
    required this.creator,
  });
}

class RoomsListScreen extends StatelessWidget {
  final List<Room> rooms;

  const RoomsListScreen({super.key, required this.rooms});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Rooms'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(room.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject: ${room.subject}'),
                  Text('Date: ${room.date}'),
                  Text('Created by: ${room.creator}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _joinRoom(context, room),
                child: const Text('Join'),
              ),
            ),
          );
        },
      ),
    );
  }

  void _joinRoom(BuildContext context, Room room) {
    // Lógica para entrar na sala
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joined ${room.name}')),
    );
  }
}