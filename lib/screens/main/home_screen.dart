import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/daily_workout_model.dart';
import '../../models/exercise_model.dart';
import '../../models/user_model.dart';
import '../../models/workout_plan_model.dart';
import '../../utils/auth_service.dart';
import '../../utils/firestore_service.dart';
import '../workout/exercise_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _dataFuture;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() {
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Pengguna tidak login");

    final firestoreService = FirestoreService();
    final userData = await firestoreService.getUserData(user.uid);
    if (userData == null || userData.goal == null || userData.level == null) {
      throw Exception("Data onboarding pengguna tidak lengkap.");
    }
    
    final recommendedPlan = await firestoreService.getRecommendedPlan(userData.goal!, userData.level!);
    final allExercises = await firestoreService.getExercises();

    return {
      'user': userData,
      'plan': recommendedPlan,
      'exercises': allExercises, 
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              final UserModel user = snapshot.data!['user'];
              final String name = user.email.split('@')[0];
              return Text('Hai, $name!');
            }
            return const Text('Memuat...');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.signOut(),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadAllData(),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Gagal memuat data: ${snapshot.error}"));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("Data tidak ditemukan."));
            }

            final UserModel user = snapshot.data!['user'];
            final WorkoutPlan? plan = snapshot.data!['plan'];
            final List<Exercise> allExercises = snapshot.data!['exercises'];

            return _buildDashboard(context, user, plan, allExercises);
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, UserModel user, WorkoutPlan? plan, List<Exercise> allExercises) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Program Anda", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          
          if (plan != null)
            _RecommendedPlanCard(plan: plan, allExercises: allExercises, currentDay: user.currentDay)
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
  final int currentDay; 

  const _RecommendedPlanCard({
    required this.plan,
    required this.allExercises,
    required this.currentDay,
  });

  @override
  Widget build(BuildContext context) {
    final todayWorkout = plan.workouts.firstWhere(
      (w) => w.day == currentDay,
      orElse: () => plan.workouts.first,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.planName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text("Hari ke-$currentDay: ${todayWorkout.workoutName}", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text("${todayWorkout.exercises.length} gerakan", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: todayWorkout.exercises.isEmpty ? null : () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ExercisePlayerScreen(
                    dailyExercises: todayWorkout.exercises,
                    allExercises: allExercises,
                  ),
                ));
              },
              child: Text(todayWorkout.exercises.isEmpty ? 'Hari Istirahat' : "Mulai Latihan Hari Ini"),
            )
          ],
        ),
      ),
    );
  }
}