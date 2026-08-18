import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/weight_entry.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ==================================================
  // USER PROFILE
  // ==================================================

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

  // ==================================================
  // WEIGHT HISTORY
  // ==================================================

  Future<void> addWeightEntry(
    WeightEntry entry,
  ) async {
    final historyRef = _firestore
        .collection('users')
        .doc(entry.uid)
        .collection('weightHistory');

    final startOfDay = DateTime(
      entry.date.year,
      entry.date.month,
      entry.date.day,
    );

    final endOfDay = startOfDay.add(
      const Duration(days: 1),
    );

    final existing = await historyRef
        .where(
          'date',
          isGreaterThanOrEqualTo:
              startOfDay.toIso8601String(),
        )
        .where(
          'date',
          isLessThan:
              endOfDay.toIso8601String(),
        )
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update(
        entry.toMap(),
      );
    } else {
      await historyRef
          .doc(entry.id)
          .set(
            entry.toMap(),
          );
    }
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