import 'package:flutter/material.dart';
import 'scan_workflow_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Tracks which bottom nav item is selected; Home = 0
  int _selectedIndex = 0;

  void _onNavItemTapped(int index) {
    if (index == 2) {
      // Scan icon tapped → navigate to ScanWorkflowScreen
      Navigator.of(context).pushNamed(ScanWorkflowScreen.routeName);
      return; // keep Home selected
    }
    // Otherwise, update state to reflect selected index
    setState(() => _selectedIndex = index);
    // TODO: add navigation to other tabs (Tips, Clinics, Learn) as needed
  }

  @override
  Widget build(BuildContext context) {
    // Color constants
    const backgroundWhite = Colors.white;
    const darkText = Color(0xFF0A244E);
    const goldText = Color(0xFFB58E31);
    const primaryGreen = Color(0xFF7CF4A4);
    const lightBeige = Color(0xFFF5F0E6);

    return Scaffold(
      backgroundColor: backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // 1) Top Bar: Avatar, "Hi, Sarah", and two action icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                  const SizedBox(width: 12),
                  // Greeting Text
                  const Expanded(
                    child: Text(
                      'Hi, Sarah',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                  ),
                  // Icon 1 (e.g., streak icon)
                  IconButton(
                    icon: const Icon(
                      Icons.local_fire_department,
                      color: darkText,
                    ),
                    onPressed: () {
                      // TODO: handle streak action
                    },
                  ),
                  // Notification Bell icon
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: darkText),
                    onPressed: () {
                      // TODO: handle notification action
                    },
                  ),
                ],
              ),
            ),

            // 2) “Keep your smile healthy!” header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: const [
                  Text(
                    'Keep your smile\nhealthy!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3) Brushing Streak Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image at top of card
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.asset(
                        'assets/images/home_card.png',
                        height: 250,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),

                    // Card content: Streak text, subtext, and button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Brushing Streak: 5 Days',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Keep up the great work!',
                            style: TextStyle(fontSize: 16, color: goldText),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: navigate to brushing tracker logic
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                shape: const StadiumBorder(),
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Track my brushing',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
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

            // 4) Two tab buttons: Explore (green) and Daily Tip (beige)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Explore button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: handle Explore tap
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Daily Tip button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: handle Daily Tip tap
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightBeige,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Daily Tip',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Spacer to push content up so bottom nav sits at bottom
            const Spacer(),
          ],
        ),
      ),

      // 5) BottomNavigationBar
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
