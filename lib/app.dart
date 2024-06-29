import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beawake/screens/home_screen.dart';
import 'package:beawake/screens/friends_screen.dart';
import 'package:beawake/screens/sign_up_screen.dart';
import 'package:beawake/screens/stats_screen.dart';
import 'providers/event_manager.dart';
import 'providers/shared.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _isLoggedIn = false;
  String? _userId;
  late EventManager _eventManager;
  int _currentIndex = 0;
  late List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _eventManager = EventManager(null);
    _children = [];
    _checkLoginStatus();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _checkLoginStatus() async {
    bool? isLoggedIn = await Shared.getUserSharedPreferences();
    if (isLoggedIn == true) {
      setState(() {
        _isLoggedIn = true;
      });
      // Here you would typically get the user ID from your authentication system
      // For now, we'll use a placeholder
      _setUserId("loggedInUserId");
    } else {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  void _setUserId(String userId) {
    setState(() {
      _userId = userId;
      _eventManager.setUserId(userId);
      Shared.saveLoginSharedPreference(true);
      _initializeChildren();
    });
  }

  void _selectMockUser(String mockUserId) {
    _setUserId(mockUserId);
    _navigateToHome();
  }

  void _navigateToHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => _buildMainScreen()),
      );
    });
  }

  void _initializeChildren() {
    if (_userId != null) {
      _children = [
        ChangeNotifierProvider.value(
          value: _eventManager,
          child: HomeScreen(userId: _userId!),
        ),
        const StatsScreen(),
        FriendsScreen(userId: _userId!),
      ];
    }
  }

  Widget _buildMainScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("beawake"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
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
    );
  }

  void _signOut() async {
    // Implement your sign out logic here
    Shared.saveLoginSharedPreference(false);
    setState(() {
      _isLoggedIn = false;
      _userId = null;
      _eventManager.clearData();
      _children = [];
    });
    _navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (context) => SignUpScreen(
          onSkip: () => _selectMockUser("skipUser"),
          onSelectMockUser: _selectMockUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _eventManager),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
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
                onSkip: () => _selectMockUser("skipUser"),
                onSelectMockUser: _selectMockUser,
              ),
      ),
    );
  }
}