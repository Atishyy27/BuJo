// lib/models/priority.dart
import 'package:hive/hive.dart';

part 'priority.g.dart';

@HiveType(typeId: 2) // New unique typeId
enum Priority {
  @HiveField(0)
  low,

  @HiveField(1)
  medium,

  @HiveField(2)
  high,
}