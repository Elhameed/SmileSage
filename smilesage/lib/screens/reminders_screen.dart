import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'tips_screen.dart';
import 'scan_workflow_screen.dart';
import 'clinics_screen.dart';
import 'learn_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  TimeOfDay _dailyTipsTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _brushingTime = const TimeOfDay(hour: 20, minute: 0);

  static const String dailyTipsOptInKey = 'daily_tips_opt_in';
  static const String dailyTipsTimeKey = 'daily_tips_time';
  static const String brushingTimeKey = 'brushing_time';
  static const String brushingOptInKey = 'brushing_opt_in';

  @override
  void initState() {
    super.initState();
    _loadOptInStatus();
    _loadTimes();
    NotificationService().init();
    NotificationService().setOnNotificationTap((payload) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notification Tapped'),
          content: Text(payload != null && payload.isNotEmpty
              ? 'Payload: $payload'
              : 'You tapped a SmileSage notification!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _loadOptInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyTips = prefs.getBool(dailyTipsOptInKey) ?? false;
      _bracesCleaning = prefs.getBool(brushingOptInKey) ?? false;
    });
  }

  Future<void> _loadTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final tipsTimeStr = prefs.getString(dailyTipsTimeKey);
    final brushingTimeStr = prefs.getString(brushingTimeKey);
    if (tipsTimeStr != null) {
      final parts = tipsTimeStr.split(':');
      _dailyTipsTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    if (brushingTimeStr != null) {
      final parts = brushingTimeStr.split(':');
      _brushingTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    setState(() {});
  }

  Future<void> _setOptInStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(dailyTipsOptInKey, value);
    setState(() {
      _dailyTips = value;
    });
    if (value) {
      await NotificationService().scheduleDailyNotification(
        id: 1,
        time: _dailyTipsTime,
        title: 'Daily Dental Tip',
        body: 'Check out your daily dental tip in SmileSage!',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Daily tip reminder scheduled for ${_dailyTipsTime.format(context)}')),
        );
      }
    } else {
      await NotificationService().cancelNotification(1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daily tip reminder cancelled')),
        );
      }
    }
  }

  Future<void> _setDailyTipsTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dailyTipsTimeKey, '${time.hour}:${time.minute}');
    setState(() {
      _dailyTipsTime = time;
    });
    if (_dailyTips) {
      await NotificationService().scheduleDailyNotification(
        id: 1,
        time: time,
        title: 'Daily Dental Tip',
        body: 'Check out your daily dental tip in SmileSage!',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Daily tip reminder rescheduled for ${time.format(context)}')),
        );
      }
    }
  }

  Future<void> _setBrushingTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(brushingTimeKey, '${time.hour}:${time.minute}');
    setState(() {
      _brushingTime = time;
    });
    if (_bracesCleaning) {
      await NotificationService().scheduleDailyNotification(
        id: 2,
        time: time,
        title: 'Brushing Reminder',
        body: 'Time to brush your teeth! Keep your smile healthy.',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Brushing reminder rescheduled for ${time.format(context)}')),
        );
      }
    }
  }

  Future<void> _setBracesCleaning(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(brushingOptInKey, value);
    setState(() {
      _bracesCleaning = value;
    });
    if (value) {
      await NotificationService().scheduleDailyNotification(
        id: 2,
        time: _brushingTime,
        title: 'Brushing Reminder',
        body: 'Time to brush your teeth! Keep your smile healthy.',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Brushing reminder scheduled for ${_brushingTime.format(context)}')),
        );
      }
    } else {
      await NotificationService().cancelNotification(2);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Brushing reminder cancelled')),
        );
      }
    }
  }

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
            Row(
              children: [
                Expanded(
                  child: _ReminderToggleTile(
                    icon: Icons.notifications,
                    label: 'Daily Tip Reminders',
                    sublabel: 'Daily',
                    value: _dailyTips,
                    onChanged: (v) => _setOptInStatus(v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: _dailyTips
                      ? () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _dailyTipsTime,
                          );
                          if (picked != null) {
                            await _setDailyTipsTime(picked);
                          }
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Braces Cleaning Alerts
            Row(
              children: [
                Expanded(
                  child: _ReminderToggleTile(
                    icon: Icons.brush,
                    label: 'Teeth Brushing Reminders',
                    sublabel: 'Daily',
                    value: _bracesCleaning,
                    onChanged: (v) => _setBracesCleaning(v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: _bracesCleaning
                      ? () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _brushingTime,
                          );
                          if (picked != null) {
                            await _setBrushingTime(picked);
                          }
                        }
                      : null,
                ),
              ],
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
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.notifications_active),
                label: const Text('Test Notification'),
                onPressed: () async {
                  await NotificationService()
                      .flutterLocalNotificationsPlugin
                      .show(
                        999,
                        'Test Notification',
                        'This is a test notification from SmileSage.',
                        const NotificationDetails(
                          android: AndroidNotificationDetails(
                            'smilesage_channel',
                            'SmileSage Reminders',
                            channelDescription:
                                'Reminders for daily tips and brushing',
                            importance: Importance.max,
                            priority: Priority.high,
                          ),
                          iOS: DarwinNotificationDetails(),
                        ),
                      );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.timer),
                label: const Text('Test 10s Scheduled Notification'),
                onPressed: () async {
                  await NotificationService().scheduleQuickTestNotification();
                },
              ),
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
          activeColor:
              onChanged is ValueChanged<bool> ? const Color(0xFF7CF4A4) : null,
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
