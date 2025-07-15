import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'permissions_screen.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          title: Text(
            AppLocalizations.of(context)!.termsTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.termsWelcome,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text(
                  '1. ${AppLocalizations.of(context)!.termsPurpose}: ${AppLocalizations.of(context)!.termsPurposeDesc}',
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),
                Text(
                  '2. ${AppLocalizations.of(context)!.termsDisclaimer}: ${AppLocalizations.of(context)!.termsDisclaimerDesc}',
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),
                Text(
                  '3. ${AppLocalizations.of(context)!.termsPrivacy}: ${AppLocalizations.of(context)!.termsPrivacyDesc}',
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),
                Text(
                  '4. ${AppLocalizations.of(context)!.termsResponsibilities}: ${AppLocalizations.of(context)!.termsResponsibilitiesDesc}',
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),
                Text(
                  '5. ${AppLocalizations.of(context)!.termsLiability}: ${AppLocalizations.of(context)!.termsLiabilityDesc}',
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),
                Text(
                  '6. ${AppLocalizations.of(context)!.termsUpdates}: ${AppLocalizations.of(context)!.termsUpdatesDesc}',
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),
                Text(
                  '7. ${AppLocalizations.of(context)!.termsContact}: ${AppLocalizations.of(context)!.termsContactDesc}',
                  style: const TextStyle(fontSize: 13, height: 1.4),
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
              child: Text(
                AppLocalizations.of(context)!.iUnderstand,
                style: const TextStyle(
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
      setState(
          () => _nameError = AppLocalizations.of(context)!.fullNameRequired);
      hasError = true;
    }
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
    } else if (password.length < 6) {
      setState(() =>
          _passwordError = AppLocalizations.of(context)!.passwordMinLength);
      hasError = true;
    }
    if (!_termsViewed) {
      _showError(context, AppLocalizations.of(context)!.pleaseViewTerms);
      setState(() => _loading = false);
      return;
    }
    if (!_agree) {
      _showError(context, AppLocalizations.of(context)!.mustAgreeTerms);
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
      String message = AppLocalizations.of(context)!.signUpFailed;
      if (e.code == 'email-already-in-use') {
        message = AppLocalizations.of(context)!.emailInUse;
      } else if (e.code == 'invalid-email') {
        message = AppLocalizations.of(context)!.invalidEmail;
      } else if (e.code == 'weak-password') {
        message = AppLocalizations.of(context)!.passwordTooWeak;
      }
      _showError(context, message);
    } catch (e) {
      _showError(context, AppLocalizations.of(context)!.unexpectedError);
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
        title: Text(
          AppLocalizations.of(context)!.getStarted,
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
                  children: [
                    const SizedBox(height: 10),
                    // Full Name
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.fullName,
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

                    // Password with visibility toggle
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
                                    text: AppLocalizations.of(context)!
                                        .iAgreeTerms,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
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
                            : Text(
                                AppLocalizations.of(context)!.signUp,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: navyText,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.orSignInWith),
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
                        label: Text(
                          AppLocalizations.of(context)!.signUp,
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
                    GestureDetector(
                      onTap: () => Navigator.of(
                        context,
                      ).pushReplacementNamed(LoginScreen.routeName),
                      child: Text(
                        AppLocalizations.of(context)!.alreadyHaveAccount +
                            ' ' +
                            AppLocalizations.of(context)!.login,
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
