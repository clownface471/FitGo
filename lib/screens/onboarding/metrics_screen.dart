import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/firestore_service.dart';
import '../../utils/theme.dart';
import '../main/main_screen.dart';

class MetricsScreen extends StatefulWidget {
  final String goal;
  final String level;

  const MetricsScreen({
    super.key,
    required this.goal,
    required this.level,
  });

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  String _selectedGender = 'male';
  int _age = 25;
  int _height = 170;
  int _weight = 65;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Lengkapi Profil Anda",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),

              _buildGenderSelector(),
              const SizedBox(height: 24),

              Expanded(
                child: Row(
                  children: [
                    _buildPicker("UMUR", _age, 10, 80, (newValue) => setState(() => _age = newValue)),
                    _buildPicker("TINGGI (cm)", _height, 120, 220, (newValue) => setState(() => _height = newValue)),
                    _buildPicker("BERAT (kg)", _weight, 40, 150, (newValue) => setState(() => _weight = newValue)),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), 
                ),
                onPressed: _finishOnboarding,
                child: const Text('Selesai & Mulai'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final Map<String, dynamic> userData = {
      'goal': widget.goal,
      'level': widget.level,
      'gender': _selectedGender,
      'age': _age,
      'height': _height,
      'weight': _weight,
      'onboardingCompleted': true, 
    };

    await FirestoreService().updateUserOnboardingData(uid: user.uid, data: userData);
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Widget _buildGenderSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _GenderButton(
          label: "Pria",
          isSelected: _selectedGender == 'male',
          onTap: () => setState(() => _selectedGender = 'male'),
        ),
        const SizedBox(width: 20),
        _GenderButton(
          label: "Wanita",
          isSelected: _selectedGender == 'female',
          onTap: () => setState(() => _selectedGender = 'female'),
        ),
      ],
    );
  }

  Widget _buildPicker(String label, int currentValue, int minValue, int maxValue, ValueChanged<int> onChanged) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController: FixedExtentScrollController(initialItem: currentValue - minValue),
              onSelectedItemChanged: (index) => onChanged(index + minValue),
              children: List.generate(maxValue - minValue + 1, (index) {
                return Center(
                  child: Text(
                    '${index + minValue}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? primaryColor : darkCardColor,
        foregroundColor: isSelected ? darkTextColor : lightTextColor,
        fixedSize: const Size(120, 50), 
      ),
      child: Text(label),
    );
  }
}