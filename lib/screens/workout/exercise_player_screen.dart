import 'package:flutter/material.dart';
import '../../models/exercise_model.dart';

class ExercisePlayerScreen extends StatelessWidget {
  final Exercise exercise;
  const ExercisePlayerScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final secureGifUrl = exercise.gifUrl.replaceFirst('http://', 'https://');

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(15),
              ),
              clipBehavior: Clip.antiAlias, 
              child: Center(
                child: Image.network(
                  secureGifUrl,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Gagal memuat gambar.", textAlign: TextAlign.center),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "Instructions",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),

            ...exercise.instructions.asMap().entries.map((entry) {
              int idx = entry.key + 1;
              String instruction = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text("$idx", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(instruction, style: Theme.of(context).textTheme.bodyLarge)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}