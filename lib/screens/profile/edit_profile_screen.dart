import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/firestore_service.dart';
import '../../utils/theme.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late String _selectedGoal;
  late String _selectedLevel;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(text: widget.user.height?.toString() ?? '');
    _weightController = TextEditingController(text: widget.user.weight?.toString() ?? '');
    _selectedGoal = widget.user.goal ?? 'fat_loss';
    _selectedLevel = widget.user.level ?? 'beginner';
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final Map<String, dynamic> updatedData = {
        'height': int.tryParse(_heightController.text) ?? 0,
        'weight': int.tryParse(_weightController.text) ?? 0,
        'goal': _selectedGoal,
        'level': _selectedLevel,
      };

      await FirestoreService().updateUserOnboardingData(uid: uid, data: updatedData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: primaryColor),
            onPressed: _saveProfile,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Data Metrik", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: "Tinggi Badan (cm)"),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: "Berat Badan (kg)"),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Tidak boleh kosong' : null,
              ),
              const SizedBox(height: 32),
              Text("Preferensi Latihan", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildDropdown("Tujuan Utama", _selectedGoal, ['fat_loss', 'muscle_gain', 'general_fitness'], (val) {
                setState(() => _selectedGoal = val!);
              }),
              const SizedBox(height: 16),
              _buildDropdown("Tingkat Kebugaran", _selectedLevel, ['beginner', 'intermediate', 'advanced'], (val) {
                setState(() => _selectedLevel = val!);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item.replaceAll('_', ' ').toUpperCase()),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}