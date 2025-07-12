import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'permissions_screen.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/sign-up';
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _agree = false;
  bool _termsViewed = false; // Track if user has viewed terms
  bool _obscure = true; // <-- for visibility toggle
  bool _loading = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Terms and Conditions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Welcome to SmileSage! By using our app, you agree to the following terms:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  '1. **App Purpose**: SmileSage is a dental health companion app that provides educational content, scanning capabilities, and dental care tips. It is not a substitute for professional dental care.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                SizedBox(height: 12),
                Text(
                  '2. **Medical Disclaimer**: The scanning feature and AI-powered analysis are for educational purposes only. Always consult with a qualified dental professional for diagnosis and treatment.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                SizedBox(height: 12),
                Text(
                  '3. **Privacy & Data**: We collect and process your personal information, including dental images, to provide our services. Your data is stored securely and used only for app functionality.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                SizedBox(height: 12),
                Text(
                  '4. **User Responsibilities**: You are responsible for maintaining the accuracy of your information and using the app appropriately. Do not rely solely on app recommendations for medical decisions.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                SizedBox(height: 12),
                Text(
                  '5. **Limitation of Liability**: SmileSage is not liable for any damages arising from the use of our app or reliance on its content.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                SizedBox(height: 12),
                Text(
                  '6. **Updates**: We may update these terms periodically. Continued use of the app constitutes acceptance of updated terms.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                SizedBox(height: 12),
                Text(
                  '7. **Contact**: For questions about these terms, contact us through the app settings.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _termsViewed = true; // Enable checkbox after viewing terms
                });
              },
              child: const Text(
                'I Understand',
                style: TextStyle(
                  color: Color(0xFF7CF4A4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Future<void> _handleSignUp() async {
    setState(() {
      _loading = true;
      _nameError = null;
      _emailError = null;
      _passwordError = null;
    });
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    bool hasError = false;
    if (name.isEmpty) {
      setState(() => _nameError = 'Full name is required');
      hasError = true;
    }
    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      hasError = true;
    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(email)) {
      setState(() => _emailError = 'Enter a valid email address');
      hasError = true;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      hasError = true;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      hasError = true;
    }
    if (!_termsViewed) {
      _showError(context, 'Please view the terms and conditions first.');
      setState(() => _loading = false);
      return;
    }
    if (!_agree) {
      _showError(context, 'You must agree to the terms and conditions.');
      setState(() => _loading = false);
      return;
    }
    if (hasError) {
      setState(() => _loading = false);
      return;
    }
    try {
      final credential = await AuthService().signUp(email, password, name);
      if (credential.additionalUserInfo?.isNewUser == true) {
        Navigator.of(context).pushReplacementNamed(PermissionsScreen.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Sign up failed';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already in use.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      }
      _showError(context, message);
    } catch (e) {
      _showError(context, 'An unexpected error occurred.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _loading = true);
    try {
      final credential = await AuthService().signInWithGoogle();
      if (credential.additionalUserInfo?.isNewUser == true) {
        Navigator.of(context).pushReplacementNamed(PermissionsScreen.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    } catch (e) {
      _showError(context, e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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
          'Get Started',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Full Name
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        hintText: 'Full Name',
                        hintStyle: const TextStyle(fontSize: 14),
                        filled: true,
                        fillColor: inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _nameError,
                      ),
                    ),
                    const SizedBox(height: 24), // increased gap
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
                        errorText: _emailError,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Password with visibility toggle
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
                        errorText: _passwordError,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Terms checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _agree,
                          onChanged: _termsViewed
                              ? (v) => setState(() => _agree = v!)
                              : null,
                          activeColor:
                              _termsViewed ? primaryGreen : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: GestureDetector(
                            onTap: _showTermsAndConditions,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'I agree with the ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'terms and conditions',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: linkText,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (!_termsViewed)
                                    TextSpan(
                                      text: ' (tap to view)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sign Up button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _agree && _termsViewed && !_loading
                            ? _handleSignUp
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          shape: const StadiumBorder(),
                          elevation: 4,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: navyText,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text('or'),
                    const SizedBox(height: 16),

                    // Google sign-up
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _handleGoogleSignUp,
                        icon: Image.asset(
                          'assets/images/google_icon.png',
                          width: 24,
                          height: 24,
                        ),
                        label: const Text(
                          'Sign up with Google',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: navyText,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bottom link
                    GestureDetector(
                      onTap: () => Navigator.of(
                        context,
                      ).pushReplacementNamed(LoginScreen.routeName),
                      child: Text(
                        'Already have an account? Log in',
                        style: TextStyle(color: linkText),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              if (_loading)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
