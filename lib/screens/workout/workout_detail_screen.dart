import 'package:flutter/material.dart';
import '../../models/daily_workout_model.dart';
import '../../models/exercise_model.dart';
import 'exercise_player_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final String title;
  final List<Exercise> exercises;

  const WorkoutDetailScreen({
    super.key,
    required this.title,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title.toUpperCase()),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final exercise = exercises[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExercisePlayerScreen(
                            dailyExercises: [
                              DailyExercise(exerciseId: exercise.id, sets: 3, reps: '10-12')
                            ],
                            allExercises: exercises,
                            planName: "Latihan Bebas",
                            workoutName: exercise.name,
                            currentDay: 1,
                          ),
                        ),
                      );
                    },
                    child: _ExerciseCard(exercise: exercise),
                  );
                },
                childCount: exercises.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final secureGifUrl = exercise.gifUrl.replaceFirst('http://', 'https://');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Image.network(
                secureGifUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.fitness_center, color: Colors.grey, size: 50);
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            color: Theme.of(context).cardTheme.color,
            child: Text(
              exercise.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}