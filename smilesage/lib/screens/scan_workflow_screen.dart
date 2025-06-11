import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'tips_screen.dart';
import 'clinics_screen.dart';
import 'learn_screen.dart';
import 'general_scan_screen.dart';

class ScanWorkflowScreen extends StatefulWidget {
  static const routeName = '/scan-workflow';
  const ScanWorkflowScreen({Key? key}) : super(key: key);

  @override
  State<ScanWorkflowScreen> createState() => _ScanWorkflowScreenState();
}

class _ScanWorkflowScreenState extends State<ScanWorkflowScreen> {
  // Mark "Scan" as the selected tab
  int _selectedIndex = 2;

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(TipsScreen.routeName);
        break;
      case 2:
        // Already on Scan
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
    const blackText = Colors.black;
    const subtitleText = Color(0xFF3A3A3A);
    const descriptionGold = Color(0xFFA1824A);
    const primaryGreen = Color(0xFF00C566);
    const backgroundWhite = Colors.white;
    const goldText = Color(0xFFB58E31);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header & Scan Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  const Text(
                    'Scan Your Teeth',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: blackText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose the type of scan you’d like to perform. Hold your phone steady while scanning.',
                    style: TextStyle(
                      fontSize: 16,
                      color: subtitleText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ScanOptionTile(
                    title: 'General Scan',
                    description:
                        'Scan your teeth for cavities, gum disease, and more',
                    descriptionColor: descriptionGold,
                    onTap: () => Navigator.of(
                      context,
                    ).pushReplacementNamed(GeneralScanScreen.routeName),
                  ),
                  const SizedBox(height: 16),
                  _ScanOptionTile(
                    title: 'Braces Scan',
                    description: 'Scan your teeth for braces related issues',
                    descriptionColor: descriptionGold,
                    onTap: () {
                      // TODO: navigate to BracesScanScreen
                    },
                  ),
                ],
              ),
            ),

            // Ensure map/image sits under options and above nav
            const SizedBox(height: 48),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  'assets/images/teeth_scan.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 36),
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

class _ScanOptionTile extends StatelessWidget {
  final String title;
  final String description;
  final Color descriptionColor;
  final VoidCallback onTap;

  const _ScanOptionTile({
    Key? key,
    required this.title,
    required this.description,
    required this.descriptionColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const blackText = Color(0xFF0A244E);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: blackText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: descriptionColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 28, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}
