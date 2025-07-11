import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'scan_workflow_screen.dart';
import 'clinics_screen.dart';
import 'learn_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/brushing_log.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/animation.dart';

class TipsScreen extends StatefulWidget {
  static const routeName = '/tips';
  const TipsScreen({Key? key}) : super(key: key);

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1; // Tips tab

  // Brushing log and streak state
  List<BrushingLog> _brushingLogs = [];
  int _currentStreak = 0;
  DateTime? _lastBrushedDate;

  // Daily tips state
  List<Map<String, String>> _tips = [];
  bool _isLoadingTips = false;
  String? _tipsError;

  // Local storage keys
  static const String brushingLogsKey = 'brushing_logs';

  // Gemini proxy API endpoint
  static const String geminiTipsUrl =
      'https://teniola04-gemini-dental-chat.hf.space/chat';

  // Fallback static tips
  final List<Map<String, String>> _staticTips = [
    {
      'icon': 'assets/images/icon_braces_care.png',
      'title': 'Braces Care: Gentle Brushing',
      'desc':
          'Brush gently around brackets and wires to remove plaque and food particles.',
    },
    {
      'icon': 'assets/images/icon_braces_care.png',
      'title': 'Braces Care: Flossing',
      'desc':
          'Use a floss threader or interdental brush to clean between teeth and under wires.',
    },
    {
      'icon': 'assets/images/icon_braces_care.png',
      'title': 'Braces Care: Mouthwash',
      'desc':
          'Rinse with fluoride mouthwash to strengthen enamel and prevent cavities.',
    },
  ];

  bool _isMarkingBrushed = false;

  // Badge milestones
  final List<Map<String, dynamic>> _badges = [
    {'min': 0, 'max': 3, 'label': 'New Kid', 'icon': Icons.emoji_emotions},
    {'min': 4, 'max': 7, 'label': 'Cool Kid', 'icon': Icons.star},
    {'min': 8, 'max': 14, 'label': 'Rising Star', 'icon': Icons.emoji_events},
    {'min': 15, 'max': 30, 'label': 'Streak Pro', 'icon': Icons.military_tech},
    {
      'min': 31,
      'max': 120,
      'label': 'Iron Will',
      'icon': Icons.workspace_premium
    },
    {'min': 121, 'max': 365, 'label': 'Smile Sage', 'icon': Icons.auto_awesome},
  ];

  Map<String, dynamic> get _currentBadge {
    for (final badge in _badges) {
      if (_currentStreak >= badge['min'] && _currentStreak <= badge['max']) {
        return badge;
      }
    }
    return _badges.first;
  }

  bool get _brushedToday {
    if (_lastBrushedDate == null) return false;
    final now = DateTime.now();
    return _lastBrushedDate!.year == now.year &&
        _lastBrushedDate!.month == now.month &&
        _lastBrushedDate!.day == now.day;
  }

  Future<void> saveBrushingLog(BrushingLog log) async {
    final prefs = await SharedPreferences.getInstance();
    _brushingLogs.add(log);
    final jsonString = BrushingLog.listToJson(_brushingLogs);
    await prefs.setString(brushingLogsKey, jsonString);
    setState(() {});
  }

  Future<void> loadBrushingLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(brushingLogsKey);
    if (jsonString != null) {
      _brushingLogs = BrushingLog.listFromJson(jsonString);
      _brushingLogs.sort((a, b) => a.date.compareTo(b.date));
      if (_brushingLogs.isNotEmpty) {
        _lastBrushedDate = _brushingLogs.last.date;
        _currentStreak = _calculateStreak(_brushingLogs);
      } else {
        _lastBrushedDate = null;
        _currentStreak = 0;
      }
    } else {
      _brushingLogs = [];
      _lastBrushedDate = null;
      _currentStreak = 0;
    }
    setState(() {});
  }

  Future<void> clearBrushingLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(brushingLogsKey);
    _brushingLogs = [];
    _lastBrushedDate = null;
    _currentStreak = 0;
    setState(() {});
  }

  int _calculateStreak(List<BrushingLog> logs) {
    if (logs.isEmpty) return 0;
    logs.sort((a, b) => b.date.compareTo(a.date));
    int streak = 1;
    DateTime prev = logs.first.date;
    for (int i = 1; i < logs.length; i++) {
      final diff = prev.difference(logs[i].date).inDays;
      if (diff == 1) {
        streak++;
        prev = logs[i].date;
      } else if (diff > 1) {
        break;
      }
    }
    return streak;
  }

  // --- Daily Tips Caching ---
  static const String dailyTipsCacheKey = 'cached_daily_tips';
  static const String dailyTipsCacheDateKey = 'cached_daily_tips_date';

  Future<void> fetchDailyTips() async {
    setState(() {
      _isLoadingTips = true;
      _tipsError = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final cachedDate = prefs.getString(dailyTipsCacheDateKey);
    final cachedTipsString = prefs.getString(dailyTipsCacheKey);
    if (cachedDate == todayStr && cachedTipsString != null) {
      try {
        final tipsJson = json.decode(cachedTipsString);
        List<Map<String, String>> tips = [];
        if (tipsJson is List) {
          for (var tip in tipsJson) {
            if (tip is Map && tip.containsKey('title')) {
              final desc = tip['desc'] ?? tip['description'] ?? '';
              tips.add({
                'icon': 'assets/images/icon_braces_care.png',
                'title': tip['title'],
                'desc': desc,
              });
            }
          }
        }
        if (tips.isNotEmpty) {
          setState(() {
            _tips = tips;
            _isLoadingTips = false;
          });
          return;
        }
      } catch (e) {
        // Ignore and fall through to fetch
      }
    }
    // If not cached, fetch from API
    try {
      final requestBody = {
        'system_prompt':
            'You are a dental health assistant. Respond with clear, evidence-based answers about oral hygiene, dental diseases, and oral care. If the question is outside this domain, politely explain that you\'re limited to dental topics.',
        'messages': [
          {
            'role': 'user',
            'content':
                'Give me 3 concise, motivational daily dental care tips for braces in JSON array format, each with a title and a sentence description.'
          }
        ]
      };
      final response = await http.post(
        Uri.parse(geminiTipsUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded.containsKey('response')) {
          String tipsString = decoded['response'];
          tipsString = tipsString.trim();
          if (tipsString.startsWith('```')) {
            final firstNewline = tipsString.indexOf('\n');
            if (firstNewline != -1) {
              tipsString = tipsString.substring(firstNewline + 1);
            }
            if (tipsString.endsWith('```')) {
              tipsString = tipsString.substring(0, tipsString.length - 3);
            }
            tipsString = tipsString.trim();
          }
          try {
            final tipsJson = json.decode(tipsString);
            List<Map<String, String>> tips = [];
            if (tipsJson is List) {
              for (var tip in tipsJson) {
                if (tip is Map && tip.containsKey('title')) {
                  final desc = tip['desc'] ?? tip['description'] ?? '';
                  tips.add({
                    'icon': 'assets/images/icon_braces_care.png',
                    'title': tip['title'],
                    'desc': desc,
                  });
                }
              }
            }
            if (tips.isNotEmpty) {
              // Cache the tips for today
              await prefs.setString(dailyTipsCacheKey, json.encode(tipsJson));
              await prefs.setString(dailyTipsCacheDateKey, todayStr);
              setState(() {
                _tips = tips;
                _isLoadingTips = false;
              });
              return;
            }
          } catch (e) {
            // Ignore and fall through to fallback
          }
        }
      }
      // If failed to parse or empty, fallback
      setState(() {
        _tips = _staticTips;
        _isLoadingTips = false;
        _tipsError = 'Could not fetch new tips. Showing static tips.';
      });
    } catch (e) {
      setState(() {
        _tips = _staticTips;
        _isLoadingTips = false;
        _tipsError = 'Could not fetch new tips. Showing static tips.';
      });
    }
  }

  Future<void> _markBrushedToday() async {
    setState(() => _isMarkingBrushed = true);
    final now = DateTime.now();
    final log = BrushingLog(date: DateTime(now.year, now.month, now.day));
    await saveBrushingLog(log);

    // Recalculate streak and update UI state
    _brushingLogs.sort((a, b) => a.date.compareTo(b.date));
    if (_brushingLogs.isNotEmpty) {
      _lastBrushedDate = _brushingLogs.last.date;
      _currentStreak = _calculateStreak(_brushingLogs);
    }

    setState(() {
      _isMarkingBrushed = false;
    });
  }

  // Call this when user views/completes daily tips (e.g., after tips are loaded)
  // Remove points system variables and functions

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
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
      case 1:
        // already here
        break;
    }
    setState(() => _selectedIndex = index);
  }

  void _showBadgeListModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'All Badges',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                ..._badges.map((badge) {
                  final isCurrent = badge['label'] == _currentBadge['label'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isCurrent ? Colors.amber.withOpacity(0.15) : null,
                      borderRadius: BorderRadius.circular(12),
                      border: isCurrent
                          ? Border.all(color: Colors.amber, width: 2)
                          : null,
                    ),
                    child: ListTile(
                      leading: Icon(badge['icon'],
                          color: isCurrent ? Colors.amber : Colors.grey,
                          size: 32),
                      title: Text(
                        badge['label'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Colors.amber[900] : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                          'Streak: ${badge['min']} - ${badge['max']} days'),
                      trailing: isCurrent
                          ? const Icon(Icons.check_circle, color: Colors.amber)
                          : null,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadBrushingLogs();
    fetchDailyTips();
    _loadOptInStatus();
    // Badge animation setup
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _badgeScaleAnimation = Tween<double>(begin: 1.0, end: 1.25)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_badgeController);
    _previousBadge = _currentBadge;
  }

  @override
  void dispose() {
    _badgeController.dispose();
    super.dispose();
  }

  void _checkBadgeAnimation() {
    final current = _currentBadge;
    if (_previousBadge == null ||
        current['label'] != _previousBadge!['label']) {
      _badgeController.forward(from: 0.0);
      _previousBadge = current;
    }
  }

  Widget _buildBrushingTracker() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBadgeAnimation());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Brushing Streak',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                _showBadgeListModal(context);
              },
              child: ScaleTransition(
                scale: _badgeScaleAnimation,
                child:
                    Icon(_currentBadge['icon'], color: Colors.amber, size: 36),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${_currentBadge['label']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 16),
            Text(
              'Streak: $_currentStreak',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentStreak % 7) / 7.0,
          minHeight: 8,
          backgroundColor: Color(0xFFFAFAFA),
          color: Colors.green,
        ),
        const SizedBox(height: 4),
        Text(
          'Keep brushing daily to unlock the next badge!',
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7D82)),
        ),
        const SizedBox(height: 16),
        if (_brushedToday)
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              const Text('You have marked today as brushed!',
                  style: TextStyle(color: Colors.green)),
            ],
          )
        else
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _isMarkingBrushed ? null : _markBrushedToday,
                icon: const Icon(Icons.check),
                label: _isMarkingBrushed
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Mark as Brushed'),
              ),
            ],
          ),
        const SizedBox(height: 12),
        if (!_brushedToday && _currentStreak > 0)
          OutlinedButton.icon(
            onPressed: clearBrushingLogs,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Streak'),
          ),
      ],
    );
  }

  // Remove points system variables and functions

  bool _dailyTipsOptIn = false;
  bool _showOptInBanner = true;
  static const String dailyTipsOptInKey = 'daily_tips_opt_in';

  Future<void> _loadOptInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyTipsOptIn = prefs.getBool(dailyTipsOptInKey) ?? false;
    });
  }

  late AnimationController _badgeController;
  late Animation<double> _badgeScaleAnimation;
  Map<String, dynamic>? _previousBadge;

  @override
  Widget build(BuildContext context) {
    const headingText = Colors.black;
    const bodyText = Color(0xFF000000);
    const subtitleText = Color(0xFF6B7D82);
    const iconBg = Color(0xFFE8F4EC);
    const primaryGreen = Color(0xFF7CF4A4);
    const lightGray = Color(0xFFFAFAFA);
    const backgroundWhite = Colors.white;
    const goldText = Color(0xFFB58E31);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Daily Dental Tips',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_dailyTipsOptIn && _showOptInBanner)
              Dismissible(
                key: const Key('optInBanner'),
                direction: DismissDirection.horizontal,
                onDismissed: (_) => setState(() => _showOptInBanner = false),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active,
                          color: Colors.orange),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Enable Daily Tip Reminders to get motivational dental care tips as notifications!',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/reminders');
                        },
                        child: const Text('Enable'),
                      ),
                    ],
                  ),
                ),
              ),
            // Intro text
            const Text(
              'Here are your personalized tips for today.\nKeep up the great work!',
              style: TextStyle(fontSize: 16, color: bodyText),
            ),
            const SizedBox(height: 24),
            if (_isLoadingTips)
              const Center(child: CircularProgressIndicator()),
            if (_tipsError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _tipsError!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            // Tip items
            ..._tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Image.asset(tip['icon']!, width: 24, height: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: headingText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tip['desc']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: subtitleText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            _buildBrushingTracker(),
            const SizedBox(height: 24),

            // Rewards
            const Text(
              'Rewards',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: headingText,
              ),
            ),
            const SizedBox(height: 16),

            // Badge Unlocked
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_currentBadge['icon'], color: headingText),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Badge Unlocked: ${_currentBadge['label']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: headingText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You unlocked the "${_currentBadge['label']}" badge for your brushing streak! Keep going to reach the next milestone.',
                        style:
                            const TextStyle(fontSize: 14, color: subtitleText),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
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
}
