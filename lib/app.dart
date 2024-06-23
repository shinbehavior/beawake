import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:beawake/screens/home_screen.dart';
import 'package:beawake/screens/friends_screen.dart';
import 'package:beawake/screens/sign_up_screen.dart';
import 'package:beawake/screens/stats_screen.dart';
import 'package:provider/provider.dart';
import 'providers/event_manager.dart';
import 'providers/shared.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToHome() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushReplacement(
        MaterialPageRoute(
          builder: (context) => _buildMainScreen(),
        ),
      );
    }
  }

  void _skipRegistration() {
    setState(() {
      _isLoggedIn = true;
      _userId = "skipUser";
      Shared.saveLoginSharedPreference(true);
      _navigateToHome();
    });
  }

  void _selectMockUser(String mockUserId) {
    setState(() {
      _isLoggedIn = true;
      _userId = mockUserId;
      Shared.saveLoginSharedPreference(true);
      _navigateToHome();
    });
  }

  void _setUserId(String userId) {
    setState(() {
      _userId = userId;
      Shared.saveLoginSharedPreference(true);
    });
  }

  Future<void> _checkLoginStatus() async {
    bool? isLoggedIn = await Shared.getUserSharedPreferences();
    if (isLoggedIn == true) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _setUserId(user.uid);
        setState(() {
          _isLoggedIn = true;
        });
      } else {
        setState(() {
          _isLoggedIn = false;
        });
      }
    } else {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Shared.saveLoginSharedPreference(false);
    setState(() {
      _isLoggedIn = false;
      _userId = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(
            builder: (context) => SignUpScreen(
              onSkip: _skipRegistration,
              onSelectMockUser: _selectMockUser,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EventManager(_userId),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeData(
          primaryColor: const Color(0xFF1E1E2C),
          scaffoldBackgroundColor: const Color(0xFF1E1E2C),
          appBarTheme: const AppBarTheme(
            color: Color(0xFF2C2C38),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF2C2C38),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
          ),
        ),
        home: _isLoggedIn
            ? _buildMainScreen()
            : SignUpScreen(
                onSkip: _skipRegistration,
                onSelectMockUser: _selectMockUser,
              ),
      ),
    );
  }

  Widget _buildMainScreen() {
    if (_userId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EventManager(_userId),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("beawake"),
          centerTitle: true,
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _signOut(context),
                );
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(userId: _userId!),
            const StatsScreen(),
            FriendsScreen(userId: _userId!),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Stats"),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
          ],
        ),
      ),
    );
  }
}
