// lib/providers/habit_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit_model.dart';
import 'package:table_calendar/table_calendar.dart';

class HabitProvider extends ChangeNotifier {
  final Box<Habit> _habitBox = Hive.box<Habit>('habits');
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  // Load all habits from the database
  void loadHabits() {
    _habits = _habitBox.values.toList();
    // Also, update the isCompleted status for today when loading
    for (var habit in _habits) {
      habit.isCompleted = _isHabitCompletedToday(habit);
    }
    notifyListeners();
  }

  // Add a new habit
  void addHabit(String name, String description) {
    final newHabit = Habit(
      name: name,
      description: description,
      completedDates: [], // Start with an empty list
      isCompleted: false,
    );
    _habitBox.add(newHabit);
    loadHabits(); // Reload the list and notify UI
  }

  // Toggle a habit's completion status for today's date
  void toggleHabitCompletion(Habit habit) {
    final today = DateUtils.dateOnly(DateTime.now());

    if (habit.completedDates.contains(today)) {
      // If it was completed today, un-complete it
      habit.completedDates.remove(today);
      habit.isCompleted = false;
    } else {
      // If it was not completed today, complete it
      habit.completedDates.add(today);
      habit.isCompleted = true;
    }
    habit.save(); // Save the changes to the database
    notifyListeners(); // Notify the UI
  }

  // Helper function to check if a habit is completed today
  bool _isHabitCompletedToday(Habit habit) {
    final today = DateUtils.dateOnly(DateTime.now());
    return habit.completedDates.contains(today);
  }

  int calculateCurrentStreak(Habit habit) {
    if (!habit.completedDates.any((date) => isSameDay(date, DateTime.now()))) {
      // If not completed today, current streak is 0
      return 0;
    }

    int currentStreak = 0;
    DateTime dayToCheck = DateUtils.dateOnly(DateTime.now());

    // Sort dates to be safe
    habit.completedDates.sort((a, b) => b.compareTo(a));

    for (var date in habit.completedDates) {
      if (isSameDay(date, dayToCheck)) {
        currentStreak++;
        dayToCheck = dayToCheck.subtract(const Duration(days: 1));
      } else {
        // As soon as we find a gap, the streak is broken
        break;
      }
    }
    return currentStreak;
  }

  int calculateLongestStreak(Habit habit) {
    if (habit.completedDates.isEmpty) {
      return 0;
    }

    // Sort dates from oldest to newest
    habit.completedDates.sort((a, b) => a.compareTo(b));

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < habit.completedDates.length; i++) {
      // Check if the current date is exactly one day after the previous one
      if (habit.completedDates[i]
              .difference(habit.completedDates[i - 1])
              .inDays ==
          1) {
        currentStreak++;
      } else {
        // Gap found, reset the current streak
        currentStreak = 1;
      }

      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    }
    return longestStreak;
  }

  void toggleHabitCompletionForDate(Habit habit, DateTime date) {
    final dateOnly = DateUtils.dateOnly(date);

    if (habit.completedDates.contains(dateOnly)) {
      habit.completedDates.remove(dateOnly);
    } else {
      habit.completedDates.add(dateOnly);
    }

    // Also update the main 'isCompleted' flag if the toggled date is today
    if (isSameDay(dateOnly, DateTime.now())) {
      habit.isCompleted = _isHabitCompletedToday(habit);
    }

    habit.save();
    notifyListeners();
  }
}
