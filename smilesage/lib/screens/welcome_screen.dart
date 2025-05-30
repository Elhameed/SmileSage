import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = '/welcome';
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1) Full-screen background
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2) Centered logo + tagline
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo (includes SmileSage text)
                Image.asset(
                  'assets/images/welcome_logo.png',
                  width: 180,
                  height: 180,
                ),

                const SizedBox(height: 16),

                // Tagline in #004060
                const Text(
                  'AI-Powered Oral Health, One Scan at a Time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF004060),
                  ),
                ),
              ],
            ),
          ),

          // 3) Bottom-anchored Get Started button
          Positioned(
            left: 32,
            right: 32,
            bottom: 48 + MediaQuery.of(context).padding.bottom,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/sign-up');
                },
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: const Color(0xFF7CF4A4),
                  elevation: 4,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A244E),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
