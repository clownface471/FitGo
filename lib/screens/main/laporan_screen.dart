import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../../models/workout_history_model.dart';
import '../../utils/firestore_service.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  late Future<List<WorkoutHistory>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _historyFuture = FirestoreService().getWorkoutHistory(user.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Latihan'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadHistory(),
        child: FutureBuilder<List<WorkoutHistory>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Gagal memuat riwayat."));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Anda belum menyelesaikan latihan apapun.\nSelesaikan satu sesi untuk melihatnya di sini.",
                  textAlign: TextAlign.center,
                ),
              );
            }

            final historyList = snapshot.data!;

            return ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final history = historyList[index];
                final formattedDate = DateFormat('EEEE, d MMMM y', 'id_ID').format(history.completedDate);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                    title: Text(history.workoutName),
                    subtitle: Text(history.planName),
                    trailing: Text(
                      'Hari ke-${history.dayCompleted}\n$formattedDate',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}