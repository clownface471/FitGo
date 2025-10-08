import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/daily_workout_model.dart';
import '../../models/exercise_model.dart';
import '../../models/performed_set_model.dart';
import '../../models/workout_history_model.dart';
import '../../providers/providers.dart';
import '../../utils/theme.dart';

class ExercisePlayerScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ExercisePlayerScreen> createState() =>
      _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends ConsumerState<ExercisePlayerScreen> {
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  bool _isResting = false;

  Timer? _timer;
  int _restSeconds = 30;

  final List<PerformedExercise> _performedExercisesLog = [];
  final List<PerformedSet> _currentExerciseSetsLog = [];
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  String? _currentNotes;

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
      PerformedSet(
        setNumber: _currentSet,
        weight: weight,
        reps: reps,
        notes: _currentNotes,
      ),
    );
    _currentNotes = null;

    _startRestTimer();
  }

  Future<void> _showNotesDialog() async {
    final notesController = TextEditingController(text: _currentNotes);
    final notes = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkCardColor,
        title: Text('Catatan untuk Set $_currentSet'),
        content: TextField(
          controller: notesController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Mis: Form bagus, angkat beban...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(notesController.text),
            child: const Text('Simpan', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );

    if (notes != null) {
      setState(() {
        _currentNotes = notes.trim().isEmpty ? null : notes.trim();
      });
    }
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
        final currentExerciseDetail = widget.allExercises
            .firstWhere((ex) => ex.name == currentDailyExercise.exerciseName);
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
    if (!mounted) return;

    final feedback = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: darkCardColor,
          title: const Text('Bagaimana Sesi Latihan Tadi?'),
          content: const Text(
              'Umpan balik Anda akan membantu kami menyesuaikan program ke depannya.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Terlalu Mudah',
                  style: TextStyle(color: Colors.green)),
              onPressed: () => Navigator.of(dialogContext).pop('easy'),
            ),
            TextButton(
              child: const Text('Cukup', style: TextStyle(color: primaryColor)),
              onPressed: () => Navigator.of(dialogContext).pop('good'),
            ),
            TextButton(
              child:
                  const Text('Terlalu Sulit', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(dialogContext).pop('hard'),
            ),
          ],
        );
      },
    );

    if (feedback == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final firestoreService = ref.read(firestoreServiceProvider);

      await firestoreService.addWorkoutHistory(
        uid: user.uid,
        planName: widget.planName,
        workoutName: widget.workoutName,
        dayCompleted: widget.currentDay,
        exercises: _performedExercisesLog,
        difficultyFeedback: feedback,
      );

      await firestoreService.updateUserProgressAfterWorkout(user.uid);

      ref.invalidate(userProvider);
      ref.invalidate(homeScreenDataProvider);
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
              child: const Text('Kembali ke Home',
                  style: TextStyle(color: primaryColor)),
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
      (ex) => ex.name == currentDailyExercise.exerciseName,
      orElse: () => Exercise(
        id: '',
        name: 'Not Found',
        description: '',
        bodyPart: '',
        equipment: '',
        gifUrl: '',
        primaryMuscles: [],
        secondaryMuscles: [],
        instructions: [],
      ),
    );
    final secureGifUrl =
        currentExerciseDetail.gifUrl.replaceFirst('http://', 'https://');

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Latihan ${_currentExerciseIndex + 1} / ${widget.dailyExercises.length}'),
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
                errorBuilder: (c, e, s) =>
                    const Center(child: Icon(Icons.fitness_center, size: 60)),
              ),
            ),
            const SizedBox(height: 24),
            Text(currentExerciseDetail.name,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center),
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
                IconButton(
                  icon: Icon(
                    _currentNotes == null
                        ? Icons.note_add_outlined
                        : Icons.note_alt,
                    color: _currentNotes == null ? Colors.grey : primaryColor,
                  ),
                  onPressed: _showNotesDialog,
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
              onPressed: _logSetAndStartRest,
              child: Text(
                (_currentExerciseIndex == widget.dailyExercises.length - 1 &&
                        _currentSet == currentDailyExercise.sets)
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
            const Text('ISTIRAHAT',
                style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: primaryColor)),
            const SizedBox(height: 20),
            Text('$_restSeconds',
                style:
                    const TextStyle(fontSize: 80, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                _timer?.cancel();
                _moveToNext();
              },
              child: const Text('Lewati Istirahat',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}