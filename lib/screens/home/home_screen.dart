import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../history/weight_history_screen.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../auth/login_screen.dart';
import '../onboarding/user_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  UserModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      final profile = await _firestoreService.getUserProfile(user.uid);

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('BMI Tracker')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserDetailsScreen()),
              );
            },
            child: const Text('Add Details'),
          ),
        ),
      );
    }

    final profile = _profile!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Tracker'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Hello 👋',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              profile.email ?? 'Welcome back',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Your BMI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      _formatNumber(profile.bmi),
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Chip(
                      label: Text(
                        profile.bmiCategory,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    title: 'Weight',
                    value:
                        '${_formatNumber(profile.weight)} ${profile.weightUnit}',
                    icon: Icons.monitor_weight_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    title: 'Height',
                    value:
                        '${_formatNumber(profile.height)} ${profile.heightUnit}',
                    icon: Icons.height,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _InfoCard(
              title: 'Gender',
              value: profile.gender,
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserDetailsScreen()),
                );

                _loadProfile();
              },
              icon: const Icon(Icons.edit),
              label: const Text('Update Details'),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WeightHistoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.show_chart),
              label: const Text('View Weight History'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
