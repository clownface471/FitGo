import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/daily_workout_model.dart';
import '../../models/exercise_model.dart';
import '../../providers/providers.dart';
import 'exercise_player_screen.dart';

final selectedExercisesProvider =
    StateProvider<List<Exercise>>((ref) => []);

class WorkoutBuilderScreen extends ConsumerWidget {
  const WorkoutBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExercisesAsync = ref.watch(exercisesProvider);
    final selectedExercises = ref.watch(selectedExercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Latihan Bebas'),
      ),
      floatingActionButton: selectedExercises.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                final allExercises = ref.read(exercisesProvider).value ?? [];
                final dailyExercises = selectedExercises.map((e) {
                  return DailyExercise(exerciseId: e.id, exerciseName: e.name, sets: 3, reps: '10');
                }).toList();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExercisePlayerScreen(
                      dailyExercises: dailyExercises,
                      allExercises: allExercises,
                      planName: 'Latihan Bebas',
                      workoutName: 'Sesi Kustom',
                      currentDay: 1,
                    ),
                  ),
                );
              },
              label: Text('Mulai (${selectedExercises.length})'),
              icon: const Icon(Icons.play_arrow),
            )
          : null,
      body: allExercisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Gagal memuat latihan: $err")),
        data: (exercises) {
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              final isSelected = selectedExercises.contains(exercise);

              return CheckboxListTile(
                title: Text(exercise.name),
                subtitle: Text(exercise.bodyPart.toUpperCase()),
                value: isSelected,
                onChanged: (bool? value) {
                  final notifier = ref.read(selectedExercisesProvider.notifier);
                  if (value == true) {
                    notifier.state = [...notifier.state, exercise];
                  } else {
                    notifier.state = notifier.state
                        .where((e) => e.id != exercise.id)
                        .toList();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}