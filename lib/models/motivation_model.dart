class Motivation {
  final String id;
  final String type;
  final String name;
  final String imageUrl;
  final String content;

  Motivation({
    required this.id,
    required this.type,
    required this.name,
    required this.imageUrl,
    required this.content,
  });

  factory Motivation.fromJson(Map<String, dynamic> json) {
    const String baseUrl = 'https://wrkout.onrender.com';
    String imagePath = json['image_url'] ?? '';
    final String fullImageUrl = imagePath.startsWith('http') ? imagePath : '$baseUrl$imagePath';

    return Motivation(
      id: json['_id'] ?? '',
      type: json['type'] ?? 'quote',
      name: json['name'] ?? 'Unknown',
      imageUrl: fullImageUrl,
      content: json['content'] ?? '',
    );
  }
}