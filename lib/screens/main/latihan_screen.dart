import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../models/exercise_model.dart';
import '../../providers/providers.dart';
import '../workout/workout_builder_screen.dart'; 
import '../workout/workout_detail_screen.dart';
import '../../widgets/muscle_map.dart';

final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

class LatihanScreen extends ConsumerWidget {
  const LatihanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExercisesAsync = ref.watch(exercisesProvider);
    final searchQuery = ref.watch(exerciseSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Latihan'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WorkoutBuilderScreen()),
          );
        },
        label: const Text('Buat Latihan Bebas'),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (query) =>
                  ref.read(exerciseSearchQueryProvider.notifier).state = query,
              decoration: InputDecoration(
                hintText: 'Cari nama latihan...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: allExercisesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text("Gagal memuat latihan: $err")),
              data: (allExercises) {
                final filteredExercises = allExercises.where((exercise) {
                  final exerciseName = exercise.name.toLowerCase();
                  final query = searchQuery.toLowerCase();
                  return exerciseName.contains(query);
                }).toList();

                if (filteredExercises.isEmpty) {
                  return const Center(child: Text("Latihan tidak ditemukan."));
                }

                final groupedExercises =
                    groupBy(filteredExercises, (Exercise e) => e.bodyPart);
                final bodyParts = groupedExercises.keys.toList();

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), 
                  itemCount: bodyParts.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final bodyPart = bodyParts[index];
                    final exercisesForBodyPart = groupedExercises[bodyPart]!;

                    return _WorkoutCategoryCard(
                      title: bodyPart,
                      exerciseCount: exercisesForBodyPart.length,
                      exercises: exercisesForBodyPart,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutDetailScreen(
                              title: bodyPart,
                              exercises: exercisesForBodyPart,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCategoryCard extends StatelessWidget {
  final String title;
  final int exerciseCount;
  final List<Exercise> exercises;
  final VoidCallback onTap;

  const _WorkoutCategoryCard({
    required this.title,
    required this.exerciseCount,
    required this.exercises,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryMuscles =
        exercises.expand((e) => e.primaryMuscles).toSet().toList();
    final secondaryMuscles =
        exercises.expand((e) => e.secondaryMuscles).toSet().toList();

    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              MuscleMap(
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontSize: 22),
                    ),
                    Text(
                      '$exerciseCount Latihan',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}