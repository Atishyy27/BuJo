// lib/screens/focus_screen.dart
import 'package:flutter/material.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
      ),
      body: const Center(
        child: Text('Pomodoro Timer UI will be built here.'),
      ),
    );
  }
}