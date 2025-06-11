import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'tips_screen.dart';
import 'scan_workflow_screen.dart';
import 'clinics_screen.dart';
import 'learn_screen.dart';
import 'scan_history_screen.dart';
import 'reminders_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;

  bool _wearBraces = false;
  bool _dailyTips = false;
  bool _checkupReminders = false;

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(TipsScreen.routeName);
        break;
      case 2:
        Navigator.of(context).pushNamed(ScanWorkflowScreen.routeName);
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed(ClinicsScreen.routeName);
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed(LearnScreen.routeName);
        break;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    const headingText = Color(0xFF0A244E);
    const subtitleText = Color(0xFF7CA78C);
    const inputBg = Color(0xFFE8F4EC);
    const goldText = Color(0xFFB58E31);
    const primaryGreen = Color(0xFF7CF4A4);
    const backgroundWhite = Colors.white;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            const CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
            const SizedBox(height: 16),

            // Name & email
            const Text(
              'Ethan Carter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: headingText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'ethan.carter@email.com',
              style: TextStyle(fontSize: 14, color: subtitleText),
            ),

            const SizedBox(height: 24),

            // Account heading
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: headingText,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name field
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: headingText,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ethan Carter',
                    style: TextStyle(fontSize: 16, color: subtitleText),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: headingText),
                  onPressed: () {
                    // TODO: edit name
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Age field
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Age',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: headingText,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Optional',
                    style: TextStyle(fontSize: 16, color: subtitleText),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: headingText),
                  onPressed: () {
                    // TODO: edit age
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Braces toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'I wear braces',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: headingText,
                  ),
                ),
                Switch(
                  value: _wearBraces,
                  onChanged: (v) => setState(() => _wearBraces = v),
                  activeColor: primaryGreen,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Notifications heading
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: headingText,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Daily tips toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Daily tips',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: headingText,
                    ),
                  ),
                ),
                Switch(
                  value: _dailyTips,
                  onChanged: (v) => setState(() => _dailyTips = v),
                  activeColor: primaryGreen,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Check-up reminders toggle
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: const Text(
                          'Check-up reminders',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: headingText,
                          ),
                        ),
                      ),
                      Switch(
                        value: _checkupReminders,
                        onChanged: (v) => setState(() => _checkupReminders = v),
                        activeColor: primaryGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Every day',
                    style: TextStyle(fontSize: 14, color: subtitleText),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Actions heading
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: headingText,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: view scan history
                      Navigator.of(
                        context,
                      ).pushNamed(ScanHistoryScreen.routeName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: inputBg,
                      shape: const StadiumBorder(),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'View Scan History',
                      style: TextStyle(
                        fontSize: 16,
                        color: headingText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: manage reminders
                      Navigator.of(
                        context,
                      ).pushNamed(RemindersScreen.routeName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: inputBg,
                      shape: const StadiumBorder(),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Manage Reminders',
                      style: TextStyle(
                        fontSize: 16,
                        color: headingText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: logout
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: inputBg,
                      shape: const StadiumBorder(),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        color: headingText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: backgroundWhite,
        selectedItemColor: primaryGreen,
        unselectedItemColor: goldText,
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon_home.png')),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon_tips.png')),
            label: 'Tips',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon_scan.png')),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon_clinics.png')),
            label: 'Clinics',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon_learn.png')),
            label: 'Learn',
          ),
        ],
      ),
    );
  }
}
