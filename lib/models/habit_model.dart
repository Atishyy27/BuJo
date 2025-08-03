// lib/models/habit_model.dart
import 'package:hive/hive.dart';
part 'habit_model.g.dart';

@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<DateTime> completedDates;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isCompleted;

  Habit({
    required this.name,
    required this.description,
    required this.completedDates,
    this.isCompleted = false,
  });
}