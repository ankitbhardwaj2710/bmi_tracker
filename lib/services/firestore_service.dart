import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/weight_entry.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // --------------------------------------------------
  // USER PROFILE
  // --------------------------------------------------

  Future<void> saveUserProfile(
    UserModel user,
  ) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<UserModel?> getUserProfile(
    String uid,
  ) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromMap(
      doc.data()!,
    );
  }

  // --------------------------------------------------
  // WEIGHT HISTORY
  // --------------------------------------------------

  Future<void> addWeightEntry(
    WeightEntry entry,
  ) async {
    await _firestore
        .collection('users')
        .doc(entry.uid)
        .collection('weightHistory')
        .doc(entry.id)
        .set(
          entry.toMap(),
        );
  }

  Future<List<WeightEntry>> getWeightHistory(
    String uid,
  ) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('weightHistory')
        .orderBy('date')
        .get();

    return snapshot.docs
        .map(
          (doc) => WeightEntry.fromMap(
            doc.data(),
          ),
        )
        .toList();
  }
}