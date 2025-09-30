import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/daily_workout_model.dart';
import '../../models/exercise_model.dart';
import '../../models/performed_set_model.dart';
import '../../models/workout_history_model.dart';
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

  final List<PerformedExercise> _performedExercisesLog = []; 
  final List<PerformedSet> _currentExerciseSetsLog = []; 
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: '0');
    _repsController = TextEditingController();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _logSetAndStartRest() {
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final reps = int.tryParse(_repsController.text) ?? 0;

    _currentExerciseSetsLog.add(
      PerformedSet(setNumber: _currentSet, weight: weight, reps: reps),
    );

    _startRestTimer();
  }

  void _startRestTimer() {
    setState(() {
      _isResting = true;
      _restSeconds = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds > 0) {
        setState(() {
          _restSeconds--;
        });
      } else {
        _timer?.cancel();
        _moveToNext();
      }
    });
  }

  void _moveToNext() {
    setState(() {
      _isResting = false;
      final currentDailyExercise = widget.dailyExercises[_currentExerciseIndex];

      if (_currentSet < currentDailyExercise.sets) {
        _currentSet++;
        _repsController.clear(); 
      } else {
        final currentExerciseDetail = widget.allExercises.firstWhere((ex) => ex.id == currentDailyExercise.exerciseId);
        _performedExercisesLog.add(
          PerformedExercise(
            exerciseId: currentExerciseDetail.id,
            exerciseName: currentExerciseDetail.name,
            sets: List.from(_currentExerciseSetsLog),
          ),
        );
        _currentExerciseSetsLog.clear(); 

        if (_currentExerciseIndex < widget.dailyExercises.length - 1) {
          _currentExerciseIndex++;
          _currentSet = 1;
          _repsController.clear();
        } else {
          _finishWorkout();
        }
      }
    });
  }

  Future<void> _finishWorkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final firestoreService = FirestoreService();
      await firestoreService.addWorkoutHistory(
        uid: user.uid,
        planName: widget.planName,
        workoutName: widget.workoutName,
        dayCompleted: widget.currentDay,
        exercises: _performedExercisesLog,
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

  @override
  Widget build(BuildContext context) {
    if (_isResting) {
      return _buildRestScreen();
    }

    final currentDailyExercise = widget.dailyExercises[_currentExerciseIndex];
    final currentExerciseDetail = widget.allExercises.firstWhere(
      (ex) => ex.id == currentDailyExercise.exerciseId,
      orElse: () => Exercise(id: '', name: 'Not Found', description: '', bodyPart: '', equipment: '', gifUrl: '', target: '', instructions: []),
    );
    final secureGifUrl = currentExerciseDetail.gifUrl.replaceFirst('http://', 'https://');

    return Scaffold(
      appBar: AppBar(
        title: Text('Latihan ${_currentExerciseIndex + 1} / ${widget.dailyExercises.length}'),
        centerTitle: true,
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
              child: Image.network(
                secureGifUrl,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Center(child: Icon(Icons.fitness_center, size: 60)),
              ),
            ),
            const SizedBox(height: 24),

            Text(currentExerciseDetail.name, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Set $_currentSet dari ${currentDailyExercise.sets} ・ Target: ${currentDailyExercise.reps} repetisi',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: "Berat (kg)"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _repsController,
                    decoration: const InputDecoration(labelText: "Repetisi"),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _logSetAndStartRest,
              child: Text(
                (_currentExerciseIndex == widget.dailyExercises.length - 1 && _currentSet == currentDailyExercise.sets)
                    ? 'Selesaikan Latihan'
                    : 'Selesai & Istirahat',
              ),
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
                _moveToNext();
              },
              child: const Text('Lewati Istirahat', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}