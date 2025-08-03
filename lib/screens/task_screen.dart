import 'package:bujo/models/priority.dart';
import 'package:bujo/models/task_model.dart';
import 'package:bujo/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('BuJo - My Tasks (${taskProvider.tasks.where((t) => !t.isCompleted).length})'),
      ),
      body: ListView.builder(
        itemCount: taskProvider.tasks.length,
        itemBuilder: (context, index) {
          final Task task = taskProvider.tasks[index];
          return ListTile(
            // NEW: Display an icon based on the task's priority
            leading: _getPriorityIcon(task.priority),
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(value: task.isCompleted, onChanged: (value) => taskProvider.toggleTaskStatus(task)),
                IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showTaskDialog(context, taskProvider, taskToEdit: task)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context, taskProvider),
        child: const Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }

  // NEW: Helper widget to return an icon based on priority
  Widget _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.high:
        return const Icon(Icons.keyboard_double_arrow_up_rounded, color: Colors.redAccent);
      case Priority.medium:
        return const Icon(Icons.drag_handle_rounded, color: Colors.yellowAccent);
      case Priority.low:
        return const Icon(Icons.keyboard_double_arrow_down_rounded, color: Colors.greenAccent);
      default:
        return const Icon(Icons.drag_handle_rounded, color: Colors.grey);
    }
  }

  void _showTaskDialog(BuildContext context, TaskProvider provider, {Task? taskToEdit}) {
    final bool isEditing = taskToEdit != null;
    final titleController = TextEditingController(text: isEditing ? taskToEdit.title : '');
    final descriptionController = TextEditingController(text: isEditing ? taskToEdit.description : '');
    // Hold the state of the dropdown
    Priority selectedPriority = isEditing ? taskToEdit.priority : Priority.medium;

    showDialog(
      context: context,
      builder: (context) {
        // Use a StatefulBuilder to allow the dialog's content to have its own state
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Task' : 'Add a New Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, autofocus: true, decoration: const InputDecoration(labelText: 'Title')),
                  TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
                  const SizedBox(height: 20),
                  // NEW: Dropdown menu to select a priority
                  DropdownButton<Priority>(
                    value: selectedPriority,
                    isExpanded: true,
                    onChanged: (Priority? newValue) {
                      // Use the dialog's own setState to update the dropdown
                      setState(() {
                        selectedPriority = newValue!;
                      });
                    },
                    items: Priority.values.map((Priority priority) {
                      return DropdownMenuItem<Priority>(
                        value: priority,
                        child: Text(priority.name.toUpperCase()),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      if (isEditing) {
                        provider.updateTask(taskToEdit, titleController.text, descriptionController.text, selectedPriority);
                      } else {
                        provider.addTask(titleController.text, descriptionController.text, selectedPriority);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}