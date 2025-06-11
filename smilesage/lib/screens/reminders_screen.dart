import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'tips_screen.dart';
import 'scan_workflow_screen.dart';
import 'clinics_screen.dart';
import 'learn_screen.dart';

class RemindersScreen extends StatefulWidget {
  static const routeName = '/reminders';
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _dailyTips = false;
  bool _bracesCleaning = false;
  bool _checkup = false;
  int _selectedIndex = 0;

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
    const bgWhite = Colors.white;
    const headingText = Colors.black;
    const primaryGreen = Color(0xFF7CF4A4);
    const goldText = Color(0xFFB58E31);

    return Scaffold(
      backgroundColor: bgWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: headingText),
        title: const Text(
          'Reminders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Upcoming section
            const Text(
              'Upcoming',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: headingText,
              ),
            ),
            const SizedBox(height: 16),

            // Daily Tip Reminders
            _ReminderToggleTile(
              icon: Icons.notifications,
              label: 'Daily Tip Reminders',
              sublabel: 'Daily',
              value: _dailyTips,
              onChanged: (v) => setState(() => _dailyTips = v),
            ),
            const SizedBox(height: 16),

            // Braces Cleaning Alerts
            _ReminderToggleTile(
              icon: Icons.brush,
              label: 'Braces Cleaning Alerts',
              sublabel: 'Daily',
              value: _bracesCleaning,
              onChanged: (v) => setState(() => _bracesCleaning = v),
            ),
            const SizedBox(height: 16),

            // 6–8 Week Check-Up
            _ReminderToggleTile(
              icon: Icons.calendar_today,
              label: '6-8 Week Check-Up',
              sublabel: 'Every 6-8 weeks',
              value: _checkup,
              onChanged: (v) => setState(() => _checkup = v),
            ),

            const SizedBox(height: 32),
            // Actions section
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: headingText,
              ),
            ),
            const SizedBox(height: 16),

            _ActionTile(
              icon: Icons.snooze,
              label: 'Snooze',
              onTap: () {
                // TODO: Snooze logic
              },
            ),
            const SizedBox(height: 16),

            _ActionTile(
              icon: Icons.edit,
              label: 'Edit',
              onTap: () {
                // TODO: Edit logic
              },
            ),
            const SizedBox(height: 16),

            _ActionTile(
              icon: Icons.delete,
              label: 'Delete',
              onTap: () {
                // TODO: Delete logic
              },
            ),
          ],
        ),
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: bgWhite,
        selectedItemColor: primaryGreen,
        unselectedItemColor: goldText,
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
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

/// A row with icon, label, sublabel, and a Switch.
class _ReminderToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ReminderToggleTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const headingText = Colors.black;
    const subtitleText = Color(0xFF638775);
    const iconBg = Color(0xFFE8F4EC);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: headingText),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: headingText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: const TextStyle(fontSize: 14, color: subtitleText),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: onChanged is ValueChanged<bool>
              ? const Color(0xFF7CF4A4)
              : null,
        ),
      ],
    );
  }
}

/// A row with icon, label, and chevron arrow.
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const headingText = Colors.black;
    const iconBg = Color(0xFFE8F4EC);

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: headingText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: headingText),
            ),
          ),
          const Icon(Icons.chevron_right, color: headingText),
        ],
      ),
    );
  }
}
