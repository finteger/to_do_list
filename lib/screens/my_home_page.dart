import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  final List<String> tasks = <String>[];

  final List<bool> checkboxes = List.generate(8, (index) => false);

  bool isChecked = false;

  TextEditingController nameController = TextEditingController();

  void addItemToList() async {
    final String taskName = nameController.text;

    await db.collection('tasks').add({
      'name': taskName,
      'completed': isChecked,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      tasks.insert(0, taskName);
      checkboxes.insert(0, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 70,
              child: Image.asset('assets/rdplogo.png'),
            ),
            Text(
              'Daily Planner',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 32,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                height: 300,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TableCalendar(
                    calendarFormat: CalendarFormat.month,
                    headerVisible: false,
                    focusedDay: DateTime.now(),
                    firstDay: DateTime(2023),
                    lastDay: DateTime(2025),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment(0.00, 0.9999),
                    end: Alignment(0.00, 0.22),
                    colors: <Color>[
                      Colors.white.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstOut,
                child: ListView.builder(
                  padding: const EdgeInsets.all(1),
                  itemCount: tasks.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: checkboxes[index]
                            ? Colors.green.withOpacity(0.7)
                            : Colors.blue.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: EdgeInsets.all(2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Row(
                                children: [
                                  Icon(
                                    !checkboxes[index]
                                        ? Icons.manage_history
                                        : Icons.playlist_add_check_circle,
                                    color: !checkboxes[index]
                                        ? Colors.white
                                        : Colors.white,
                                    size: 32,
                                  ),
                                  SizedBox(width: 18),
                                  Text(
                                    '${tasks[index]}',
                                    style: checkboxes[index]
                                        ? TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontSize: 20,
                                            color:
                                                Colors.black.withOpacity(0.5),
                                          )
                                        : TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 350,
                    child: TextField(
                      maxLength: 20,
                      controller: nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        labelText: 'Add To-Do List Item',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: addItemToList,
                  child: Text(
                    'Add Task',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
