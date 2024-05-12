import 'package:beawake/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:beawake/screens/home_screen.dart';
import 'package:beawake/screens/friends_screen.dart';
import 'package:flutter/widgets.dart';

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
      print("Auth state changed, user: $user");
      if (user == null) {
        setState(() {
          _children.clear();
          _children.add(SignInScreen());
          print("No user found, showing SigninScreen");
        });
      } else {
        setState(() {
          _children..clear()
                   ..add(HomeScreen())
                   ..add(FriendsScreen());
          print("User logged in, showing HomeScreen and FriendsScreen");
        });
      }
    });
  }

  void onTabTapped(int index) {
    print("Tab tapped: $index");
    setState(() {
      _currentIndex = index;
      print("Current index set to: $_currentIndex");
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Building Scaffold with current index: $_currentIndex");
    print("Children count: ${_children.length}");
    return MaterialApp(
      home: Scaffold(
        key: ValueKey<int>(_children.length),
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
