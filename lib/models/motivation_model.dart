import 'package:cloud_firestore/cloud_firestore.dart';

class Motivation {
  final String type;
  final String name;
  final String imageUrl;
  final String content;

  Motivation({
    required this.type,
    required this.name,
    required this.imageUrl,
    required this.content,
  });

  factory Motivation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Motivation(
      type: data['type'] ?? 'quote',
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      content: data['content'] ?? '',
    );
  }
}