import 'package:shared_preferences/shared_preferences.dart';

class LocalDataService {
  static Future<void> clearUserLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    // List all user-specific keys here
    final keysToRemove = [
      'profile_image',
      'user_age',
      'daily_tips_opt_in',
      'brushing_opt_in',
      'user_has_braces',
      'scan_history',
      'brushing_logs',
      'cached_daily_tips',
      'cached_daily_tips_date',
      // Add any other user-specific keys here
    ];
    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }
}
