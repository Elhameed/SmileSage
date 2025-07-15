import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/start_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/login_screen.dart';
import 'screens/permissions_screen.dart';
import 'screens/home_screen.dart';
import 'screens/scan_workflow_screen.dart';
import 'screens/general_scan_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/clinics_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/tips_screen.dart';
import 'screens/scan_history_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Maputo'));
  print('tz.local: ' + tz.local.toString());
  print(
      'tz.TZDateTime.now(tz.local): ' + tz.TZDateTime.now(tz.local).toString());
  print('System time: ' + DateTime.now().toString());
  print('TimeZone location: ' +
      DateTime.now().timeZoneName +
      ' / offset: ' +
      DateTime.now().timeZoneOffset.toString());
  await Firebase.initializeApp();

  // Initialize local notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Request permissions (especially for iOS and Android 13+)
  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  runApp(SmileSageRoot());
}

class SmileSageRoot extends StatefulWidget {
  @override
  State<SmileSageRoot> createState() => _SmileSageRootState();
}

class _SmileSageRootState extends State<SmileSageRoot> {
  Locale _locale = const Locale('en');

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DentalApp(
      locale: _locale,
      onLocaleChanged: _setLocale,
    );
  }
}

class DentalApp extends StatelessWidget {
  final Locale locale;
  final void Function(Locale) onLocaleChanged;
  const DentalApp(
      {Key? key, required this.locale, required this.onLocaleChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmileSage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.lexendTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
      ),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      initialRoute: StartScreen.routeName,
      navigatorObservers: [routeObserver],
      routes: {
        StartScreen.routeName: (_) => const StartScreen(),
        WelcomeScreen.routeName: (_) => const WelcomeScreen(),
        SignUpScreen.routeName: (_) => const SignUpScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        PermissionsScreen.routeName: (_) => const PermissionsScreen(),
        HomeScreen.routeName: (_) => HomeScreen(
              onLocaleChanged: onLocaleChanged,
              currentLocale: locale,
            ),
        ScanWorkflowScreen.routeName: (_) => const ScanWorkflowScreen(),
        GeneralScanScreen.routeName: (_) => const GeneralScanScreen(),
        ChatScreen.routeName: (_) => const ChatScreen(),
        RemindersScreen.routeName: (_) => const RemindersScreen(),
        ClinicsScreen.routeName: (_) => const ClinicsScreen(),
        LearnScreen.routeName: (_) => const LearnScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        TipsScreen.routeName: (_) => const TipsScreen(),
        ScanHistoryScreen.routeName: (_) => const ScanHistoryScreen(),
      },
    );
  }
}
