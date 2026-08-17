import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../home/home_screen.dart';
import '../onboarding/user_details_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder(
          future: FirestoreService().getUserProfile(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (profileSnapshot.hasError) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Unable to load profile',
                  ),
                ),
              );
            }

            final profile = profileSnapshot.data;

            if (profile == null) {
              return const UserDetailsScreen();
            }

            return const HomeScreen();
          },
        );
      },
    );
  }
}