// lib/providers/task_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  // A reference to our opened Hive box
  final Box<Task> _taskBox = Hive.box<Task>('tasks');

  // Private list to hold tasks in memory for quick access
  List<Task> _tasks = [];

  // Public getter to allow other parts of the app to read the tasks
  List<Task> get tasks => _tasks;

  // --- CRUD Operations ---

  // READ: Load all tasks from the Hive box into our private list
  void loadTasks() {
    // Hive boxes can be treated like a Map, .values gives us all items.
    _tasks = _taskBox.values.toList();
    notifyListeners(); // Tell the UI to update
  }

  // CREATE: Add a new task to the database
  void addTask(String title, String description) {
    final newTask = Task(
      title: title,
      description: description, // We're including your new field!
      isCompleted: false,
    );
    _taskBox.add(newTask); // Add to Hive
    loadTasks(); // Reload the list from the box to include the new task
  }

  // UPDATE: Toggle a task's completion status
  void toggleTaskStatus(Task task) {
    task.isCompleted = !task.isCompleted;
    task.save(); // HiveObject has a built-in save method!
    loadTasks(); // Reload and notify UI
  }

  // DELETE: Remove a task from the database
  void deleteTask(Task task) {
    task.delete(); // HiveObject also has a built-in delete method!
    loadTasks(); // Reload and notify UI
  }
}