import 'package:flutter/material.dart';

void main() {
  runApp(const StudySphereApp());
}

class StudySphereApp extends StatelessWidget {
  const StudySphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudySphere',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const RoomCreationScreen(),
    );
  }
}

class Room {
  final String subject;
  final String name;
  final String date;
  final String creator;
  final String maxStudents;
  final String duration;

  Room({
    required this.subject,
    required this.name,
    required this.date,
    required this.creator,
    required this.maxStudents,
    required this.duration,
  });
}

class RoomCreationScreen extends StatefulWidget {
  const RoomCreationScreen({super.key});

  @override
  _RoomCreationScreenState createState() => _RoomCreationScreenState();
}

class _RoomCreationScreenState extends State<RoomCreationScreen> {
  String? selectedSubject;
  final TextEditingController roomController = TextEditingController();
  final TextEditingController maxStudentsController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Room Creation"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Subject"),
              value: selectedSubject,
              items: const [
                "Base de Dados",
                "Desenho de Algoritmos",
                "ESOF",
                "Algebra",
                "Analise Matematica",
                "Programacao"
              ].map((subject) => DropdownMenuItem(
                value: subject,
                child: Text(subject),
              )).toList(),
              onChanged: (value) => setState(() => selectedSubject = value),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: roomController,
              decoration: const InputDecoration(labelText: "Room Name"),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: maxStudentsController,
              decoration: const InputDecoration(labelText: "Max Students"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: dateController,
              decoration: const InputDecoration(labelText: "Select Date"),
              readOnly: true,
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      dateController.text =
                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year} ${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: durationController,
              decoration: const InputDecoration(labelText: "Duration (hh:mm)"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedSubject == null || roomController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please fill all required fields")),
                    );
                    return;
                  }

                  final newRoom = Room(
                    subject: selectedSubject!,
                    name: roomController.text,
                    date: dateController.text,
                    creator: "You", // Substituir por sistema de login
                    maxStudents: maxStudentsController.text,
                    duration: durationController.text,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomsListScreen(newRoom: newRoom),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("CREATE", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoomsListScreen extends StatefulWidget {
  final Room? newRoom;

  const RoomsListScreen({super.key, this.newRoom});

  @override
  _RoomsListScreenState createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {
  final List<Room> _rooms = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    if (widget.newRoom != null) {
      _rooms.add(widget.newRoom!);
    }
    // Adicionar dados de exemplo
    _rooms.addAll([
      Room(
        subject: "ESOF",
        name: "Study Group 1",
        date: "19/03 14h-17h",
        creator: "António Miller",
        maxStudents: "10",
        duration: "3h",
      ),
      Room(
        subject: "LTW",
        name: "Web Dev Session",
        date: "20/03 16:30h-19:30h",
        creator: "Pedro Salgado",
        maxStudents: "8",
        duration: "3h",
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Rooms'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Rooms')),
              const PopupMenuItem(value: 'Available', child: Text('Available')),
              const PopupMenuItem(value: 'Joined', child: Text('Joined')),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          final room = _rooms[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(room.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject: ${room.subject}'),
                  Text('Date: ${room.date}'),
                  Text('Creator: ${room.creator}'),
                  Text('Duration: ${room.duration}'),
                  Text('Max Students: ${room.maxStudents}'),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joined ${room.name}')),
    );
  }
}