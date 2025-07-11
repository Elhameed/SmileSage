import 'package:flutter/material.dart';
import 'sign_up_screen.dart';
import '../services/auth_service.dart';
import 'permissions_screen.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool _loading = false;
  String? _emailError;
  String? _passwordError;

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _emailError = null;
      _passwordError = null;
    });
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    bool hasError = false;
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
    }
    if (hasError) {
      setState(() => _loading = false);
      return;
    }
    try {
      final credential = await AuthService().signIn(email, password);
      if (credential.additionalUserInfo?.isNewUser == true) {
        Navigator.of(context).pushReplacementNamed(PermissionsScreen.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'user-disabled') {
        message = 'This user has been disabled.';
      }
      _showError(context, message);
    } catch (e) {
      _showError(context, 'An unexpected error occurred.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
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

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    String? errorText;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: errorText,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      setState(() => errorText = 'Email is required');
                      return;
                    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+')
                        .hasMatch(email)) {
                      setState(() => errorText = 'Enter a valid email address');
                      return;
                    }
                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: email);
                      Navigator.of(context).pop();
                      _showError(context,
                          'Password reset email sent! Check your inbox.');
                    } on FirebaseAuthException catch (e) {
                      String message = 'Failed to send reset email.';
                      if (e.code == 'user-not-found') {
                        message = 'No user found for that email.';
                      } else if (e.code == 'invalid-email') {
                        message = 'Invalid email address.';
                      }
                      setState(() => errorText = message);
                    } catch (e) {
                      setState(
                          () => errorText = 'An unexpected error occurred.');
                    }
                  },
                  child: const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32), // extra breathing room
                    // Welcome text
                    const Text(
                      'Welcome back',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                        errorText: _emailError,
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
                        errorText: _passwordError,
                      ),
                    ),

                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
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
                        onPressed: _loading ? null : _handleLogin,
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
                        onPressed: _loading ? null : _handleGoogleLogin,
                        icon: Image.asset(
                          'assets/images/google_icon.png',
                          width: 24,
                          height: 24,
                        ),
                        label: const Text(
                          'Continue with Google',
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
