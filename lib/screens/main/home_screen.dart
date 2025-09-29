import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Hai, ${user?.email?.split('@')[0] ?? 'User'}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.signOut();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Lanjutkan Latihan
            _buildContinueCard(context),
            const SizedBox(height: 24),

            // Ringkasan Progres
            Text("Progres Mingguan", style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            _buildProgressSummary(),
            const SizedBox(height: 24),

            // Akses Cepat
            Text("Akses Cepat", style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            _buildQuickAccess(),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueCard(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Lanjutkan Latihan", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Bicep Workout - 12/15 Menit", style: TextStyle(color: Colors.black87)),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.play_circle_fill, color: Colors.black, size: 40),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummary() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _InfoTile(value: "3/5", label: "Sesi Selesai"),
            _InfoTile(value: "750", label: "Kcal Terbakar"),
            _InfoTile(value: "90", label: "Menit"),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccess() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _QuickAccessCard(icon: Icons.fitness_center, label: "Latihan", onTap: () {}),
        _QuickAccessCard(icon: Icons.restaurant_menu, label: "Diet", onTap: () {}),
        _QuickAccessCard(icon: Icons.bar_chart, label: "Laporan", onTap: () {}),
        _QuickAccessCard(icon: Icons.person, label: "Profil", onTap: () {}),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String value;
  final String label;
  const _InfoTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).primaryColor)),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAccessCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}