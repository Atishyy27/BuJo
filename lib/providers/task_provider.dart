import 'package:bujo/models/priority.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final Box<Task> _taskBox = Hive.box<Task>('tasks');
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void loadTasks() {
    _tasks = _taskBox.values.toList();
    notifyListeners();
  }

  // MODIFIED: Added the priority parameter
  void addTask(String title, String description, Priority priority) {
    final newTask = Task(
      title: title,
      description: description,
      priority: priority, // Assign the new priority
    );
    _taskBox.add(newTask);
    loadTasks();
  }

  void toggleTaskStatus(Task task) {
    task.isCompleted = !task.isCompleted;
    task.save();
    loadTasks();
  }

  // MODIFIED: Added the newPriority parameter
  void updateTask(Task task, String newTitle, String newDescription, Priority newPriority) {
    task.title = newTitle;
    task.description = newDescription;
    task.priority = newPriority; // Update the priority
    task.save();
    loadTasks();
  }

  void deleteTask(Task task) {
    task.delete();
    loadTasks();
  }
}