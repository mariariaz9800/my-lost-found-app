import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';  // Firebase Core
import 'firebase_options.dart';                     // Generated firebase_options.dart
import 'screens/splash_screen.dart';                // Make sure you create this file

// 1. Create Theme Manager Class
class ThemeManager with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with options for current platform
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Item Radar App',
      theme: themeManager.isDarkMode
          ? ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.dark().copyWith(secondary: Colors.blueAccent),
      )
          : ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.light().copyWith(secondary: Colors.blueAccent),
      ),
      home: FirebaseInitializer(),  // Using FirebaseInitializer to check Firebase state
    );
  }
}

class FirebaseInitializer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Firebase is initialized, navigate to the splash screen
          return const SplashScreen();
        } else if (snapshot.hasError) {
          // If an error occurred during initialization, display error message
          return Center(child: Text('Error initializing Firebase: ${snapshot.error}'));
        }
        // While Firebase is initializing, show a loading indicator
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
