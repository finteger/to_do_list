import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weather/weather.dart';

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

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  FocusNode _textFieldFocusNode = FocusNode();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  void addItemToList() async {
    final String taskName = nameController.text;

    //Add to the Firestore collection
    await db.collection('tasks').add({
      'name': taskName,
      'completed': isChecked,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      tasks.insert(0, taskName);
      checkboxes.insert(0, false);
    });

    clearTextField();
  }

  //Asynchronous function to update the completion status of a task in Firestore
  Future<void> updateTaskCompletionStatus(
      String taskName, bool completed) async {
    //Get a reference to the 'tasks' collection in Firestore.
    CollectionReference tasksCollection = db.collection('tasks');

    //Query Firestore for documents (tasks) with the given task name

    QuerySnapshot querySnapshot =
        await tasksCollection.where('name', isEqualTo: taskName).get();

    //If a matching task document is found
    if (querySnapshot.size > 0) {
      //Get a reference to the first matching document
      DocumentSnapshot documentSnapshot = querySnapshot.docs[0];

      //Update the 'completed' field of the document with the new completion status
      await documentSnapshot.reference.update({'completed': completed});
    }
  }

  Future<void> fetchTasksFromFirestore() async {
    CollectionReference tasksCollection = db.collection('tasks');

    QuerySnapshot querySnapshot = await tasksCollection.get();

    List<String> fetchedTasks = [];

    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      String taskName = docSnapshot.get('name');
      bool completed = docSnapshot.get('completed');

      fetchedTasks.add(taskName);
    }

    setState(() {
      tasks.clear();
      tasks.addAll(fetchedTasks);
    });
  }

  @override
  void initState() {
    super.initState();

    fetchTasksFromFirestore();
  }

  void removeItem(int index) async {
    //Get the task that needs to be removed
    String taskNameToRemove = tasks[index];

    //Remove the task from the Firestore collection
    QuerySnapshot querySnapshot = await db
        .collection('tasks')
        .where('name', isEqualTo: taskNameToRemove)
        .get();

    if (querySnapshot.size > 0) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs[0];

      await documentSnapshot.reference.delete();
    }

    //Remove the task from the task list and checkboxes
    setState(() {
      tasks.removeAt(index);
      checkboxes.removeAt(index);
    });
  }

  void clearTextField() {
    setState(() {
      nameController.clear();
    });
  }

  Future<List<Weather>> getData() async {
    String? cityName = 'Red Deer, CA';
    WeatherFactory wf = WeatherFactory("ce8eb3004b0dcfd8664bd52d8f1eae78");
    List<Weather> forecast = await wf.fiveDayForecastByCityName(cityName);
    return forecast;
  }

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
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
              child: FutureBuilder<List<Weather>>(
                future: getData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    List<Weather> forecast = snapshot.data!;

                    // Extracting weather, temperature, and wind information
                    Weather firstWeather = forecast[0];
                    String city = "Red Deer, CA";
                    String? weatherCondition = firstWeather.weatherMain;
                    double? temperature = firstWeather.temperature?.celsius;
                    double? windSpeed = firstWeather.windSpeed;

                    return Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align text to the left
                      children: [
                        Text('$city',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Weather Condition: $weatherCondition'),
                        Text('Temperature: $temperature °C'),
                        Text('Wind Speed: $windSpeed m/s'),
                      ],
                    );
                  } else {
                    return Text('No data available');
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            !checkboxes[index]
                                ? Icons.manage_history
                                : Icons.playlist_add_check_circle,
                            size: 32,
                          ),
                          SizedBox(width: 18),
                          Expanded(
                            child: Text(
                              '${tasks[index]}',
                              style: checkboxes[index]
                                  ? TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 20,
                                      color: Colors.black.withOpacity(0.5),
                                    )
                                  : TextStyle(fontSize: 20),
                            ),
                          ),
                          SizedBox(width: 58),
                          Checkbox(
                              value: checkboxes[index],
                              onChanged: (newValue) {
                                setState(() {
                                  checkboxes[index] = newValue!;
                                });
                                updateTaskCompletionStatus(
                                  tasks[index],
                                  newValue!,
                                );
                              }),
                          IconButton(
                            onPressed: () {
                              removeItem(index);
                            },
                            icon: Icon(Icons.delete),
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: TextField(
                      controller: nameController,
                      focusNode: _textFieldFocusNode,
                      maxLength: 23,
                      maxLines: 1,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Enter your task here',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
              child: Text('Add To-Do Item'),
              onPressed: () {
                _textFieldFocusNode.unfocus();
                addItemToList();
              }),
        ],
      ),
    );
  }
}
