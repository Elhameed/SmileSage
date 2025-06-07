import 'package:flutter/material.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const inputFill = Color(0xFFE8F4EC);
    const primaryGreen = Color(0xFF7CF4A4);
    const navyText = Color(0xFF0A244E);
    const linkText = Color(0xFF7CA78C);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Login',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32), // extra breathing room
            // Welcome text
            const Text(
              'Welcome back',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Email
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email Address',
                hintStyle: const TextStyle(fontSize: 14),
                filled: true,
                fillColor: inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Password
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: const TextStyle(fontSize: 14),
                filled: true,
                fillColor: inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Forgot password flow
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: linkText),
                ),
              ),
            ),

            const SizedBox(height: 24),
            // Login button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: login logic
                  Navigator.of(context).pushNamed('/permissions');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: const StadiumBorder(),
                  elevation: 4,
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: navyText,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Center(child: Text('Or')),
            const SizedBox(height: 16),

            // Google Continue
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Google login
                },
                icon: Image.asset(
                  'assets/images/google_icon.png',
                  width: 24,
                  height: 24,
                ),
                label: const Text(
                  'Continue with Google',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
              ),
            ),

            const Spacer(),

            // Bottom link
            Center(
              child: GestureDetector(
                onTap: () => Navigator.of(
                  context,
                ).pushReplacementNamed(SignUpScreen.routeName),
                child: Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(color: linkText),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
