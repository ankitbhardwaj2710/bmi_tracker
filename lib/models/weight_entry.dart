class WeightEntry {
  final String id;
  final String uid;
  final double weight;
  final String unit;
  final DateTime date;

  const WeightEntry({
    required this.id,
    required this.uid,
    required this.weight,
    required this.unit,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'weight': weight,
      'unit': unit,
      'date': date.toIso8601String(),
    };
  }

  factory WeightEntry.fromMap(
    Map<String, dynamic> map,
  ) {
    return WeightEntry(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      unit: map['unit'] ?? 'KG',
      date: DateTime.parse(
        map['date'],
      ),
    );
  }
}