// lib/screens/habits_screen.dart
import 'package:bujo/models/habit_model.dart';
import 'package:bujo/providers/habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Habit? _selectedHabit;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    if (habitProvider.habits.isNotEmpty) {
      _selectedHabit = habitProvider.habits.first;
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    if (_selectedHabit == null) return [];
    final isCompleted = _selectedHabit!.completedDates.any(
      (completedDate) => isSameDay(completedDate, day),
    );
    return isCompleted ? ['Completed'] : [];
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);

    if (_selectedHabit == null && habitProvider.habits.isNotEmpty) {
      _selectedHabit = habitProvider.habits.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedHabit == null ? 'My Habits' : _selectedHabit!.name),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            eventLoader: _getEventsForDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            
            // --- MODIFIED: The onDaySelected callback ---
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              // If a habit is selected, toggle its completion for the tapped day
              if (_selectedHabit != null) {
                habitProvider.toggleHabitCompletionForDate(_selectedHabit!, selectedDay);
              }
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blueGrey, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.lightBlue, shape: BoxShape.circle),
              markerDecoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
            ),
          ),
          if (_selectedHabit != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Current Streak', habitProvider.calculateCurrentStreak(_selectedHabit!)),
                  _buildStatCard('Longest Streak', habitProvider.calculateLongestStreak(_selectedHabit!)),
                ],
              ),
            ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: habitProvider.habits.length,
              itemBuilder: (context, index) {
                final Habit habit = habitProvider.habits[index];
                final isSelected = _selectedHabit == habit;

                return ListTile(
                  tileColor: isSelected ? Colors.blueGrey.withOpacity(0.3) : null,
                  title: Text(habit.name),
                  subtitle: Text(habit.description),
                  leading: Checkbox(
                    value: habit.isCompleted,
                    onChanged: (value) {
                      habitProvider.toggleHabitCompletion(habit);
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _selectedHabit = habit;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context, habitProvider),
        child: const Icon(Icons.add),
        tooltip: 'Add Habit',
      ),
    );
  }

  Widget _buildStatCard(String title, int count) {
    return Column(
      children: [
        Text(count.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(title),
      ],
    );
  }

  void _showAddHabitDialog(BuildContext context, HabitProvider provider) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a New Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, autofocus: true, decoration: const InputDecoration(labelText: 'Habit Name')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  provider.addHabit(nameController.text, descriptionController.text);
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