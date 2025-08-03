// lib/screens/main_screen.dart
import 'package:bujo/screens/habits_screen.dart';
import 'package:bujo/screens/task_screen.dart';
import 'package:bujo/models/task_model.dart';
import 'package:bujo/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // We use Consumer here so the title updates automatically when a task is completed
        title: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            final pendingTasks = taskProvider.tasks.where((t) => !t.isCompleted).length;
            return Text('BuJo - My Tasks ($pendingTasks)');
          },
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.tasks.isEmpty) {
            return const Center(
              child: Text('No tasks yet. Add one! ✨', style: TextStyle(fontSize: 18)),
            );
          }
          return ListView.builder(
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              final Task task = taskProvider.tasks[index];
              return ListTile(
                // --- NEW: Leading Checkbox for completion ---
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    // Call the provider method to toggle the status
                    taskProvider.toggleTaskStatus(task);
                  },
                ),
                // --- NEW: Text style changes when completed ---
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? Colors.grey : null,
                  ),
                ),
                subtitle: Text(
                  task.description,
                   style: TextStyle(
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                // --- NEW: Trailing delete button ---
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    // Call the provider method to delete the task
                    taskProvider.deleteTask(task);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // --- MODIFIED: Connect the onPressed to our new dialog method ---
        onPressed: () => _showAddTaskDialog(context, Provider.of<TaskProvider>(context, listen: false)),
        child: const Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }

  // --- NEW: Helper method to show the Add Task dialog ---
  void _showAddTaskDialog(BuildContext context, TaskProvider provider) {
    // Controllers to get text from TextFields
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Make the column size fit its content
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  provider.addTask(titleController.text, descriptionController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Tracks the currently selected tab

  // List of the screens to navigate between
  static const List<Widget> _pages = <Widget>[
    TasksScreen(),
    HabitsScreen(),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat),
            label: 'Habits',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}