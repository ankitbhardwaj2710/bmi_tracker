import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword =
        _confirmPasswordController.text;

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }

    if (!email.contains('@') ||
        !email.contains('.')) {
      _showMessage(
        'Please enter a valid email address',
      );
      return;
    }

    if (password.length < 6) {
      _showMessage(
        'Password must be at least 6 characters',
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage(
        'Passwords do not match',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showMessage(
        'Account created successfully',
      );

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Signup Firebase Error: ${e.code}',
      );

      _showMessage(
        e.message ?? 'Signup failed',
      );
    } catch (e) {
      debugPrint(
        'Signup Error: $e',
      );

      _showMessage(
        'Something went wrong. Please try again.',
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

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final colors =
        Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor:
          colors.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.primary,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24,
              20,
              24,
              32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  // LOGO
                  Center(
                    child: Container(
                      height: 86,
                      width: 86,
                      decoration: BoxDecoration(
                        color:
                            colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 44,
                        color:
                            colors.onPrimaryContainer,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Text(
                    'Create your account',
                    textAlign: TextAlign.center,
                    style: theme
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Start tracking your health and BMI today.',
                    textAlign: TextAlign.center,
                    style: theme
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                          color:
                              colors.onSurfaceVariant,
                        ),
                  ),

                  const SizedBox(height: 32),

                  // EMAIL
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
                        _inputDecoration(
                      hint: 'Enter your email',
                      icon:
                          Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // PASSWORD
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
                        TextInputAction.next,
                    decoration:
                        _inputDecoration(
                      hint: 'Create a password',
                      icon:
                          Icons.lock_outline_rounded,
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
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Password must contain at least 6 characters.',
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color:
                              colors.onSurfaceVariant,
                        ),
                  ),

                  const SizedBox(height: 18),

                  // CONFIRM PASSWORD
                  Text(
                    'Confirm password',
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
                        _confirmPasswordController,
                    obscureText:
                        _obscureConfirmPassword,
                    textInputAction:
                        TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _signup();
                      }
                    },
                    decoration:
                        _inputDecoration(
                      hint:
                          'Re-enter your password',
                      icon:
                          Icons.lock_outline_rounded,
                      suffixIcon:
                          IconButton(
                        tooltip:
                            _obscureConfirmPassword
                                ? 'Show password'
                                : 'Hide password',
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // CREATE ACCOUNT
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : _signup,
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
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // LOGIN LINK
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: theme
                            .textTheme
                            .bodyMedium,
                      ),
                      TextButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () {
                                    Navigator.pop(
                                      context,
                                    );
                                  },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Your health data stays private and secure.',
                    textAlign: TextAlign.center,
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color:
                              colors.onSurfaceVariant,
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