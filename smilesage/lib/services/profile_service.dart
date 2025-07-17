import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_result.dart';
import '../models/brushing_log.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection name for user profiles
  static const String _collectionName = 'users';

  /// Get current user's UID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Create or update user profile in Firestore
  Future<void> updateProfile({
    String? displayName,
    String? age,
    String? profileImageBase64,
    Map<String, dynamic>? preferences,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    final userId = currentUserId!;
    final userData = <String, dynamic>{};

    // Add fields only if they are provided
    if (displayName != null) {
      userData['displayName'] = displayName;
    }
    if (age != null) {
      userData['age'] = age;
    }
    if (profileImageBase64 != null) {
      userData['profileImageBase64'] = profileImageBase64;
    }
    if (preferences != null) {
      userData['preferences'] = preferences;
    }

    // Add timestamp
    userData['lastUpdated'] = FieldValue.serverTimestamp();

    try {
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Get user profile from Firestore
  Future<Map<String, dynamic>?> getProfile() async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final doc =
          await _firestore.collection(_collectionName).doc(currentUserId).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  /// Update user display name in Firebase Auth and Firestore
  Future<void> updateDisplayName(String displayName) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      // Update Firebase Auth display name
      await _auth.currentUser?.updateDisplayName(displayName);

      // Update Firestore
      await updateProfile(displayName: displayName);
    } catch (e) {
      throw Exception('Failed to update display name: $e');
    }
  }

  /// Update user age in Firestore
  Future<void> updateAge(String age) async {
    await updateProfile(age: age);
  }

  /// Update profile image in Firestore
  Future<void> updateProfileImage(String profileImageBase64) async {
    await updateProfile(profileImageBase64: profileImageBase64);
  }

  /// Update user preferences in Firestore
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    await updateProfile(preferences: preferences);
  }

  /// Upload profile image to Firebase Storage and get download URL
  Future<String> uploadProfileImageToStorage(Uint8List imageBytes) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final userId = currentUserId!;
      final ref = _storage.ref().child('profile_images/$userId.jpg');

      await ref.putData(imageBytes);
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Sync local preferences with Firestore
  Future<void> syncPreferences({
    bool? dailyTips,
    bool? brushingReminders,
    bool? hasBraces,
  }) async {
    final preferences = <String, dynamic>{};

    if (dailyTips != null) {
      preferences['dailyTips'] = dailyTips;
    }
    if (brushingReminders != null) {
      preferences['brushingReminders'] = brushingReminders;
    }
    if (hasBraces != null) {
      preferences['hasBraces'] = hasBraces;
    }

    await updatePreferences(preferences);
  }

  /// Get user preferences from Firestore
  Future<Map<String, dynamic>> getPreferences() async {
    final profile = await getProfile();
    return profile?['preferences'] ?? {};
  }

  /// Sync user profile and preferences from Firestore to local cache
  Future<void> syncUserDataFromFirebaseToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final profile = await getProfile();
    if (profile == null) return;
    // Profile image
    if (profile['profileImageBase64'] != null) {
      await prefs.setString('profile_image', profile['profileImageBase64']);
    }
    // Name and age
    if (profile['age'] != null) {
      await prefs.setString('user_age', profile['age']);
    }
    // Preferences
    final preferences = profile['preferences'] ?? {};
    if (preferences['dailyTips'] != null) {
      await prefs.setBool('daily_tips_opt_in', preferences['dailyTips']);
    }
    if (preferences['brushingReminders'] != null) {
      await prefs.setBool('brushing_opt_in', preferences['brushingReminders']);
    }
    if (preferences['hasBraces'] != null) {
      await prefs.setBool('user_has_braces', preferences['hasBraces']);
    }
  }

  /// Initialize user profile in Firestore (called after first login)
  Future<void> initializeProfile() async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    final user = _auth.currentUser!;
    final profile = await getProfile();

    // Only initialize if profile doesn't exist
    if (profile == null) {
      await updateProfile(
        displayName: user.displayName ?? '',
        age: '',
        preferences: {
          'dailyTips': false,
          'brushingReminders': false,
          'hasBraces': false,
        },
      );
    }
  }

  /// Delete user profile (for account deletion)
  Future<void> deleteProfile() async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final userId = currentUserId!;

      // Delete from Firestore
      await _firestore.collection(_collectionName).doc(userId).delete();

      // Delete profile image from Storage
      try {
        final ref = _storage.ref().child('profile_images/$userId.jpg');
        await ref.delete();
      } catch (e) {
        // Profile image might not exist, ignore error
        print('Profile image not found or already deleted: $e');
      }
    } catch (e) {
      throw Exception('Failed to delete profile: $e');
    }
  }

  /// Save scan metadata to Firestore (called after user consents to cloud save)
  Future<void> saveScanMetadataToCloud(ScanResult scan) async {
    if (!isAuthenticated) throw Exception('User not authenticated');
    final userId = currentUserId!;
    final scanId = scan.timestamp.toIso8601String();
    final scanData = scan.toJson();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('scan_reports')
        .doc(scanId)
        .set(scanData);
  }

  /// Fetch all cloud scans for the current user
  Future<List<ScanResult>> fetchCloudScans() async {
    if (!isAuthenticated) throw Exception('User not authenticated');
    final userId = currentUserId!;
    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('scan_reports')
        .get();
    return query.docs.map((doc) => ScanResult.fromJson(doc.data())).toList();
  }

  /// Save brushing logs to Firestore (for streak sync)
  Future<void> saveBrushingLogsToCloud(List<BrushingLog> logs) async {
    if (!isAuthenticated) throw Exception('User not authenticated');
    final userId = currentUserId!;
    final logsJson = logs.map((log) => log.toJson()).toList();
    await _firestore.collection('users').doc(userId).set({
      'brushingLogs': logsJson,
    }, SetOptions(merge: true));
  }

  /// Fetch brushing logs from Firestore
  Future<List<BrushingLog>> fetchBrushingLogsFromCloud() async {
    if (!isAuthenticated) throw Exception('User not authenticated');
    final userId = currentUserId!;
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();
    if (data == null || data['brushingLogs'] == null) return [];
    final logsJson = data['brushingLogs'] as List<dynamic>;
    return logsJson
        .map((e) => BrushingLog.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Delete a scan from Firestore for the current user by scan timestamp
  Future<void> deleteScanFromCloud(DateTime timestamp) async {
    if (!isAuthenticated) throw Exception('User not authenticated');
    final userId = currentUserId!;
    final scanId = timestamp.toIso8601String();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('scan_reports')
        .doc(scanId)
        .delete();
  }
}
