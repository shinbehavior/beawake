import 'package:beawake/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:beawake/screens/home_screen.dart';
import 'package:beawake/screens/friends_screen.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  final List<Widget> _children = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    var auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        setState(() {
          _children.clear();
          _children.add(SignInScreen());
        });
      } else {
        setState(() {
          _children..clear()
                   ..add(HomeScreen())
                   ..add(FriendsScreen());
        });
      }
    });
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _children,
        ),
        bottomNavigationBar: _children.length > 1 ? BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.superscript), label: "Main"),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
          ],
        ) : null,
      ),
    );
  }
}
