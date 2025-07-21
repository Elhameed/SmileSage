import 'package:flutter/material.dart';
import 'tips_screen.dart';
import 'scan_workflow_screen.dart';
import 'clinics_screen.dart';
import 'learn_screen.dart';
import 'profile_screen.dart';
import 'reminders_screen.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/brushing_log.dart';
import '../models/scan_result.dart';
import 'scan_history_screen.dart';
import '../models/clinic.dart';
import '../services/clinic_service.dart';
import 'clinic_detail_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/widgets.dart';
import 'scan_detail_screen.dart';
import '../services/profile_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/translation_service.dart';
import 'dart:async';

// Add a global RouteObserver in main.dart and import it here
import '../main.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  final void Function(Locale) onLocaleChanged;
  final Locale currentLocale;
  const HomeScreen(
      {Key? key, required this.onLocaleChanged, required this.currentLocale})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  // Tracks which bottom nav item is selected; Home = 0
  int _selectedIndex = 0;
  late Locale _selectedLocale;

  String? _profileImageBase64;
  int _brushingStreak = 0;
  bool _loadingStreak = true;
  List<ScanResult> _recentScans = [];
  bool _loadingScans = true;
  List<Map<String, String>> _dailyTips = [];
  bool _loadingTips = true;
  Clinic? _nearestClinic;
  bool _loadingClinic = true;
  int _brushingThisWeek = 0;
  final int _brushingGoal = 7;
  int _scansThisMonth = 0;
  final int _scanGoal = 4;

  // Add for tip carousel
  late final PageController _tipPageController;
  int _currentTipPage = 0;
  Timer? _tipAutoPageTimer;

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.currentLocale;
    _initializeProfile();
    _loadProfileImage();
    _loadBrushingStreak();
    _loadRecentScans();
    _loadDailyTips();
    _loadNearestClinic();
    _tipPageController = PageController();
    _startTipAutoPageTimer();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tipAutoPageTimer?.cancel();
    _tipPageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register this screen as a route observer
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    // Called when coming back to this screen
    _loadRecentScans();
    super.didPopNext();
  }

  Future<void> _initializeProfile() async {
    try {
      final profileService = ProfileService();
      await profileService.initializeProfile();
    } catch (e) {
      print('Error initializing profile: $e');
    }
  }

  void _startTipAutoPageTimer() {
    _tipAutoPageTimer?.cancel();
    _tipAutoPageTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
      if (_dailyTips.isEmpty) return;
      int nextPage = (_currentTipPage + 1) % _dailyTips.length;
      _tipPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageBase64 = prefs.getString('profile_image');
    });
  }

  Future<void> _loadBrushingStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('brushing_logs');
    List<BrushingLog> logs = [];
    if (jsonString != null) {
      logs = BrushingLog.listFromJson(jsonString);
      logs.sort((a, b) => b.date.compareTo(a.date));
    }
    int streak = _calculateStreak(logs);
    _calculateWeeklyBrushing(logs);
    setState(() {
      _brushingStreak = streak;
      _loadingStreak = false;
    });
  }

  void _calculateWeeklyBrushing(List<BrushingLog> logs) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final brushedDays = logs
        .where((log) =>
            log.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            log.date.isBefore(endOfWeek.add(const Duration(days: 1))))
        .map((log) => DateTime(log.date.year, log.date.month, log.date.day))
        .toSet()
        .length;
    setState(() {
      _brushingThisWeek = brushedDays;
    });
  }

  Future<void> _loadRecentScans() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList('scan_history') ?? [];
    final localScans = historyList
        .map((item) => ScanResult.fromJson(jsonDecode(item)))
        .toList();

    List<ScanResult> cloudScans = [];
    try {
      cloudScans = await ProfileService().fetchCloudScans();
    } catch (e) {
      // If not logged in or offline, ignore
    }

    // Merge, avoiding duplicates (by timestamp)
    final allScans = <String, ScanResult>{};
    for (final scan in [...localScans, ...cloudScans]) {
      allScans[scan.timestamp.toIso8601String()] = scan;
    }
    final allScanList = allScans.values.toList();
    _calculateMonthlyScans(allScanList);
    setState(() {
      _recentScans = allScanList.reversed.take(3).toList();
      _loadingScans = false;
    });
  }

  void _calculateMonthlyScans(List<ScanResult> scans) {
    final now = DateTime.now();
    final scansThisMonth = scans
        .where((scan) =>
            scan.timestamp.year == now.year &&
            scan.timestamp.month == now.month)
        .length;
    setState(() {
      _scansThisMonth = scansThisMonth;
    });
  }

  Future<void> _loadDailyTips() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final cachedTipsString = prefs.getString('cached_daily_tips');
    final cachedDate = prefs.getString('cached_daily_tips_date');
    List<Map<String, String>> tips = [];
    if (cachedDate == todayStr && cachedTipsString != null) {
      try {
        final tipsJson = json.decode(cachedTipsString);
        if (tipsJson is List) {
          for (var tip in tipsJson) {
            if (tip is Map && tip.containsKey('title')) {
              final desc = tip['desc'] ?? tip['description'] ?? '';
              // Try to infer imageKey from English before translation
              String imageKey = '';
              final title = (tip['title'] ?? '').toLowerCase();
              final descLower = desc.toLowerCase();
              if (title.contains('floss') || descLower.contains('floss')) {
                imageKey = 'floss';
              } else if (title.contains('brush') ||
                  descLower.contains('brush')) {
                imageKey = 'brush';
              } else if (title.contains('rinse') ||
                  descLower.contains('rinse')) {
                imageKey = 'rinse';
              }
              tips.add({
                'icon': 'assets/images/icon_braces_care.png',
                'title': tip['title'],
                'desc': desc,
                'imageKey': imageKey,
              });
            }
          }
        }
      } catch (e) {
        // Ignore and use fallback
      }
    }
    if (tips.isEmpty) {
      tips = [
        {
          'icon': 'assets/images/icon_braces_care.png',
          'title': 'Braces Care: Gentle Brushing',
          'desc':
              'Brush gently around brackets and wires to remove plaque and food particles.',
          'imageKey': 'brush',
        },
        {
          'icon': 'assets/images/icon_braces_care.png',
          'title': 'Braces Care: Flossing',
          'desc':
              'Use a floss threader or interdental brush to clean between teeth and under wires.',
          'imageKey': 'floss',
        },
        {
          'icon': 'assets/images/icon_braces_care.png',
          'title': 'Braces Care: Mouthwash',
          'desc':
              'Rinse with fluoride mouthwash to strengthen enamel and prevent cavities.',
          'imageKey': 'rinse',
        },
      ];
    }
    // Translate all tips if needed
    if (tips.isNotEmpty) {
      final lang = Localizations.localeOf(context).languageCode;
      if (lang == 'fr' || lang == 'sw') {
        for (var tip in tips) {
          tip['title'] =
              await TranslationService.translateText(tip['title'] ?? '', lang);
          tip['desc'] =
              await TranslationService.translateText(tip['desc'] ?? '', lang);
        }
      }
    }
    setState(() {
      _dailyTips = tips;
      _loadingTips = false;
    });
  }

  Future<void> _loadNearestClinic() async {
    setState(() => _loadingClinic = true);
    try {
      final clinics = await ClinicService.getNearbyClinics();
      setState(() {
        _nearestClinic = clinics.isNotEmpty ? clinics.first : null;
        _loadingClinic = false;
      });
    } catch (e) {
      setState(() {
        _nearestClinic = null;
        _loadingClinic = false;
      });
    }
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

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _onNavItemTapped(int index) {
    switch (index) {
      case 1:
        Navigator.of(context).pushNamed(TipsScreen.routeName);
        break;
      case 2:
        Navigator.of(context).pushNamed(ScanWorkflowScreen.routeName);
        break;
      case 3:
        Navigator.of(context).pushNamed(ClinicsScreen.routeName);
        break;
      case 4:
        Navigator.of(context).pushNamed(LearnScreen.routeName);
        break;
      default:
        setState(() => _selectedIndex = index);
    }
  }

  // Helper to select tip image based on imageKey
  String _getTipImage(Map<String, String> tip) {
    switch (tip['imageKey']) {
      case 'floss':
        return 'assets/images/flossing.png';
      case 'brush':
        return 'assets/images/brushing.png';
      case 'rinse':
        return 'assets/images/rinsing.png';
      default:
        return 'assets/images/icon_braces_care.png';
    }
  }

  void _onTipPageChanged(int index) {
    setState(() {
      _currentTipPage = index;
    });
    _startTipAutoPageTimer(); // Reset timer on manual swipe
  }

  @override
  Widget build(BuildContext context) {
    // Color constants
    const backgroundWhite = Colors.white;
    const darkText = Color(0xFF0A244E);
    const goldText = Color(0xFFB58E31);
    const primaryGreen = Color(0xFF7CF4A4);
    const lightBeige = Color(0xFFF5F0E6);

    // Get current user and extract first name
    final user = AuthService().currentUser;
    String firstName = 'User';
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        firstName = user.displayName!.split(' ').first;
      } else if (user.email != null && user.email!.isNotEmpty) {
        firstName = user.email!.split('@').first;
      }
    }

    return Scaffold(
      backgroundColor: backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar: Avatar, greeting, notification, language dropdown
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(ProfileScreen.routeName)
                              .then((_) => _loadProfileImage());
                        },
                        child: _profileImageBase64 != null &&
                                _profileImageBase64!.isNotEmpty
                            ? CircleAvatar(
                                radius: 20,
                                backgroundImage: MemoryImage(
                                    base64Decode(_profileImageBase64!)),
                              )
                            : const CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    AssetImage('assets/images/avatar.png'),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.hiUser(firstName),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                      ),
                      // Language dropdown
                      DropdownButton<Locale>(
                        value: _selectedLocale,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.language, color: darkText),
                        items: const [
                          DropdownMenuItem(
                            value: Locale('en'),
                            child: Text('EN'),
                          ),
                          DropdownMenuItem(
                            value: Locale('fr'),
                            child: Text('FR'),
                          ),
                          DropdownMenuItem(
                            value: Locale('sw'),
                            child: Text('SW'),
                          ),
                        ],
                        onChanged: (Locale? newLocale) {
                          if (newLocale != null) {
                            setState(() {
                              _selectedLocale = newLocale;
                            });
                            widget.onLocaleChanged(newLocale);
                          }
                        },
                        style: const TextStyle(
                          color: darkText,
                          fontWeight: FontWeight.bold,
                        ),
                        dropdownColor: Colors.white,
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none,
                            color: darkText),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed(RemindersScreen.routeName);
                        },
                      ),
                    ],
                  ),
                ),

                // Welcome Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    AppLocalizations.of(context)!.keepSmileHealthy,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Brushing Streak Card (refined design, compact)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: Image.asset(
                            'assets/images/brushing_card.png',
                            width: double.infinity,
                            height: 155,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.brushingStreak,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A244E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _brushingStreak > 0
                                    ? AppLocalizations.of(context)!
                                        .keepUpGoodWork
                                    : AppLocalizations.of(context)!
                                        .startBrushingStreak,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF4CAF50), // green
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _brushingStreak > 0
                                          ? AppLocalizations.of(context)!
                                              .nDayStreak(_brushingStreak)
                                          : AppLocalizations.of(context)!
                                              .noStreakYet,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF4CAF50), // green
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed(TipsScreen.routeName);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF7CF4A4),
                                      shape: const StadiumBorder(),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 10),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .trackTodaysBrushing,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Recent Activity Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.recentActivity,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A244E),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ScanHistoryScreen(),
                            ),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.viewAll),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 140,
                  child: _loadingScans
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Row(
                            children: List.generate(
                              3,
                              (index) => Container(
                                margin: EdgeInsets.only(
                                    left: index == 0 ? 24 : 12, right: 0),
                                width: 110,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        )
                      : (_recentScans.isEmpty
                          ? Center(
                              child: Text(
                                AppLocalizations.of(context)!.noScanHistory,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              scrollDirection: Axis.horizontal,
                              itemCount: _recentScans.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final scan = _recentScans[index];
                                final scanNumber = 'Scan Result  ${index + 1}';
                                final scanNumberLocalized =
                                    AppLocalizations.of(context)!
                                        .scanResult((index + 1).toString());
                                final formattedDate =
                                    _formatDate(scan.timestamp);
                                return Container(
                                  width: 130,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ScanDetailScreen(
                                              scanResult: scan),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(14),
                                              topRight: Radius.circular(14),
                                            ),
                                            child: scan.originalImageBase64
                                                    .isNotEmpty
                                                ? Image.memory(
                                                    base64Decode(scan
                                                        .originalImageBase64),
                                                    width: 130,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    width: 130,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                        Icons.image,
                                                        size: 32,
                                                        color: Colors.grey),
                                                  ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                scanNumberLocalized,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color: Color(0xFF0A244E),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                formattedDate,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF8A8A8A),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )),
                ),
                const SizedBox(height: 24),

                // Today's Tip Section Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    AppLocalizations.of(context)!.todaysTip,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A244E),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Today's Tip Card (carousel)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _loadingTips
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 120),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        )
                      : (_dailyTips.isEmpty
                          ? Container(
                              constraints: const BoxConstraints(minHeight: 120),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(AppLocalizations.of(context)!
                                    .noScanHistory),
                              ),
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  height: 185,
                                  child: PageView.builder(
                                    controller: _tipPageController,
                                    itemCount: _dailyTips.length,
                                    onPageChanged: _onTipPageChanged,
                                    itemBuilder: (context, index) {
                                      final tip = _dailyTips[index];
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Tip text
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                      vertical: 16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    tip['title'] ?? '',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Color(0xFF0A244E),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    tip['desc'] ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF4CAF50),
                                                    ),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 14),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pushNamed(TipsScreen
                                                              .routeName);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Color(0xFFE8F2E8),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20,
                                                          vertical: 10),
                                                      elevation: 0,
                                                    ),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .readMore,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: darkText,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Tip image
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              child: Image.asset(
                                                _getTipImage(tip),
                                                width: 90,
                                                height: 90,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                // Page indicator dots
                                if (_dailyTips.length > 1)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        _dailyTips.length,
                                        (index) => AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          width:
                                              _currentTipPage == index ? 16 : 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _currentTipPage == index
                                                ? Color(0xFF7CF4A4)
                                                : Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )),
                ),
                const SizedBox(height: 24),

                // Clinics Near Me Section Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    AppLocalizations.of(context)!.clinicsNearMe,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A244E),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Clinics Near Me Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _loadingClinic
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 100),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        )
                      : Container(
                          constraints: const BoxConstraints(minHeight: 100),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _nearestClinic == null
                              ? Center(
                                  child: Text(AppLocalizations.of(context)!
                                      .noClinicsNearby))
                              : Row(
                                  children: [
                                    // Clinic info
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _nearestClinic!.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFF0A244E),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _nearestClinic!.address,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF4CAF50),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 14),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        ClinicDetailScreen(
                                                            clinic:
                                                                _nearestClinic!),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xFFE8F2E8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                elevation: 0,
                                              ),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .viewDetails,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF0A244E),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Clinic image
                                    if (_nearestClinic!.imagePath != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: _nearestClinic!.imagePath!
                                                  .startsWith('http')
                                              ? Image.network(
                                                  _nearestClinic!.imagePath!,
                                                  width: 90,
                                                  height: 90,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Container(
                                                    width: 90,
                                                    height: 90,
                                                    color: Color(0xFFE8F4EC),
                                                    child: const Icon(
                                                        Icons.local_hospital,
                                                        color:
                                                            Color(0xFF7CA78C),
                                                        size: 40),
                                                  ),
                                                )
                                              : Image.asset(
                                                  _nearestClinic!.imagePath!,
                                                  width: 90,
                                                  height: 90,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                ),
                const SizedBox(height: 24),

                // Progress Summary Section Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    AppLocalizations.of(context)!.progressSummary,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A244E),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Progress Summary Cards (dynamic)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Color(0xFFB7E2C2), width: 1.2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.weeklyGoal,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0A244E),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12),
                              Text(
                                '${((_brushingThisWeek / _brushingGoal) * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A244E),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '${_brushingThisWeek} of $_brushingGoal days brushed',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          margin: const EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Color(0xFFB7E2C2), width: 1.2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.monthlyGoal,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0A244E),
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                '${((_scansThisMonth / _scanGoal) * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A244E),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '${_scansThisMonth} of $_scanGoal scans completed',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),

      // 5) BottomNavigationBar
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
            icon: ImageIcon(const AssetImage('assets/images/icon_home.png')),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(const AssetImage('assets/images/icon_tips.png')),
            label: AppLocalizations.of(context)!.tips,
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(const AssetImage('assets/images/icon_scan.png')),
            label: AppLocalizations.of(context)!.scan,
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(const AssetImage('assets/images/icon_clinics.png')),
            label: AppLocalizations.of(context)!.clinics,
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(const AssetImage('assets/images/icon_learn.png')),
            label: AppLocalizations.of(context)!.learn,
          ),
        ],
      ),
    );
  }
}
