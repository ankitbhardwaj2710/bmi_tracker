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
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Login failed');
    } catch (e) {
      _showMessage('Something went wrong');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _googleLogin() async {
  setState(() => _isLoading = true);

  try {
    final credential = await _authService.signInWithGoogle();

    debugPrint(
      'Google Login UID: ${credential.user?.uid}',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google login successful'),
      ),
    );

    // Give Firebase Auth a moment to update its state.
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
    debugPrint('Firebase Google Auth Error: ${e.code}');
    debugPrint('Firebase Google Auth Message: ${e.message}');

    if (!mounted) return;

    _showMessage(
      '${e.code}: ${e.message}',
    );
  } catch (e) {
    debugPrint('Google Sign-In Error: $e');

    if (!mounted) return;

    _showMessage(
      'Google Sign-In Error: $e',
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.monitor_weight_outlined,
                    size: 80,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'BMI Tracker',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Track your health, one step at a time.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Login'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _googleLogin,
                    icon: const Icon(Icons.login),
                    label: const Text('Continue with Google'),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text('Create Account'),
                      ),
                    ],
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