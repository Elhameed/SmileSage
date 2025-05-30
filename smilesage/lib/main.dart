import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/start_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/login_screen.dart';
import 'screens/permissions_screen.dart';

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
        // (optionally customize colors, button themes, etc. here)
      ),

      initialRoute: StartScreen.routeName,
      routes: {
        StartScreen.routeName: (_) => const StartScreen(),
        WelcomeScreen.routeName: (_) => const WelcomeScreen(),
        SignUpScreen.routeName: (_) => const SignUpScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        PermissionsScreen.routeName: (_) => const PermissionsScreen(),
      },
    );
  }
}
