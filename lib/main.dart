import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: RoomCreationScreen(),
  ));
}

class RoomCreationScreen extends StatefulWidget {
  @override
  _RoomCreationScreenState createState() => _RoomCreationScreenState();
}

class _RoomCreationScreenState extends State<RoomCreationScreen> {
  String? selectedSubject;
  TextEditingController roommaxstudentsController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Room Creation"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown menu das cadeiras(subject to change tho)
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Subject"),
              value: selectedSubject,
              items: ["Base de Dados", "Desenho de Algoritmos", "ESOF", "Fisica", "Analise Matematica", "Programacao"]
                  .map((subject) => DropdownMenuItem(
                        value: subject,
                        child: Text(subject),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedSubject = value;
                });
              },
            ),
            SizedBox(height: 10),

            // O Nome da sala ;)
            TextFormField(
              controller: roomController,
              decoration: InputDecoration(labelText: "Room"),
            ),
            SizedBox(height: 10),

            // O nr maximo de estudantes na sala
            TextFormField(
              controller: roommaxstudentsController,
              decoration: InputDecoration(labelText: "Max Students"),
            ),
            SizedBox(height: 10),

            // A data que vai ser cirada/aberta a sala
            TextFormField(
              controller: dateController,
              decoration: InputDecoration(labelText: "Select Date"),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      dateController.text =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year} ${pickedTime.hour}:${pickedTime.minute}";
                    });
                  }
                }
              },
            ),
            SizedBox(height: 10),

            // Quanto tempo vai ficar up a sala
            TextFormField(
              controller: durationController,
              decoration: InputDecoration(labelText: "Duration (hh:mm)"),
            ),
            SizedBox(height: 20),
            
            // O botao de criar a sala
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  print("Room Created: ${roomController.text}");
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("CREATE", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}