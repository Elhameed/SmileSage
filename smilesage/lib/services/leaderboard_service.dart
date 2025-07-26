import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collectionName = 'leaderboard';
  static const String _documentName = 'global';

  /// Get current user's UID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Update user's streak in the global leaderboard
  Future<void> updateUserStreak({
    required int streak,
    required String displayName,
    String? profileImage,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    final userId = currentUserId!;
    final now = DateTime.now();

    try {
      // Get current leaderboard
      final leaderboardDoc =
          await _firestore.collection(_collectionName).doc(_documentName).get();

      List<LeaderboardEntry> entries = [];

      if (leaderboardDoc.exists) {
        final data = leaderboardDoc.data();
        if (data != null && data['entries'] != null) {
          final entriesJson = data['entries'] as List<dynamic>;
          entries = entriesJson
              .map((e) =>
                  LeaderboardEntry.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      // Find existing user entry or create new one
      int existingIndex = entries.indexWhere((entry) => entry.userId == userId);

      if (existingIndex != -1) {
        // Update existing entry
        entries[existingIndex] = LeaderboardEntry(
          userId: userId,
          displayName: displayName,
          currentStreak: streak,
          profileImage: profileImage,
          lastUpdated: now,
          rank: entries[existingIndex].rank, // Will be updated after sorting
        );
      } else {
        // Add new entry
        entries.add(LeaderboardEntry(
          userId: userId,
          displayName: displayName,
          currentStreak: streak,
          profileImage: profileImage,
          lastUpdated: now,
          rank: 0, // Will be updated after sorting
        ));
      }

      // Sort by streak (descending) and update ranks
      entries.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));

      // Update ranks
      for (int i = 0; i < entries.length; i++) {
        entries[i] = LeaderboardEntry(
          userId: entries[i].userId,
          displayName: entries[i].displayName,
          currentStreak: entries[i].currentStreak,
          profileImage: entries[i].profileImage,
          lastUpdated: entries[i].lastUpdated,
          rank: i + 1,
        );
      }

      // Keep only top 100 users to maintain performance
      if (entries.length > 100) {
        entries = entries.take(100).toList();
      }

      // Save updated leaderboard
      await _firestore.collection(_collectionName).doc(_documentName).set({
        'entries': entries.map((e) => e.toJson()).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update leaderboard: $e');
    }
  }

  /// Fetch top users from the leaderboard
  Future<List<LeaderboardEntry>> getTopUsers({int limit = 50}) async {
    try {
      final leaderboardDoc =
          await _firestore.collection(_collectionName).doc(_documentName).get();

      if (!leaderboardDoc.exists) {
        return [];
      }

      final data = leaderboardDoc.data();
      if (data == null || data['entries'] == null) {
        return [];
      }

      final entriesJson = data['entries'] as List<dynamic>;
      final entries = entriesJson
          .map((e) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Return limited number of entries
      return entries.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to fetch leaderboard: $e');
    }
  }

  /// Get current user's rank in the leaderboard
  Future<int?> getUserRank() async {
    if (!isAuthenticated) {
      return null;
    }

    try {
      final entries = await getTopUsers(limit: 1000); // Get all entries
      final userEntry = entries.firstWhere(
        (entry) => entry.userId == currentUserId,
        orElse: () => LeaderboardEntry(
          userId: '',
          displayName: '',
          currentStreak: 0,
          lastUpdated: DateTime.now(),
          rank: 0,
        ),
      );

      return userEntry.userId.isNotEmpty ? userEntry.rank : null;
    } catch (e) {
      print('Error getting user rank: $e');
      return null;
    }
  }

  /// Get current user's leaderboard entry
  Future<LeaderboardEntry?> getUserEntry() async {
    if (!isAuthenticated) {
      return null;
    }

    try {
      final entries = await getTopUsers(limit: 1000); // Get all entries
      final userEntry = entries.firstWhere(
        (entry) => entry.userId == currentUserId,
        orElse: () => LeaderboardEntry(
          userId: '',
          displayName: '',
          currentStreak: 0,
          lastUpdated: DateTime.now(),
          rank: 0,
        ),
      );

      return userEntry.userId.isNotEmpty ? userEntry : null;
    } catch (e) {
      print('Error getting user entry: $e');
      return null;
    }
  }

  /// Remove user from leaderboard (when streak is 0 or user opts out)
  Future<void> removeUserFromLeaderboard() async {
    if (!isAuthenticated) {
      return;
    }

    final userId = currentUserId!;

    try {
      final leaderboardDoc =
          await _firestore.collection(_collectionName).doc(_documentName).get();

      if (!leaderboardDoc.exists) {
        return;
      }

      final data = leaderboardDoc.data();
      if (data == null || data['entries'] == null) {
        return;
      }

      final entriesJson = data['entries'] as List<dynamic>;
      List<LeaderboardEntry> entries = entriesJson
          .map((e) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Remove user entry
      entries.removeWhere((entry) => entry.userId == userId);

      // Re-sort and update ranks
      entries.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));

      for (int i = 0; i < entries.length; i++) {
        entries[i] = LeaderboardEntry(
          userId: entries[i].userId,
          displayName: entries[i].displayName,
          currentStreak: entries[i].currentStreak,
          profileImage: entries[i].profileImage,
          lastUpdated: entries[i].lastUpdated,
          rank: i + 1,
        );
      }

      // Save updated leaderboard
      await _firestore.collection(_collectionName).doc(_documentName).set({
        'entries': entries.map((e) => e.toJson()).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error removing user from leaderboard: $e');
    }
  }
}
