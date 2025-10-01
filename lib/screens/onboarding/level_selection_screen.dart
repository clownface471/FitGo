import 'package:flutter/material.dart';
import 'metrics_screen.dart'; 

class LevelSelectionScreen extends StatefulWidget {
  final String goal; 
  const LevelSelectionScreen({super.key, required this.goal});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  String? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                "Bagaimana Tingkat Kebugaran Anda?",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "Ini membantu kami menentukan intensitas program Anda.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),

              _OptionCard(
                title: 'Pemula',
                subtitle: 'Baru memulai atau jarang berolahraga.',
                isSelected: _selectedLevel == 'beginner',
                onTap: () => setState(() => _selectedLevel = 'beginner'),
              ),
              const SizedBox(height: 16),
              _OptionCard(
                title: 'Menengah',
                subtitle: 'Berolahraga secara konsisten 2-3 kali seminggu.',
                isSelected: _selectedLevel == 'intermediate',
                onTap: () => setState(() => _selectedLevel = 'intermediate'),
              ),
              const SizedBox(height: 16),
              _OptionCard(
                title: 'Mahir',
                subtitle: 'Berpengalaman dan berolahraga lebih dari 3 kali seminggu.',
                isSelected: _selectedLevel == 'advanced',
                onTap: () => setState(() => _selectedLevel = 'advanced'),
              ),
              const Spacer(),

              ElevatedButton(
                onPressed: _selectedLevel == null ? null : () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => MetricsScreen(
                      goal: widget.goal,
                      level: _selectedLevel!,
                    ),
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

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Theme.of(context).primaryColor.withAlpha(77) : Theme.of(context).cardTheme.color,
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