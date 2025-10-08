import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/daily_workout_model.dart';
import '../../models/exercise_model.dart';
import '../../providers/providers.dart';
import '../../utils/theme.dart';
import 'exercise_player_screen.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final allExercises = ref.read(exercisesProvider).value ?? [];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExercisePlayerScreen(
                dailyExercises: [
                  DailyExercise(exerciseId: exercise.id, exerciseName: exercise.name, sets: 3, reps: '10-12')
                ],
                allExercises: allExercises,
                planName: "Latihan Tunggal",
                workoutName: exercise.name,
                currentDay: 1,
              ),
            ),
          );
        },
        label: const Text("Mulai Latihan"),
        icon: const Icon(Icons.play_arrow),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 350,
              width: double.infinity,
              color: Colors.white,
              child: Image.asset(
                exercise.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Center(
                    child: Icon(Icons.fitness_center, size: 80, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Peralatan: ${exercise.equipment}",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  _buildMuscleChips(),
                  const SizedBox(height: 24),
                  Text(
                    "Instruksi",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildInstructions(),
                  const SizedBox(height: 100), // Padding untuk FAB
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exercise.primaryMuscles.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const Chip(
                label: Text("Utama"),
                backgroundColor: primaryColor,
                labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              ...exercise.primaryMuscles
                  .map((muscle) => Chip(label: Text(muscle.toUpperCase())))
                  .toList(),
            ],
          ),
        if (exercise.secondaryMuscles.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const Chip(
                label: Text("Sekunder"),
                backgroundColor: darkCardColor,
              ),
              ...exercise.secondaryMuscles
                  .map((muscle) => Chip(label: Text(muscle.toUpperCase())))
                  .toList(),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: exercise.instructions.asMap().entries.map((entry) {
        int idx = entry.key;
        String instruction = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${idx + 1}.",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  instruction,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}