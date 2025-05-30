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
    const primaryGreen = Color(0xFF7CF4A4);
    const headingText = Color(0xFF0A244E);
    const bodyText = Color(0xFF004060);
    const subtitleText = Color(0xFF7CA78C);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Let's get started",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'We’ll need to ask for a few permissions before\nwe can get started.',
              style: TextStyle(fontSize: 16),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

      // Bottom “Done” button
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(24),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Save preferences and navigate forward
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              shape: const StadiumBorder(),
              elevation: 4,
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                fontSize: 18,
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
