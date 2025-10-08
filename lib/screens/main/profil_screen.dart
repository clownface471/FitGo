import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../models/user_progress_model.dart';
import '../../providers/providers.dart';
import '../../utils/theme.dart';
import '../profile/edit_profile_screen.dart';

class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userProvider);
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        actions: [
          userData.when(
            data: (user) {
              if (user != null) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(user: user),
                      ),
                    );
                    if (result == true) {
                      ref.invalidate(userProvider);
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(userProvider),
        child: userData.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text("Gagal memuat data profil."));
            }
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(context, user),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, "Progres & Pencapaian"),
                  _buildGamificationCard(context, user.progress),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, "Informasi Akun"),
                  _InfoCard(
                      children: [_InfoTile(label: "Email", value: user.email)]),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, "Preferensi Latihan"),
                  _InfoCard(children: [
                    _InfoTile(
                        label: "Tujuan Utama",
                        value: user.goal?.replaceAll('_', ' ').toUpperCase() ??
                            '-'),
                    _InfoTile(
                        label: "Tingkat Kebugaran",
                        value: user.level?.toUpperCase() ?? '-'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, "Data Metrik"),
                  _InfoCard(children: [
                    _InfoTile(
                        label: "Jenis Kelamin",
                        value: user.gender?.toUpperCase() ?? '-'),
                    _InfoTile(
                        label: "Umur", value: "${user.age ?? '-'} tahun"),
                    _InfoTile(
                        label: "Tinggi Badan",
                        value: "${user.height ?? '-'} cm"),
                    _InfoTile(
                        label: "Berat Badan",
                        value: "${user.weight ?? '-'} kg"),
                  ]),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => authService.signOut(),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text("Error: ${err.toString()}")),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: darkCardColor,
            child: Icon(Icons.person, size: 50, color: primaryColor),
          ),
          const SizedBox(height: 12),
          Text(
            user.email.split('@')[0],
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildGamificationCard(BuildContext context, UserProgress progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatColumn(
              icon: Icons.local_fire_department,
              value: progress.currentStreak.toString(),
              label: "Hari Beruntun",
              color: Colors.orange,
            ),
            _StatColumn(
              icon: Icons.star,
              value: progress.longestStreak.toString(),
              label: "Rekor Beruntun",
              color: Colors.amber,
            ),
            _StatColumn(
              icon: Icons.fitness_center,
              value: progress.totalWorkouts.toString(),
              label: "Total Latihan",
              color: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}