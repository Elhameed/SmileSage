import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'scan_workflow_screen.dart';
import 'clinics_screen.dart';
import 'learn_screen.dart';

class TipsScreen extends StatefulWidget {
  static const routeName = '/tips';
  const TipsScreen({Key? key}) : super(key: key);

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  int _selectedIndex = 1; // Tips tab

  // Sample data for the daily tips
  final List<Map<String, String>> _tips = [
    {
      'icon': 'assets/images/icon_braces_care.png',
      'title': 'Braces Care: Gentle Brushing',
      'desc':
          'Brush gently around brackets and wires to remove plaque and food particles.',
    },
    {
      'icon': 'assets/images/icon_braces_care.png',
      'title': 'Braces Care: Flossing',
      'desc':
          'Use a floss threader or interdental brush to clean between teeth and under wires.',
    },
    {
      'icon': 'assets/images/icon_braces_care.png',
      'title': 'Braces Care: Mouthwash',
      'desc':
          'Rinse with fluoride mouthwash to strengthen enamel and prevent cavities.',
    },
  ];

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
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
      case 1:
        // already here
        break;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    const headingText = Colors.black;
    const bodyText = Color(0xFF000000);
    const subtitleText = Color(0xFF6B7D82);
    const iconBg = Color(0xFFE8F4EC);
    const primaryGreen = Color(0xFF7CF4A4);
    const lightGray = Color(0xFFFAFAFA);
    const backgroundWhite = Colors.white;
    const goldText = Color(0xFFB58E31);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Daily Dental Tips',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro text
            const Text(
              'Here are your personalized tips for today.\nKeep up the great work!',
              style: TextStyle(fontSize: 16, color: bodyText),
            ),

            const SizedBox(height: 24),

            // Tip items
            ..._tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Image.asset(tip['icon']!, width: 24, height: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: headingText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tip['desc']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: subtitleText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Streak Tracker
            const Text(
              'Streak Tracker',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: headingText,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Daily Streak',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: headingText,
              ),
            ),
            const SizedBox(height: 8),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 3 / 5,
                minHeight: 8,
                backgroundColor: lightGray,
                color: headingText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '3/5 Days',
              style: TextStyle(fontSize: 14, color: subtitleText),
            ),

            const SizedBox(height: 24),

            // Rewards
            const Text(
              'Rewards',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: headingText,
              ),
            ),
            const SizedBox(height: 16),

            // Points Earned
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.monetization_on, color: headingText),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Points Earned',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: headingText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Earned 150 points for completing your daily tips!',
                        style: TextStyle(fontSize: 14, color: subtitleText),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Badge Unlocked
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.emoji_events, color: headingText),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Badge Unlocked',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: headingText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Unlocked the 'Brace Master' badge for consistent care!",
                        style: TextStyle(fontSize: 14, color: subtitleText),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
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
