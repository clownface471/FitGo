import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/daily_workout_model.dart';
import '../../models/exercise_model.dart';
import '../../utils/firestore_service.dart';
import '../../utils/theme.dart';

class ExercisePlayerScreen extends StatefulWidget {
  final List<DailyExercise> dailyExercises;
  final List<Exercise> allExercises;
  final String planName; 
  final String workoutName;
  final int currentDay;

  const ExercisePlayerScreen({
    super.key,
    required this.dailyExercises,
    required this.allExercises,
    required this.planName,
    required this.workoutName,
    required this.currentDay,
  });

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen> {
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  bool _isResting = false;
  Timer? _timer;
  int _restSeconds = 30;

  Future<void> _finishWorkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final firestoreService = FirestoreService();
      await firestoreService.addWorkoutHistory(
        uid: user.uid,
        planName: widget.planName,
        workoutName: widget.workoutName,
        dayCompleted: widget.currentDay,
      );
      await firestoreService.advanceToNextDay(user.uid);
    }
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) => AlertDialog(
          backgroundColor: darkCardColor,
          title: const Text('Kerja Bagus!'),
          content: const Text('Anda telah menyelesaikan latihan hari ini.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Kembali ke Home', style: TextStyle(color: primaryColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop(true); 
              },
            ),
          ],
        ),
      );
    }
  }

  void _startRestTimer() {
    setState(() {
      _isResting = true;
      _restSeconds = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds > 0) {
        setState(() => _restSeconds--);
      } else {
        _timer?.cancel();
        _moveToNextSetOrExercise();
      }
    });
  }

  void _moveToNextSetOrExercise() {
    setState(() {
      _isResting = false;
      final currentDailyExercise = widget.dailyExercises[_currentExerciseIndex];

      if (_currentSet < currentDailyExercise.sets) {
        _currentSet++;
      } else {
        if (_currentExerciseIndex < widget.dailyExercises.length - 1) {
          _currentExerciseIndex++;
          _currentSet = 1;
        } else {
          _finishWorkout();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isResting) {
      return _buildRestScreen();
    }

    final currentDailyExercise = widget.dailyExercises[_currentExerciseIndex];
    final currentExerciseDetail = widget.allExercises.firstWhere(
      (ex) => ex.id == currentDailyExercise.exerciseId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentExerciseIndex + 1} / ${widget.dailyExercises.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(currentExerciseDetail.gifUrl.replaceFirst('http://', 'https://'), fit: BoxFit.contain),
            ),
            const SizedBox(height: 24),
            Text(currentExerciseDetail.name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Set $_currentSet dari ${currentDailyExercise.sets} ・ ${currentDailyExercise.reps} repetisi',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _startRestTimer,
              child: Text(_currentExerciseIndex == widget.dailyExercises.length - 1 && _currentSet == currentDailyExercise.sets ? 'Selesaikan Latihan' : 'Selesai & Istirahat'),
            ),
          ],
        ),
      ),
    );
  }

  Scaffold _buildRestScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ISTIRAHAT', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 20),
            Text('$_restSeconds', style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                _timer?.cancel();
                _moveToNextSetOrExercise();
              },
              child: const Text('Lewati Istirahat', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}