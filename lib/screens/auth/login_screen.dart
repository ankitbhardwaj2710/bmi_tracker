import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'auth_gate.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showMessage('Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      _showMessage('Login successful');

      await Future.delayed(
        const Duration(milliseconds: 400),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthGate(),
        ),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showMessage(
        e.message ?? 'Login failed',
      );
    } catch (e) {
      debugPrint('Login Error: $e');

      _showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _googleLogin() async {
    setState(() => _isLoading = true);

    try {
      final credential =
          await _authService.signInWithGoogle();

      debugPrint(
        'Google Login UID: ${credential.user?.uid}',
      );

      if (!mounted) return;

      _showMessage(
        'Google login successful',
      );

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthGate(),
        ),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Firebase Google Auth Error: ${e.code}',
      );

      debugPrint(
        'Firebase Google Auth Message: ${e.message}',
      );

      if (!mounted) return;

      _showMessage(
        e.message ?? 'Google Sign-In failed',
      );
    } catch (e) {
      debugPrint(
        'Google Sign-In Error: $e',
      );

      if (!mounted) return;

      _showMessage(
        'Google Sign-In failed. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24,
              32,
              24,
              24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  // -----------------------------------
                  // LOGO
                  // -----------------------------------

                  Center(
                    child: Container(
                      height: 92,
                      width: 92,
                      decoration: BoxDecoration(
                        color:
                            colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons
                            .monitor_weight_outlined,
                        size: 48,
                        color:
                            colors.onPrimaryContainer,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'BMI Tracker',
                    textAlign: TextAlign.center,
                    style: theme
                        .textTheme
                        .headlineLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Track your health,\none step at a time.',
                    textAlign: TextAlign.center,
                    style: theme
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                          color: colors
                              .onSurfaceVariant,
                          height: 1.4,
                        ),
                  ),

                  const SizedBox(height: 36),

                  // -----------------------------------
                  // EMAIL
                  // -----------------------------------

                  Text(
                    'Email address',
                    style: theme
                        .textTheme
                        .labelLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w600,
                        ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller:
                        _emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    textInputAction:
                        TextInputAction.next,
                    decoration:
                        InputDecoration(
                      hintText:
                          'Enter your email',
                      prefixIcon: const Icon(
                        Icons
                            .email_outlined,
                      ),
                      filled: true,
                      fillColor:
                          colors.surfaceContainerHighest,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            BorderSide(
                          color:
                              colors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // -----------------------------------
                  // PASSWORD
                  // -----------------------------------

                  Text(
                    'Password',
                    style: theme
                        .textTheme
                        .labelLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w600,
                        ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller:
                        _passwordController,
                    obscureText:
                        _obscurePassword,
                    textInputAction:
                        TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _login();
                      }
                    },
                    decoration:
                        InputDecoration(
                      hintText:
                          'Enter your password',
                      prefixIcon: const Icon(
                        Icons
                            .lock_outline_rounded,
                      ),
                      suffixIcon:
                          IconButton(
                        tooltip:
                            _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                      filled: true,
                      fillColor:
                          colors.surfaceContainerHighest,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            BorderSide(
                          color:
                              colors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // -----------------------------------
                  // FORGOT PASSWORD
                  // -----------------------------------

                  Align(
                    alignment:
                        Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                      child: const Text(
                        'Forgot password?',
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // -----------------------------------
                  // LOGIN BUTTON
                  // -----------------------------------

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : _login,
                      style:
                          ElevatedButton.styleFrom(
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Login',
                              style:
                                  TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // -----------------------------------
                  // DIVIDER
                  // -----------------------------------

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: colors.outlineVariant,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        child: Text(
                          'OR',
                          style: theme
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: colors
                                    .onSurfaceVariant,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: colors.outlineVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // -----------------------------------
                  // GOOGLE
                  // -----------------------------------

                  SizedBox(
                    height: 54,
                    child:
                        OutlinedButton.icon(
                      onPressed:
                          _isLoading
                              ? null
                              : _googleLogin,
                      style:
                          OutlinedButton.styleFrom(
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                        side: BorderSide(
                          color:
                              colors.outline,
                        ),
                      ),
                      icon: const Icon(
                        Icons
                            .account_circle_outlined,
                      ),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // -----------------------------------
                  // SIGNUP
                  // -----------------------------------

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: theme
                            .textTheme
                            .bodyMedium,
                      ),
                      TextButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const SignupScreen(),
                                      ),
                                    );
                                  },
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Your health data stays private and secure.',
                    textAlign: TextAlign.center,
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: colors
                              .onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}