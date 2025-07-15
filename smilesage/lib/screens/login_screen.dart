import 'package:flutter/material.dart';
import 'sign_up_screen.dart';
import '../services/auth_service.dart';
import 'permissions_screen.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      setState(() => _emailError = AppLocalizations.of(context)!.emailRequired);
      hasError = true;
    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(email)) {
      setState(
          () => _emailError = AppLocalizations.of(context)!.enterValidEmail);
      hasError = true;
    }
    if (password.isEmpty) {
      setState(() =>
          _passwordError = AppLocalizations.of(context)!.passwordRequired);
      hasError = true;
    }
    if (hasError) {
      setState(() => _loading = false);
      return;
    }
    try {
      final credential = await AuthService().signIn(email, password);
      await ProfileService().syncUserDataFromFirebaseToLocal();
      if (credential.additionalUserInfo?.isNewUser == true) {
        Navigator.of(context).pushReplacementNamed(PermissionsScreen.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    } on FirebaseAuthException catch (e) {
      String message = AppLocalizations.of(context)!.loginFailed;
      if (e.code == 'user-not-found') {
        message = AppLocalizations.of(context)!.noUserFound;
      } else if (e.code == 'wrong-password') {
        message = AppLocalizations.of(context)!.incorrectPassword;
      } else if (e.code == 'invalid-email') {
        message = AppLocalizations.of(context)!.invalidEmail;
      } else if (e.code == 'user-disabled') {
        message = AppLocalizations.of(context)!.userDisabled;
      }
      _showError(context, message);
    } catch (e) {
      _showError(context, AppLocalizations.of(context)!.unexpectedError);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _loading = true);
    try {
      final credential = await AuthService().signInWithGoogle();
      await ProfileService().syncUserDataFromFirebaseToLocal();
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
              title: Text(AppLocalizations.of(context)!.resetPassword),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email,
                      errorText: errorText,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      setState(() => errorText =
                          AppLocalizations.of(context)!.emailRequired);
                      return;
                    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+')
                        .hasMatch(email)) {
                      setState(() => errorText =
                          AppLocalizations.of(context)!.enterValidEmail);
                      return;
                    }
                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: email);
                      Navigator.of(context).pop();
                      _showError(context,
                          AppLocalizations.of(context)!.passwordResetSent);
                    } on FirebaseAuthException catch (e) {
                      String message =
                          AppLocalizations.of(context)!.failedToSendReset;
                      if (e.code == 'user-not-found') {
                        message = AppLocalizations.of(context)!.noUserFound;
                      } else if (e.code == 'invalid-email') {
                        message = AppLocalizations.of(context)!.invalidEmail;
                      }
                      setState(() => errorText = message);
                    } catch (e) {
                      setState(() => errorText =
                          AppLocalizations.of(context)!.unexpectedError);
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.send),
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
        title: Text(
          AppLocalizations.of(context)!.login,
          style: const TextStyle(
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
                    Text(
                      AppLocalizations.of(context)!.welcomeBack,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // Email
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.email,
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
                        hintText: AppLocalizations.of(context)!.password,
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
                          AppLocalizations.of(context)!.forgotPassword,
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
                            : Text(
                                AppLocalizations.of(context)!.login,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: navyText,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Center(
                        child:
                            Text(AppLocalizations.of(context)!.orSignInWith)),
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
                        label: Text(
                          AppLocalizations.of(context)!.signIn,
                          style: const TextStyle(
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
                          AppLocalizations.of(context)!.dontHaveAccount +
                              ' ' +
                              AppLocalizations.of(context)!.signUp,
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
