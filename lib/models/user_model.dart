class UserModel {
  final String uid;
  final String? email;
  final double weight;
  final String weightUnit;
  final double height;
  final String heightUnit;
  final String gender;
  final double bmi;
  final String bmiCategory;

  const UserModel({
    required this.uid,
    this.email,
    required this.weight,
    required this.weightUnit,
    required this.height,
    required this.heightUnit,
    required this.gender,
    required this.bmi,
    required this.bmiCategory,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'weight': weight,
      'weightUnit': weightUnit,
      'height': height,
      'heightUnit': heightUnit,
      'gender': gender,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'],
      weight: (map['weight'] ?? 0).toDouble(),
      weightUnit: map['weightUnit'] ?? 'KG',
      height: (map['height'] ?? 0).toDouble(),
      heightUnit: map['heightUnit'] ?? 'CM',
      gender: map['gender'] ?? 'Other',
      bmi: (map['bmi'] ?? 0).toDouble(),
      bmiCategory: map['bmiCategory'] ?? 'Unknown',
    );
  }
}