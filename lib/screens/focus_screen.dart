// lib/screens/focus_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  // Timer logic variables
  static const int _focusDuration = 25 * 60; // 25 minutes in seconds
  int _remainingTime = _focusDuration;
  Timer? _timer;
  bool _isTimerRunning = false;

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _isTimerRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer!.cancel();
          _isTimerRunning = false;
          // You could add a sound or notification here
        }
      });
    });
  }

  void _pauseTimer() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() {
        _isTimerRunning = false;
      });
    }
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _remainingTime = _focusDuration;
    });
  }

  // Helper to format time as MM:SS
  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when the screen is closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 120.0,
              lineWidth: 15.0,
              percent: _remainingTime / _focusDuration,
              center: Text(
                _formatTime(_remainingTime),
                style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
              progressColor: Colors.lightBlue,
              backgroundColor: Colors.blueGrey.withOpacity(0.3),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Start/Pause Button
                IconButton(
                  iconSize: 80,
                  icon: Icon(_isTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_filled),
                  onPressed: _isTimerRunning ? _pauseTimer : _startTimer,
                ),
                const SizedBox(width: 20),
                // Reset Button
                IconButton(
                  iconSize: 50,
                  icon: const Icon(Icons.replay_circle_filled_outlined),
                  onPressed: _resetTimer,
                  color: Colors.grey,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}