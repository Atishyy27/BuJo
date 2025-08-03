// In lib/screens/main_screen.dart
import 'package:bujo/screens/courses_screen.dart'; // Import the new screen
import 'package:bujo/screens/focus_screen.dart';
import 'package:bujo/screens/habits_screen.dart';
import 'package:bujo/screens/tasks_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Add the new screen to the list
  static const List<Widget> _pages = <Widget>[
    TasksScreen(),
    HabitsScreen(),
    FocusScreen(),
    CoursesScreen(), // New screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Use this type for 4+ items
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined), // New icon
            label: 'Courses', // New label
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}