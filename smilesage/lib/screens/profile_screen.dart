import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'tips_screen.dart';
import 'scan_workflow_screen.dart';
import 'clinics_screen.dart';
import 'learn_screen.dart';
import 'scan_history_screen.dart';
import 'reminders_screen.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  String? _name;
  String? _email;
  String? _age;
  bool _editingName = false;
  bool _editingAge = false;
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _profileImageBase64;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    _name = user?.displayName ?? '';
    _email = user?.email ?? '';
    _nameController.text = _name ?? '';
    _loadAge();
    _loadProfileImage();
  }

  Future<void> _loadAge() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _age = prefs.getString('user_age') ?? '';
      _ageController.text = _age ?? '';
    });
  }

  Future<void> _saveAge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_age', _ageController.text.trim());
    setState(() {
      _age = _ageController.text.trim();
      _editingAge = false;
    });
  }

  Future<void> _saveName() async {
    final user = AuthService().currentUser;
    await user?.updateDisplayName(_nameController.text.trim());
    setState(() {
      _name = _nameController.text.trim();
      _editingName = false;
    });
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', base64Image);
      setState(() {
        _profileImageBase64 = base64Image;
      });
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageBase64 = prefs.getString('profile_image');
    });
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
            const SizedBox(height: 8),
            _buildProfileAvatar(),
            const SizedBox(height: 16),

            // Name & email
            Text(
              _name ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: headingText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _email ?? '',
              style: const TextStyle(fontSize: 14, color: subtitleText),
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
                Expanded(
                  child: _editingName
                      ? TextField(
                          controller: _nameController,
                          autofocus: true,
                          onSubmitted: (_) => _saveName(),
                        )
                      : Text(
                          _name ?? '',
                          style: const TextStyle(
                              fontSize: 16, color: subtitleText),
                        ),
                ),
                IconButton(
                  icon: Icon(_editingName ? Icons.check : Icons.edit,
                      color: headingText),
                  onPressed: () {
                    if (_editingName) {
                      _saveName();
                    } else {
                      setState(() => _editingName = true);
                    }
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
                Expanded(
                  child: _editingAge
                      ? TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          onSubmitted: (_) => _saveAge(),
                        )
                      : Text(
                          _age ?? 'Optional',
                          style: const TextStyle(
                              fontSize: 16, color: subtitleText),
                        ),
                ),
                IconButton(
                  icon: Icon(_editingAge ? Icons.check : Icons.edit,
                      color: headingText),
                  onPressed: () {
                    if (_editingAge) {
                      _saveAge();
                    } else {
                      setState(() => _editingAge = true);
                    }
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
                    onPressed: () async {
                      await AuthService().signOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          LoginScreen.routeName, (route) => false);
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

  Widget _buildProfileAvatar() {
    Widget avatar;
    if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: 48,
        backgroundImage: MemoryImage(base64Decode(_profileImageBase64!)),
      );
    } else {
      avatar = const CircleAvatar(
        radius: 48,
        backgroundImage: AssetImage('assets/images/avatar.png'),
      );
    }
    return Stack(
      children: [
        avatar,
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickProfileImage,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.edit, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
