import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class  MyHomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>_MyHomePage();

}
class _MyHomePage extends State<MyHomePage>{
  Map<String, List<Map<String, dynamic>>> tasksByDate = {};
  TextEditingController taskController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // Load tasks from SharedPreferences
  Future<void> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTasks = prefs.getString('tasksByDate');
    if (savedTasks != null) {
      setState(() {
        tasksByDate = Map<String, List<Map<String, dynamic>>>.from(
          json.decode(savedTasks).map(
                (key, value) => MapEntry(
              key,
              List<Map<String, dynamic>>.from(value),
            ),
          ),
        );
      });
    }
  }

  // Save tasks to SharedPreferences
  Future<void> saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tasksByDate', json.encode(tasksByDate));
  }

  // Add a new task
  void addTask() {
    if (taskController.text.trim().isNotEmpty) {
      String dateKey = selectedDate.toIso8601String().split('T')[0];
      setState(() {
        if (!tasksByDate.containsKey(dateKey)) {
          tasksByDate[dateKey] = [];
        }
        tasksByDate[dateKey]!.add({
          'task': taskController.text.trim(),
          'completed': false,
        });
      });
      saveTasks();
      taskController.clear();
    }
  }

  // Toggle task completion
  void toggleTaskCompletion(String dateKey, int index) {
    setState(() {
      tasksByDate[dateKey]![index]['completed'] =
      !tasksByDate[dateKey]![index]['completed'];
    });
    saveTasks();
  }

  // Remove a task
  void removeTask(String dateKey, int index) {
    setState(() {
      tasksByDate[dateKey]!.removeAt(index);
      if (tasksByDate[dateKey]!.isEmpty) {
        tasksByDate.remove(dateKey);
      }
    });
    saveTasks();
  }

  // Select a date
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedDateKey = selectedDate.toIso8601String().split('T')[0];
    List<Map<String, dynamic>> tasksForSelectedDate =
        tasksByDate[selectedDateKey] ?? [];
    String formattedDate =
        "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${formattedDate} To-Do List",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: pickDate,
            child: Icon(Icons.calendar_month,color: Colors.white,)
            // const Text(
            //   'Change Date',
            //   style: TextStyle(color: Colors.white),
            // ),
          ),
        ],
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: taskController,
                      decoration: InputDecoration(
                        labelText: 'Enter a task',
                        labelStyle: const TextStyle(color: Colors.blueAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.purple, width: 2.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onPressed: addTask,
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: tasksForSelectedDate.isEmpty
                  ? Center(
                child: Text(
                  'No tasks for this date!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: tasksForSelectedDate.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: tasksForSelectedDate[index]['completed'],
                        onChanged: (bool? value) {
                          toggleTaskCompletion(selectedDateKey, index);
                        },
                        activeColor: Colors.green,
                        checkColor: Colors.white,
                      ),
                      title: Text(
                        tasksForSelectedDate[index]['task'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: tasksForSelectedDate[index]['completed']
                              ? Colors.grey
                              : Colors.black,
                          decoration: tasksForSelectedDate[index]['completed']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => removeTask(selectedDateKey, index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    //   Scaffold(
    //   appBar: AppBar(
    //     title: Text("${formattedDate} To-Do List"),
    //     actions: [ElevatedButton(
    //       onPressed: pickDate,
    //       child: const Text('change Date'),
    //     ),],
    //     centerTitle: true,
    //   ),
    //   body: Column(
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.all(16.0),
    //         child: Row(
    //           children: [
    //             Expanded(
    //               child: TextField(
    //                 controller: taskController,
    //                 decoration: const InputDecoration(
    //                   labelText: 'Enter a task',
    //                   border: OutlineInputBorder(),
    //                 ),
    //               ),
    //             ),
    //             const SizedBox(width: 10),
    //             ElevatedButton(
    //               onPressed: addTask,
    //               child: const Text('Add'),
    //             ),
    //           ],
    //         ),
    //       ),
    //       Expanded(
    //         child: tasksForSelectedDate.isEmpty
    //             ? const Center(
    //           child: Text(
    //             'No tasks for this date!',
    //             style: TextStyle(fontSize: 16),
    //           ),
    //         )
    //             : ListView.builder(
    //           itemCount: tasksForSelectedDate.length,
    //           itemBuilder: (context, index) {
    //             return Card(
    //               margin: const EdgeInsets.symmetric(
    //                 vertical: 4.0,
    //                 horizontal: 16.0,
    //               ),
    //               child: ListTile(
    //                 leading: Checkbox(
    //                   value: tasksForSelectedDate[index]['completed'],
    //                   onChanged: (bool? value) {
    //                     toggleTaskCompletion(selectedDateKey, index);
    //                   },
    //                 ),
    //                 title: Text(
    //                   tasksForSelectedDate[index]['task'],
    //                   style: TextStyle(
    //                     decoration: tasksForSelectedDate[index]
    //                     ['completed']
    //                         ? TextDecoration.lineThrough
    //                         : TextDecoration.none,
    //                   ),
    //                 ),
    //                 trailing: IconButton(
    //                   icon: const Icon(Icons.delete),
    //                   onPressed: () => removeTask(selectedDateKey, index),
    //                 ),
    //               ),
    //             );
    //           },
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}