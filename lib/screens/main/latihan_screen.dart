import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../../models/exercise_model.dart';
import '../../utils/firestore_service.dart'; 
import '../workout/workout_detail_screen.dart';

class LatihanScreen extends StatefulWidget {
  const LatihanScreen({super.key});

  @override
  State<LatihanScreen> createState() => _LatihanScreenState();
}

class _LatihanScreenState extends State<LatihanScreen> {
  late Future<List<Exercise>> _exercises = FirestoreService().getExercises();

  void _refreshExercises() {
    setState(() {
      _exercises = FirestoreService().getExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latihan'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshExercises(),
        child: FutureBuilder<List<Exercise>>(
          future: _exercises,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Tidak ada data latihan di database.'));
            } else {
              final exercises = snapshot.data!;
              final groupedExercises = groupBy(exercises, (Exercise e) => e.bodyPart);
              final bodyParts = groupedExercises.keys.toList();

              return ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: bodyParts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final bodyPart = bodyParts[index];
                  final exercisesForBodyPart = groupedExercises[bodyPart]!;
                  
                  return _WorkoutCategoryCard(
                    title: bodyPart,
                    exerciseCount: exercisesForBodyPart.length,
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
            }
          },
        ),
      ),
    );
  }
}

class _WorkoutCategoryCard extends StatelessWidget {
  final String title;
  final int exerciseCount;
  final VoidCallback onTap;

  const _WorkoutCategoryCard({required this.title, required this.exerciseCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Icon(Icons.image, color: Colors.grey, size: 40)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22),
                    ),
                    Text(
                      '$exerciseCount Latihan',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}