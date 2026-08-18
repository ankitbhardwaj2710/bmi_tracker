import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/user_model.dart';
import '../../models/weight_entry.dart';
import '../../services/bmi_service.dart';
import '../../services/firestore_service.dart';
import '../home/home_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  final UserModel? existingProfile;

  const UserDetailsScreen({
    super.key,
    this.existingProfile,
  });

  @override
  State<UserDetailsScreen> createState() =>
      _UserDetailsScreenState();
}

class _UserDetailsScreenState
    extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _weightController =
      TextEditingController();

  final _heightController =
      TextEditingController();

  final _firestoreService =
      FirestoreService();

  final _uuid = const Uuid();

  String _weightUnit = 'KG';
  String _heightUnit = 'CM';
  String _gender = 'Male';

  bool _isLoading = false;

  bool get _isEditing =>
      widget.existingProfile != null;

  @override
  void initState() {
    super.initState();

    final profile = widget.existingProfile;

    if (profile != null) {
      _weightController.text =
          profile.weight.toString();

      _heightController.text =
          profile.height.toString();

      _weightUnit =
          profile.weightUnit;

      _heightUnit =
          profile.heightUnit;

      _gender =
          profile.gender;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please login first',
      );
      return;
    }

    final weight = double.parse(
      _weightController.text.trim(),
    );

    final height = double.parse(
      _heightController.text.trim(),
    );

    setState(() {
      _isLoading = true;
    });

    try {
      // ==============================================
      // CALCULATE BMI
      // ==============================================

      final bmi = BmiService.calculate(
        weight: weight,
        weightUnit: _weightUnit,
        height: height,
        heightUnit: _heightUnit,
      );

      final category =
          BmiService.getCategory(bmi);

      // ==============================================
      // CREATE PROFILE
      // ==============================================

      final profile = UserModel(
        uid: user.uid,
        email: user.email,
        weight: weight,
        weightUnit: _weightUnit,
        height: height,
        heightUnit: _heightUnit,
        gender: _gender,
        bmi: bmi,
        bmiCategory: category,
      );

      // ==============================================
      // SAVE PROFILE
      // ==============================================

      await _firestoreService
          .saveUserProfile(profile);

      // ==============================================
      // SAVE WEIGHT HISTORY
      // ==============================================

      final weightEntry = WeightEntry(
        id: _uuid.v4(),
        uid: user.uid,
        weight: weight,
        unit: _weightUnit,
        date: DateTime.now(),
      );

      await _firestoreService
          .addWeightEntry(weightEntry);

      if (!mounted) return;

      _showMessage(
        _isEditing
            ? 'Profile updated successfully!'
            : 'Profile saved successfully!',
      );

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      // ==============================================
      // GO TO DASHBOARD
      // ==============================================

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const HomeScreen(),
        ),
        (_) => false,
      );
    } catch (e) {
      debugPrint(
        'Save Profile Error: $e',
      );

      if (!mounted) return;

      _showMessage(
        'Unable to save profile. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateNumber(
    String? value,
    String fieldName,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final number =
        double.tryParse(value.trim());

    if (number == null) {
      return 'Enter a valid number';
    }

    if (number <= 0) {
      return '$fieldName must be greater than zero';
    }

    return null;
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Update Details'
              : 'Your Details',
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [
                Icon(
                  _isEditing
                      ? Icons.edit_note
                      : Icons
                          .monitor_weight_outlined,
                  size: 72,
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  _isEditing
                      ? 'Update your details'
                      : 'Tell us about yourself',
                  textAlign:
                      TextAlign.center,

                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  _isEditing
                      ? 'Update your information to recalculate your BMI.'
                      : 'Enter your basic details to calculate your BMI.',
                  textAlign:
                      TextAlign.center,
                ),

                const SizedBox(
                  height: 32,
                ),

                // =====================================
                // WEIGHT
                // =====================================

                TextFormField(
                  controller:
                      _weightController,

                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),

                  decoration:
                      InputDecoration(
                    labelText: 'Weight',

                    prefixIcon:
                        const Icon(
                      Icons
                          .monitor_weight,
                    ),

                    suffixText:
                        _weightUnit,

                    border:
                        const OutlineInputBorder(),
                  ),

                  validator:
                      (value) =>
                          _validateNumber(
                    value,
                    'Weight',
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'KG',
                      label: Text('KG'),
                    ),
                    ButtonSegment(
                      value: 'LBS',
                      label: Text('LBS'),
                    ),
                  ],

                  selected: {
                    _weightUnit,
                  },

                  onSelectionChanged:
                      (value) {
                    setState(() {
                      _weightUnit =
                          value.first;
                    });
                  },
                ),

                const SizedBox(
                  height: 24,
                ),

                // =====================================
                // HEIGHT
                // =====================================

                TextFormField(
                  controller:
                      _heightController,

                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),

                  decoration:
                      InputDecoration(
                    labelText: 'Height',

                    prefixIcon:
                        const Icon(
                      Icons.height,
                    ),

                    suffixText:
                        _heightUnit,

                    border:
                        const OutlineInputBorder(),
                  ),

                  validator:
                      (value) =>
                          _validateNumber(
                    value,
                    'Height',
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'CM',
                      label: Text('CM'),
                    ),
                    ButtonSegment(
                      value: 'INCH',
                      label:
                          Text('Inches'),
                    ),
                  ],

                  selected: {
                    _heightUnit,
                  },

                  onSelectionChanged:
                      (value) {
                    setState(() {
                      _heightUnit =
                          value.first;
                    });
                  },
                ),

                const SizedBox(
                  height: 24,
                ),

                // =====================================
                // GENDER
                // =====================================

                DropdownButtonFormField<
                    String>(
                  initialValue:
                      _gender,

                  decoration:
                      const InputDecoration(
                    labelText: 'Gender',

                    prefixIcon:
                        Icon(
                      Icons
                          .person_outline,
                    ),

                    border:
                        OutlineInputBorder(),
                  ),

                  items: const [
                    DropdownMenuItem(
                      value: 'Male',
                      child:
                          Text('Male'),
                    ),
                    DropdownMenuItem(
                      value: 'Female',
                      child:
                          Text('Female'),
                    ),
                    DropdownMenuItem(
                      value: 'Other',
                      child:
                          Text('Other'),
                    ),
                  ],

                  onChanged:
                      (value) {
                    if (value !=
                        null) {
                      setState(() {
                        _gender =
                            value;
                      });
                    }
                  },
                ),

                const SizedBox(
                  height: 32,
                ),

                // =====================================
                // SAVE / UPDATE
                // =====================================

                SizedBox(
                  height: 54,

                  child:
                      ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _saveDetails,

                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child:
                                CircularProgressIndicator(),
                          )
                        : Text(
                            _isEditing
                                ? 'Update & Recalculate BMI'
                                : 'Calculate My BMI',

                            style:
                                const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}