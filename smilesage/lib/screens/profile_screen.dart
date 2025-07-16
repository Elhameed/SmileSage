import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'tips_screen.dart';
import 'scan_workflow_screen.dart';
import 'clinics_screen.dart';
import 'learn_screen.dart';
import 'scan_history_screen.dart';
import 'reminders_screen.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/local_data_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;
  final ProfileService _profileService = ProfileService();

  // Loading states
  bool _isLoading = true;
  bool _isSaving = false;

  // Notification toggles
  bool _wearBraces = false;
  bool _dailyTips = false;
  bool _checkupReminders = false;

  // SharedPreferences keys (same as RemindersScreen and PermissionsScreen)
  static const String dailyTipsOptInKey = 'daily_tips_opt_in';
  static const String brushingOptInKey = 'brushing_opt_in';
  static const String bracesKey = 'user_has_braces';

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
    _loadProfileData();
    // Remove unnecessary local history entry to fix double back press
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize profile in Firebase if needed
      await _profileService.initializeProfile();

      // Load profile data from Firebase
      final profile = await _profileService.getProfile();
      final user = AuthService().currentUser;

      setState(() {
        _name = profile?['displayName'] ?? user?.displayName ?? '';
        _email = user?.email ?? '';
        _age = profile?['age'] ?? '';
        _profileImageBase64 = profile?['profileImageBase64'];
        _nameController.text = _name ?? '';
        _ageController.text = _age ?? '';
        _isLoading = false;
      });

      // Load local preferences (for backward compatibility)
      await _loadReminderToggles();
      await _loadBracesPreference();

      // Sync preferences with Firebase
      await _syncPreferencesWithFirebase();
    } catch (e) {
      print('Error loading profile data: $e');
      // Fallback to local data
      final user = AuthService().currentUser;
      setState(() {
        _name = user?.displayName ?? '';
        _email = user?.email ?? '';
        _nameController.text = _name ?? '';
        _isLoading = false;
      });
      _loadAge();
      _loadProfileImage();
      _loadReminderToggles();
      _loadBracesPreference();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload toggles every time dependencies change (e.g., after coming back from RemindersScreen)
    _loadReminderToggles();
    _loadBracesPreference();
  }

  Future<void> _loadAge() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _age = prefs.getString('user_age') ?? '';
      _ageController.text = _age ?? '';
    });
  }

  Future<void> _saveAge() async {
    final age = _ageController.text.trim();

    // Save to local storage (for backward compatibility)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_age', age);

    // Save to Firebase
    try {
      await _profileService.updateAge(age);
    } catch (e) {
      print('Error saving age to Firebase: $e');
    }

    setState(() {
      _age = age;
      _editingAge = false;
    });
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();

    setState(() {
      _isSaving = true;
    });

    // Update Firebase Auth and Firestore
    try {
      await _profileService.updateDisplayName(name);
      setState(() {
        _name = name;
        _editingName = false;
        _isSaving = false;
      });
    } catch (e) {
      print('Error saving name to Firebase: $e');
      setState(() {
        _isSaving = false;
      });
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save name: $e')),
        );
      }
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Save to local storage (for backward compatibility)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', base64Image);

      // Save to Firebase
      try {
        await _profileService.updateProfileImage(base64Image);
      } catch (e) {
        print('Error saving profile image to Firebase: $e');
      }

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

  Future<void> _loadReminderToggles() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyTips = prefs.getBool(dailyTipsOptInKey) ?? false;
      _checkupReminders = prefs.getBool(brushingOptInKey) ?? false;
    });
  }

  Future<void> _loadBracesPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _wearBraces = prefs.getBool(bracesKey) ?? false;
    });
  }

  Future<void> _setDailyTips(bool value) async {
    // Save to local storage (for backward compatibility)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(dailyTipsOptInKey, value);

    // Save to Firebase
    try {
      await _profileService.syncPreferences(dailyTips: value);
    } catch (e) {
      print('Error saving daily tips preference to Firebase: $e');
    }

    setState(() {
      _dailyTips = value;
    });
  }

  Future<void> _setBrushingReminders(bool value) async {
    // Save to local storage (for backward compatibility)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(brushingOptInKey, value);

    // Save to Firebase
    try {
      await _profileService.syncPreferences(brushingReminders: value);
    } catch (e) {
      print('Error saving brushing reminders preference to Firebase: $e');
    }

    setState(() {
      _checkupReminders = value;
    });
  }

  Future<void> _setBraces(bool value) async {
    // Save to local storage (for backward compatibility)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(bracesKey, value);

    // Save to Firebase
    try {
      await _profileService.syncPreferences(hasBraces: value);
    } catch (e) {
      print('Error saving braces preference to Firebase: $e');
    }

    setState(() {
      _wearBraces = value;
    });
  }

  Future<void> _syncPreferencesWithFirebase() async {
    try {
      await _profileService.syncPreferences(
        dailyTips: _dailyTips,
        brushingReminders: _checkupReminders,
        hasBraces: _wearBraces,
      );
    } catch (e) {
      print('Error syncing preferences with Firebase: $e');
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
        title: Text(
          AppLocalizations.of(context)!.profile,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.account,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: headingText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.profileName,
                      style: const TextStyle(
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.age,
                      style: const TextStyle(
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
                                decoration: InputDecoration(
                                  hintText:
                                      AppLocalizations.of(context)!.optional,
                                ),
                                onSubmitted: (_) => _saveAge(),
                              )
                            : Text(
                                (_age == null || _age!.isEmpty)
                                    ? AppLocalizations.of(context)!.optional
                                    : _age!,
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
                      Text(
                        AppLocalizations.of(context)!.iWearBraces,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: headingText,
                        ),
                      ),
                      Switch(
                        value: _wearBraces,
                        onChanged: (v) => _setBraces(v),
                        activeColor: primaryGreen,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Notifications heading
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.profileNotifications,
                      style: const TextStyle(
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
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.dailyTips,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: headingText,
                          ),
                        ),
                      ),
                      Switch(
                        value: _dailyTips,
                        onChanged: (v) => _setDailyTips(v),
                        activeColor: primaryGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Brushing reminders toggle
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.brushingReminders,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: headingText,
                                ),
                              ),
                            ),
                            Switch(
                              value: _checkupReminders,
                              onChanged: (v) => _setBrushingReminders(v),
                              activeColor: primaryGreen,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.everyDay,
                          style: const TextStyle(
                              fontSize: 14, color: subtitleText),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Actions heading
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.actions,
                      style: const TextStyle(
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
                          child: Text(
                            AppLocalizations.of(context)!.viewScanHistory,
                            style: const TextStyle(
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
                          child: Text(
                            AppLocalizations.of(context)!.manageReminders,
                            style: const TextStyle(
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
                            await LocalDataService.clearUserLocalData();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                LoginScreen.routeName, (route) => false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: inputBg,
                            shape: const StadiumBorder(),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.logout,
                            style: const TextStyle(
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
        items: [
          BottomNavigationBarItem(
            icon: const ImageIcon(AssetImage('assets/images/icon_home.png')),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const ImageIcon(AssetImage('assets/images/icon_tips.png')),
            label: AppLocalizations.of(context)!.tips,
          ),
          BottomNavigationBarItem(
            icon: const ImageIcon(AssetImage('assets/images/icon_scan.png')),
            label: AppLocalizations.of(context)!.scan,
          ),
          BottomNavigationBarItem(
            icon: const ImageIcon(AssetImage('assets/images/icon_clinics.png')),
            label: AppLocalizations.of(context)!.clinics,
          ),
          BottomNavigationBarItem(
            icon: const ImageIcon(AssetImage('assets/images/icon_learn.png')),
            label: AppLocalizations.of(context)!.learn,
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
