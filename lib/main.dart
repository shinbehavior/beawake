import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'services/firebase_service.dart';  // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Create FirebaseService instance
    final firebaseService = FirebaseService();
    
    // Create mock users (you might want to do this only in debug mode)
    await firebaseService.createMockUsers();
    
    runApp(
      ProviderScope(
        child: MyApp(),
      ),
    );
  } catch (e) {
    runApp(ErrorApp(message: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Error: $message')),
      ),
    );
  }
}