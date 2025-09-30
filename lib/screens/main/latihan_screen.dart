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
  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirestoreService().getExercises().then((exercises) {
      setState(() {
        _allExercises = exercises;
        _filteredExercises = exercises;
      });
    });

    _searchController.addListener(_filterExercises);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterExercises() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredExercises = _allExercises.where((exercise) {
        final exerciseName = exercise.name.toLowerCase();
        return exerciseName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupedExercises =
        groupBy(_filteredExercises, (Exercise e) => e.bodyPart);
    final bodyParts = groupedExercises.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Latihan'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
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
            child: _allExercises.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : bodyParts.isEmpty
                    ? const Center(child: Text("Latihan tidak ditemukan."))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: bodyParts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final bodyPart = bodyParts[index];
                          final exercisesForBodyPart =
                              groupedExercises[bodyPart]!;

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
  final VoidCallback onTap;

  const _WorkoutCategoryCard(
      {required this.title, required this.exerciseCount, required this.onTap});

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
                child: const Center(
                    child: Icon(Icons.image, color: Colors.grey, size: 40)),
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
            ],
          ),
        ),
      ),
    );
  }
}
