import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Please enter your email');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showMessage('Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(email);

      if (!mounted) return;

      _showMessage(
        'Password reset email sent. Check your inbox.',
      );
    } catch (e) {
      debugPrint('Password Reset Error: $e');

      if (!mounted) return;

      _showMessage(
        'Unable to send reset email. Check the email address.',
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
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
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
              32,
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
                  // ICON
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
                        Icons.lock_reset_rounded,
                        size: 48,
                        color:
                            colors.onPrimaryContainer,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Reset your password',
                    textAlign: TextAlign.center,
                    style: theme
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Enter the email linked to your account and we will send you a password reset link.',
                    textAlign: TextAlign.center,
                    style: theme
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                          color:
                              colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                  ),

                  const SizedBox(height: 32),

                  // EMAIL LABEL
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
                        TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _resetPassword();
                      }
                    },
                    decoration:
                        InputDecoration(
                      hintText:
                          'Enter your email',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
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

                  const SizedBox(height: 24),

                  // SEND BUTTON
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isLoading
                              ? null
                              : _resetPassword,
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
                      icon: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(
                              Icons
                                  .send_outlined,
                            ),
                      label: Text(
                        _isLoading
                            ? 'Sending...'
                            : 'Send Reset Link',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // INFO CARD
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons
                                .info_outline_rounded,
                            color:
                                colors.primary,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              'After requesting a reset, check your email inbox and spam folder for the password reset link.',
                              style: theme
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: colors
                                        .onSurfaceVariant,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton.icon(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                                Navigator.pop(
                                  context,
                                );
                              },
                    icon: const Icon(
                      Icons
                          .arrow_back_rounded,
                    ),
                    label: const Text(
                      'Back to Login',
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