import 'dart:async';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';

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
    // After 4 seconds, go to WelcomeScreen
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacementNamed(WelcomeScreen.routeName);
    });
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
