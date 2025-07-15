// lib/screens/permissions_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/profile_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PermissionsScreen extends StatefulWidget {
  static const routeName = '/permissions';
  const PermissionsScreen({Key? key}) : super(key: key);

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final ProfileService _profileService = ProfileService();
  bool _hasBraces = false;
  bool _dailyTips = false;
  bool _brushingReminders = false;

  // SharedPreferences keys (same as RemindersScreen and ProfileScreen)
  static const String dailyTipsOptInKey = 'daily_tips_opt_in';
  static const String brushingOptInKey = 'brushing_opt_in';
  static const String bracesKey = 'user_has_braces';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasBraces = prefs.getBool(bracesKey) ?? false;
      _dailyTips = prefs.getBool(dailyTipsOptInKey) ?? false;
      _brushingReminders = prefs.getBool(brushingOptInKey) ?? false;
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
      _hasBraces = value;
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
      _brushingReminders = value;
    });
  }

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
            Text(
              AppLocalizations.of(context)!.letsGetStarted,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: headingText,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              AppLocalizations.of(context)!.permissionsIntro,
              style: const TextStyle(fontSize: 16, color: bodyText),
            ),

            const SizedBox(height: 32),
            // Braces toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.doYouWearBraces,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: headingText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.bracesHelp,
                        style:
                            const TextStyle(fontSize: 14, color: subtitleText),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _hasBraces,
                  onChanged: (v) => _setBraces(v),
                  activeColor: primaryGreen,
                ),
              ],
            ),

            const SizedBox(height: 32),
            // Notification preferences heading
            Text(
              AppLocalizations.of(context)!.notificationPreferences,
              style: const TextStyle(
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
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dailyTips,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: headingText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.receiveDailyTips,
                        style:
                            const TextStyle(fontSize: 14, color: subtitleText),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _dailyTips,
                  onChanged: (v) => _setDailyTips(v),
                  activeColor: primaryGreen,
                ),
              ],
            ),

            const SizedBox(height: 24),
            // Brushing reminders toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.brushingReminders,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: headingText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.getBrushingReminders,
                        style:
                            const TextStyle(fontSize: 14, color: subtitleText),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _brushingReminders,
                  onChanged: (v) => _setBrushingReminders(v),
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
            child: Text(
              AppLocalizations.of(context)!.done,
              style: const TextStyle(
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
