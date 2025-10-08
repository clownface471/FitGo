import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise_model.dart';
import '../models/motivation_model.dart'; // Import model motivasi

class ApiService {
  final String _baseUrl = 'https://wrkout.onrender.com/api';
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'x-api-key': '9632f2f9-ea85-4e88-8c07-e018a6305304',
  };

  Future<List<Exercise>> getExercises() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/exercises'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Exercise.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load exercises from API');
    }
  }

  Future<List<Motivation>> getMotivations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/motivations'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Motivation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load motivations from API');
    }
  }
}