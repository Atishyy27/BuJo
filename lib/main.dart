// lib/main.dart
import 'package:bujo/models/habit_model.dart';
import 'package:bujo/models/task_model.dart';
import 'package:bujo/models/priority.dart';
import 'package:bujo/providers/habit_provider.dart';
import 'package:bujo/providers/task_provider.dart';
import 'package:bujo/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(PriorityAdapter());

  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Habit>('habits');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MultiProvider to provide multiple objects
    return MultiProvider(
      providers: [
        // Provider for Tasks
        ChangeNotifierProvider(
          create: (context) => TaskProvider()..loadTasks(),
        ),
        // NEW: Provider for Habits
        ChangeNotifierProvider(
          create: (context) => HabitProvider()..loadHabits(),
        ),
      ],
      child: MaterialApp(
        title: 'BuJo',
        theme: ThemeData.dark(useMaterial3: true),
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
      ),
    );
  }
}