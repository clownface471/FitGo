class Exercise {
  final String id;
  final String name;
  final String description;
  final String bodyPart;
  final String equipment;
  final String gifUrl;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
  });

  factory Exercise.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Exercise(
      id: documentId,
      name: data['name'] ?? 'Unnamed Exercise',
      description: data['description'] ?? 'No description available.',
      bodyPart: data['bodyPart'] ?? 'Unknown', 
      equipment: data['equipment'] ?? 'N/A',
      gifUrl: (data['gifUrl'] ?? '').replaceFirst('http://', 'https://'), 
      primaryMuscles: List<String>.from(data['primaryMuscles'] ?? []),
      secondaryMuscles: List<String>.from(data['secondaryMuscles'] ?? []),
      instructions: List<String>.from(data['instructions'] ?? []),
    );
  }
}