// lib/models/task_model.dart
import 'package:hive/hive.dart';
import 'priority.dart'; // Import our new enum

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  bool isCompleted;

  // --- NEW FIELD ---
  @HiveField(3)
  Priority priority;

  Task({
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.priority = Priority.medium, // Default to medium
  });
}