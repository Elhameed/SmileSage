import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard_service.dart';
import '../services/auth_service.dart';
import 'dart:convert';

class LeaderboardScreen extends StatefulWidget {
  static const routeName = '/leaderboard';
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final AuthService _authService = AuthService();

  List<LeaderboardEntry> _entries = [];
  LeaderboardEntry? _currentUserEntry;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    if (_isRefreshing) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final entries = await _leaderboardService.getTopUsers(limit: 50);
      final currentUserEntry = await _leaderboardService.getUserEntry();

      setState(() {
        _entries = entries;
        _currentUserEntry = currentUserEntry;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshLeaderboard() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadLeaderboard();

    setState(() {
      _isRefreshing = false;
    });
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    IconData badgeIcon;

    switch (rank) {
      case 1:
        badgeColor = Colors.amber;
        badgeIcon = Icons.emoji_events;
        break;
      case 2:
        badgeColor = Colors.grey.shade400;
        badgeIcon = Icons.emoji_events;
        break;
      case 3:
        badgeColor = Colors.orange.shade700;
        badgeIcon = Icons.emoji_events;
        break;
      default:
        badgeColor = Colors.grey.shade300;
        badgeIcon = Icons.star;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        badgeIcon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildRankNumber(int rank) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A244E),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(String? profileImage, String displayName) {
    if (profileImage != null && profileImage.isNotEmpty) {
      try {
        return CircleAvatar(
          radius: 25,
          backgroundImage: MemoryImage(base64Decode(profileImage)),
        );
      } catch (e) {
        // Fallback to initials if image is invalid
      }
    }

    // Fallback to initials
    final initials = displayName.isNotEmpty
        ? displayName.split(' ').take(2).map((n) => n[0]).join('').toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 25,
      backgroundColor: const Color(0xFF7CF4A4),
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0A244E),
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntry(LeaderboardEntry entry, int index) {
    final isCurrentUser = entry.userId == _authService.currentUser?.uid;
    final rank = index + 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFE8F4EC) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: const Color(0xFF7CF4A4), width: 2)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: rank <= 3 ? _buildRankBadge(rank) : _buildRankNumber(rank),
        title: Row(
          children: [
            _buildUserAvatar(entry.profileImage, entry.displayName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A244E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isCurrentUser)
                    const Text(
                      'You',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7CF4A4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF7CF4A4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${entry.currentStreak} ${AppLocalizations.of(context)!.nDayStreak(entry.currentStreak).split(' ').last}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A244E),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentUserCard() {
    if (_currentUserEntry == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.person, color: Colors.grey, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.startBrushingStreak,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A244E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.startBrushingToAppear,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7CF4A4), Color(0xFF5CDB95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7CF4A4).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildUserAvatar(
              _currentUserEntry!.profileImage, _currentUserEntry!.displayName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.yourPosition,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF0A244E).withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '#${_currentUserEntry!.rank}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A244E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currentUserEntry!.currentStreak} ${AppLocalizations.of(context)!.nDayStreak(_currentUserEntry!.currentStreak).split(' ').last}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A244E),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.trending_up,
            color: Color(0xFF0A244E),
            size: 32,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.globalLeaderboard,
          style: const TextStyle(
            color: Color(0xFF0A244E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0A244E)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshLeaderboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshLeaderboard,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7CF4A4)),
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.errorLoadingLeaderboard,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A244E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadLeaderboard,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7CF4A4),
                            foregroundColor: const Color(0xFF0A244E),
                          ),
                          child: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      _buildCurrentUserCard(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.topBrushers,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A244E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _entries.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.leaderboard,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .noLeaderboardData,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0A244E),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .beFirstToStart,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _entries.length,
                                itemBuilder: (context, index) {
                                  return _buildLeaderboardEntry(
                                      _entries[index], index);
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
