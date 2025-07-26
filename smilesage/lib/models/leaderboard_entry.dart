class LeaderboardEntry {
  final String userId;
  final String displayName;
  final int currentStreak;
  final String? profileImage;
  final DateTime lastUpdated;
  final int rank;

  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.currentStreak,
    this.profileImage,
    required this.lastUpdated,
    required this.rank,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'currentStreak': currentStreak,
        'profileImage': profileImage,
        'lastUpdated': lastUpdated.toIso8601String(),
        'rank': rank,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        userId: json['userId'] as String,
        displayName: json['displayName'] as String,
        currentStreak: json['currentStreak'] as int,
        profileImage: json['profileImage'] as String?,
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
        rank: json['rank'] as int,
      );

  @override
  String toString() {
    return 'LeaderboardEntry(userId: $userId, displayName: $displayName, currentStreak: $currentStreak, rank: $rank)';
  }
}
