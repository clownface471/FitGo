import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String name;
  final String imageUrl;
  final int calories;
  final String protein;
  final String carbs;
  final String fat;
  final List<String> ingredients;
  final List<String> instructions;

  Recipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.instructions,
  });

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Recipe.fromJson(data, doc.id); // Panggil fromJson
  }

  factory Recipe.fromJson(Map<String, dynamic> json, [String? docId]) {
    return Recipe(
      id: docId ?? json['recipeId'] ?? '',
      name: json['name'] ?? 'No Name',
      imageUrl: json['imageUrl'] ?? '',
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? '0g',
      carbs: json['carbs'] ?? '0g',
      fat: json['fat'] ?? '0g',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }
}