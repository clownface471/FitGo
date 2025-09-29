class Exercise {
  final String id;
  final String name;
  final String bodyPart;
  final String equipment;
  final String gifUrl;
  final String target;
  final List<String> instructions;

  Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    required this.target,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? 'no-id',
      name: json['name'] as String? ?? 'Unnamed Exercise',
      bodyPart: json['bodyPart'] as String? ?? 'Unknown',
      equipment: json['equipment'] as String? ?? 'N/A',
      gifUrl: json['gifUrl'] as String? ?? '',
      target: json['target'] as String? ?? 'N/A',
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }
}
