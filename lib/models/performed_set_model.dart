class PerformedSet {
  final int setNumber;
  final double weight;
  final int reps;

  PerformedSet({
    required this.setNumber,
    required this.weight,
    required this.reps,
  });

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
    };
  }

  factory PerformedSet.fromMap(Map<String, dynamic> map) {
    return PerformedSet(
      setNumber: map['setNumber'] ?? 0,
      weight: (map['weight'] ?? 0.0).toDouble(),
      reps: map['reps'] ?? 0,
    );
  }
}