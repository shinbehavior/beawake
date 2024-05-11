import 'package:flutter/material.dart';
import 'package:beawake/screens/home_screen.dart'; // Assuming your event list and buttons are in this file

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wake/Sleep Tracker',
      home: HomeScreen(),
    );
  }
}
