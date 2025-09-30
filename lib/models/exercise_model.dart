class Exercise {
  final String id;
  final String name;
  final String description;
  final String bodyPart; 
  final String equipment;
  final String gifUrl;
  final String target;
  final List<String> instructions;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    required this.target,
    required this.instructions,
  });

  factory Exercise.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Exercise(
      id: documentId,
      name: data['name'] ?? 'Unnamed Exercise',
      description: data['description'] ?? 'No description available.',
      bodyPart: data['targetMuscle'] ?? 'Unknown', 
      equipment: data['equipment'] ?? 'N/A',
      gifUrl: (data['gifUrl'] ?? '').replaceFirst('http://', 'https://'), 
      target: data['targetMuscle'] ?? 'N/A',
      instructions: List<String>.from(data['instructions'] ?? []),
    );
  }
}