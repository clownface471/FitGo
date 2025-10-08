class Exercise {
  final String id;
  final String name;
  final String bodyPart;
  final String equipment;
  final String imagePath;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    required this.imagePath,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final List<dynamic> images = json['images'] ?? [];
    final String rawImagePath = images.isNotEmpty ? images[0] : '';

    return Exercise(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unnamed Exercise',
      bodyPart: json['category'] ?? 'Unknown',
      equipment: json['equipment'] ?? 'N/A',
      // PERBAIKAN: Path sekarang relatif terhadap folder 'assets'
      imagePath: 'exercise_images/exercises/$rawImagePath',
      primaryMuscles: List<String>.from(json['primaryMuscles'] ?? []),
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }
}