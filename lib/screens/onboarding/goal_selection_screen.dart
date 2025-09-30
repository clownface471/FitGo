import 'package:flutter/material.dart';
import 'level_selection_screen.dart';

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  String? _selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                "Apa Tujuan Utama Anda?",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "Ini akan membantu kami menyusun program yang dipersonalisasi untuk Anda.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),

              _GoalOptionCard(
                title: 'Membentuk Otot',
                subtitle: 'Fokus pada kekuatan dan hipertrofi.',
                isSelected: _selectedGoal == 'muscle_gain',
                onTap: () => setState(() => _selectedGoal = 'muscle_gain'),
              ),
              const SizedBox(height: 16),
              _GoalOptionCard(
                title: 'Menurunkan Berat Badan',
                subtitle: 'Membakar lemak dan meningkatkan kardio.',
                isSelected: _selectedGoal == 'fat_loss',
                onTap: () => setState(() => _selectedGoal = 'fat_loss'),
              ),
              const SizedBox(height: 16),
              _GoalOptionCard(
                title: 'Menjaga Kebugaran',
                subtitle: 'Tetap aktif dan sehat secara keseluruhan.',
                isSelected: _selectedGoal == 'general_fitness',
                onTap: () => setState(() => _selectedGoal = 'general_fitness'),
              ),
              const Spacer(),

              ElevatedButton(
                onPressed: _selectedGoal == null ? null : () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => LevelSelectionScreen(goal: _selectedGoal!), 
                  ));
                },
                child: const Text('Lanjutkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _GoalOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalOptionCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.3) : Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}