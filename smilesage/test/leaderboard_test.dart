import 'package:flutter_test/flutter_test.dart';
import 'package:smilesage/models/leaderboard_entry.dart';

void main() {
  group('LeaderboardEntry Model', () {
    test('should create LeaderboardEntry from JSON', () {
      final json = {
        'userId': 'user123',
        'displayName': 'John Doe',
        'currentStreak': 15,
        'profileImage': 'base64image',
        'lastUpdated': '2024-01-01T00:00:00.000Z',
        'rank': 5,
      };

      final entry = LeaderboardEntry.fromJson(json);

      expect(entry.userId, 'user123');
      expect(entry.displayName, 'John Doe');
      expect(entry.currentStreak, 15);
      expect(entry.profileImage, 'base64image');
      expect(entry.rank, 5);
    });

    test('should convert LeaderboardEntry to JSON', () {
      final entry = LeaderboardEntry(
        userId: 'user123',
        displayName: 'John Doe',
        currentStreak: 15,
        profileImage: 'base64image',
        lastUpdated: DateTime(2024, 1, 1),
        rank: 5,
      );

      final json = entry.toJson();

      expect(json['userId'], 'user123');
      expect(json['displayName'], 'John Doe');
      expect(json['currentStreak'], 15);
      expect(json['profileImage'], 'base64image');
      expect(json['rank'], 5);
    });

    test('should handle null profileImage', () {
      final entry = LeaderboardEntry(
        userId: 'user123',
        displayName: 'John Doe',
        currentStreak: 15,
        profileImage: null,
        lastUpdated: DateTime(2024, 1, 1),
        rank: 5,
      );

      final json = entry.toJson();
      final fromJson = LeaderboardEntry.fromJson(json);

      expect(fromJson.profileImage, isNull);
      expect(fromJson.userId, 'user123');
    });
  });
}
