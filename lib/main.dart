import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';
import 'screens/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Google Sign-In
  await GoogleSignIn.instance.initialize();

  runApp(const BmiTrackerApp());
}

class BmiTrackerApp extends StatelessWidget {
  const BmiTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMI Tracker',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),

        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),

        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              width: 2,
            ),
          ),
        ),

        cardTheme: const CardThemeData(
          elevation: 1,
          margin: EdgeInsets.zero,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(
              double.infinity,
              52,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(
              double.infinity,
              52,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),

      // Authentication decides where the user should go.
      home: const AuthGate(),
    );
  }
}