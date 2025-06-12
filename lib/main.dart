import 'package:flutter/material.dart';
import 'screens/timer_screen.dart';

void main() {
  runApp(const IntervalTimerApp());
}

class IntervalTimerApp extends StatelessWidget {
  const IntervalTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'インターバルタイマー',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TimerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}