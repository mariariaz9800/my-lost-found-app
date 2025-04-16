import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';        // Replace with your actual path
import 'welcome_screen.dart';     // Replace with your actual path

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnAuthStatus();
  }

  Future<void> _navigateBasedOnAuthStatus() async {
    // Optional delay to show splash effect
    await Future.delayed(const Duration(seconds: 2));

    // Check if a user is already signed in
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in - navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()), // Removed `const`
      );
    } else {
      // No user signed in - navigate to WelcomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()), // Removed `const`
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // You can replace with logo/animation
      ),
    );
  }
}
