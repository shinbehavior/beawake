import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> saveWakeTime() async {
    final prefs = await SharedPreferences.getInstance();
    String formattedTime = DateFormat('HH:mm').format(DateTime.now());
    await prefs.setString('wakeTime', formattedTime);
    print('Wake time saved: ${DateTime.now()}');
  }
  Future<void> saveSleepTime() async {
    final prefs = await SharedPreferences.getInstance();
    String formattedTime = DateFormat('HH:mm').format(DateTime.now());
    await prefs.setString('sleepTime', formattedTime);
    print('Go to sleep time saved: ${DateTime.now()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wake/Sleep Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                saveWakeTime();
              },
              child: Text('I\'m Awake'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveSleepTime();
              },
              child: Text('I\'m Sleep'),
            ),
          ],
        ),
      ),
    );
  }
}
