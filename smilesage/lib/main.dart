import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'screens/scan_detail_screen.dart';

void main() => runApp(const DentalApp());

class DentalApp extends StatelessWidget {
  const DentalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmileSage',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        textTheme: GoogleFonts.lexendTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
      ),

      initialRoute: StartScreen.routeName,
      routes: {
        StartScreen.routeName: (_) => const StartScreen(),
        WelcomeScreen.routeName: (_) => const WelcomeScreen(),
        SignUpScreen.routeName: (_) => const SignUpScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        PermissionsScreen.routeName: (_) => const PermissionsScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        ScanWorkflowScreen.routeName: (_) => const ScanWorkflowScreen(),
        GeneralScanScreen.routeName: (_) => const GeneralScanScreen(),
        ChatScreen.routeName: (_) => const ChatScreen(),
        RemindersScreen.routeName: (_) => const RemindersScreen(),
        ClinicsScreen.routeName: (_) => const ClinicsScreen(),
        LearnScreen.routeName: (_) => const LearnScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        TipsScreen.routeName: (_) => const TipsScreen(),
        ScanHistoryScreen.routeName: (_) => const ScanHistoryScreen(),
        ScanDetailScreen.routeName: (_) => const ScanDetailScreen(),
      },
    );
  }
}
