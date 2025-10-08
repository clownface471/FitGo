import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/daily_progress_model.dart';
import '../../models/exercise_model.dart';
import '../../models/user_model.dart';
import '../../models/workout_plan_model.dart';
import '../../providers/providers.dart';
import '../../utils/calorie_calculator.dart';
import '../../utils/custom_page_route.dart';
import '../workout/exercise_player_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataFuture = ref.watch(homeScreenDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: dataFuture.when(
          data: (data) {
            final UserModel user = data['user'];
            final String name = user.email.split('@')[0];
            return Text('Hai, $name!');
          },
          loading: () => const Text('Memuat...'),
          error: (_, __) => const Text('Selamat Datang!'),
        ),
        actions: const [],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homeScreenDataProvider);
        },
        child: dataFuture.when(
          data: (data) {
            final UserModel user = data['user'];
            final WorkoutPlan? plan = data['plan'];
            final List<Exercise> allExercises = data['exercises'];
            final DailyProgress progress = data['progress'];
            return _buildDashboard(context, ref, user, plan, allExercises, progress);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Gagal memuat data: $err")),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, UserModel user, WorkoutPlan? plan, List<Exercise> allExercises, DailyProgress progress) {
    final calorieTarget = CalorieCalculator.calculateBMR(user);

    int dayOfProgram = 1;
    if (user.planStartDate != null) {
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final startDate = DateTime(user.planStartDate!.year, user.planStartDate!.month, user.planStartDate!.day);
      dayOfProgram = today.difference(startDate).inDays + 1;
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalorieDashboard(
            caloriesConsumed: progress.caloriesConsumed,
            calorieTarget: calorieTarget,
          ),
          const SizedBox(height: 24),
          Text("Program Anda", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          if (plan != null)
            _RecommendedPlanCard(
              plan: plan,
              allExercises: allExercises,
              dayOfProgram: dayOfProgram,
              onWorkoutCompleted: () {
                 ref.invalidate(homeScreenDataProvider);
              },
            )
          else
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text("Program Tidak Ditemukan"),
                subtitle: Text("Belum ada program yang cocok untuk tujuan dan level Anda."),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecommendedPlanCard extends StatelessWidget {
  final WorkoutPlan plan;
  final List<Exercise> allExercises;
  final int dayOfProgram;
  final VoidCallback onWorkoutCompleted;

  const _RecommendedPlanCard({
    required this.plan,
    required this.allExercises,
    required this.dayOfProgram,
    required this.onWorkoutCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final dayInCycle = (dayOfProgram - 1) % plan.workouts.length;
    final todayWorkout = plan.workouts[dayInCycle];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.planName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text("Hari ke-$dayOfProgram: ${todayWorkout.workoutName}", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text("${todayWorkout.exercises.length} gerakan", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: todayWorkout.exercises.isEmpty ? null : () async {
                HapticFeedback.lightImpact();
                final result = await Navigator.push(context, CustomPageRoute(
                  child: ExercisePlayerScreen(
                    dailyExercises: todayWorkout.exercises,
                    allExercises: allExercises,
                    planName: plan.planName,
                    workoutName: todayWorkout.workoutName,
                    currentDay: dayOfProgram,
                  ),
                ));

                if (result == true) {
                  onWorkoutCompleted();
                }
              },
              child: Text(todayWorkout.exercises.isEmpty ? 'Hari Istirahat' : "Mulai Latihan Hari Ini"),
            )
          ],
        ),
      ),
    );
  }
}
class CalorieDashboard extends StatelessWidget {
  final int caloriesConsumed;
  final int calorieTarget;

  const CalorieDashboard({
    super.key,
    required this.caloriesConsumed,
    required this.calorieTarget,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = calorieTarget > 0 ? (caloriesConsumed / calorieTarget).clamp(0, 1) : 0;
    final int remainingCalories = calorieTarget - caloriesConsumed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ringkasan Kalori Hari Ini", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoColumn(title: "Masuk", value: "$caloriesConsumed"),
                _InfoColumn(title: "Target", value: "$calorieTarget"),
                _InfoColumn(title: "Sisa", value: "$remainingCalories"),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
              backgroundColor: Theme.of(context).cardTheme.color,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;
  const _InfoColumn({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}