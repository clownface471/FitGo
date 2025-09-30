import 'package:flutter/material.dart';
import '../../models/workout_history_model.dart';

class HistoryDetailScreen extends StatelessWidget {
  final WorkoutHistory history;
  const HistoryDetailScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(history.workoutName),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.exercises.length,
        itemBuilder: (context, index) {
          final performedExercise = history.exercises[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    performedExercise.exerciseName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...performedExercise.sets.map((set) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        child: Text('${set.setNumber}'),
                      ),
                      title: Text("${set.weight} kg × ${set.reps} reps"),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}