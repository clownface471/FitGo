import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise_model.dart';

class ApiService {
  final String _baseUrl = 'exercisedb.p.rapidapi.com'; 
  final Map<String, String> _headers = {
    'X-RapidAPI-Key': 'e238a9ca7emshbb645e607c88b78p1b7d5ajsn3c411f7c0e96',
    'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com'
  };

  Future<List<Exercise>> getAllExercises() async {
    try {
      final uri = Uri.https(_baseUrl, '/exercises', {'limit': '0'});

      final response = await http.get(
        uri,
        headers: _headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load exercises: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}