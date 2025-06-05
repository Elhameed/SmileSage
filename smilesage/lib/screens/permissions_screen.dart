// lib/screens/permissions_screen.dart

import 'package:flutter/material.dart';

class PermissionsScreen extends StatefulWidget {
  static const routeName = '/permissions';
  const PermissionsScreen({Key? key}) : super(key: key);

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _hasBraces = false;
  bool _dailyTips = false;
  bool _checkupReminders = false;

  @override
  Widget build(BuildContext context) {
    const canvasBg = Color(0xFFF7FAFA);
    const primaryGreen = Color(0xFF7CF4A4);
    const headingText = Color(0xFF0A244E);
    const bodyText = Color(0xFF000000);
    const subtitleText = Color(0xFF7CA78C);

    return Scaffold(
      backgroundColor: canvasBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // extra space below back arrow
            const SizedBox(height: 16),
            // Heading text
            const Text(
              "Let's get started",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: headingText,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'We’ll need to ask for a few permissions before\nwe can get started.',
              style: TextStyle(fontSize: 16, color: bodyText),
            ),

            const SizedBox(height: 32),
            // Braces toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Do you wear braces?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: headingText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'This will help us provide better recommendations.',
                        style: TextStyle(fontSize: 14, color: subtitleText),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _hasBraces,
                  onChanged: (v) => setState(() => _hasBraces = v),
                  activeColor: primaryGreen,
                ),
              ],
            ),

            const SizedBox(height: 32),
            // Notification preferences heading
            const Text(
              'Notification preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: headingText,
              ),
            ),

            const SizedBox(height: 16),
            // Daily tips toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Daily tips',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: headingText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Receive dental care tips every day',
                        style: TextStyle(fontSize: 14, color: subtitleText),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _dailyTips,
                  onChanged: (v) => setState(() => _dailyTips = v),
                  activeColor: primaryGreen,
                ),
              ],
            ),

            const SizedBox(height: 24),
            // Check-up reminders toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Check-up reminders',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: headingText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Get reminders to check your teeth',
                        style: TextStyle(fontSize: 14, color: subtitleText),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _checkupReminders,
                  onChanged: (v) => setState(() => _checkupReminders = v),
                  activeColor: primaryGreen,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              shape: const StadiumBorder(),
              elevation: 4,
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: headingText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
