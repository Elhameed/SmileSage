import 'dart:async';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class StartScreen extends StatefulWidget {
  static const routeName = '/';
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(seconds: 3)); // splash duration
    final user = AuthService().currentUser;
    if (user != null) {
      // User is logged in, go to Home
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } else {
      // Not logged in, go to Welcome
      Navigator.of(context).pushReplacementNamed(WelcomeScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen background
          Positioned.fill(
            child: Image.asset(
              'assets/images/start_background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Center logo
          Center(
            child: Image.asset(
              'assets/images/start_logo.png',
              width: 150,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}
