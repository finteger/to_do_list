import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> tasks = <String>[];

  final List<bool> checkboxes = List.generate(8, (index) => false);

  bool isChecked = false;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  FocusNode _textFieldFocusNode = FocusNode();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 80,
              child: Image.asset('assets/rdplogo.png'),
            ),
            const Text(
              'Daily Planner',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 32,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(13.0),
            child: TableCalendar(
              calendarFormat: _calendarFormat,
              headerVisible: false,
              focusedDay: _focusedDay,
              firstDay: DateTime(2022),
              lastDay: DateTime(2024),
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
                itemCount: 0,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: checkboxes[index]
                          ? Colors.green.withOpacity(0.7)
                          : Colors.blue.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          !checkboxes[index]
                              ? Icons.manage_history
                              : Icons.playlist_add_check_circle,
                          size: 32,
                        ),
                        SizedBox(width: 18),
                        Text(
                          '${tasks[index]}',
                          style: checkboxes[index]
                              ? TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 20,
                                  color: Colors.black.withOpacity(0.5),
                                )
                              : TextStyle(fontSize: 20),
                        ),
                        Checkbox(
                            value: checkboxes[index],
                            onChanged: (newValue) {
                              setState(() {
                                checkboxes[index] = newValue!;
                              });
                            }),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
