import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/auth_service.dart';
import '../../utils/firestore_service.dart';
import '../../utils/theme.dart';
import '../profile/edit_profile_screen.dart'; 

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  late Future<UserModel?> _userData;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userData = FirestoreService().getUserData(user.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        actions: [
          FutureBuilder<UserModel?>(
            future: _userData,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(user: snapshot.data!),
                      ),
                    );
                    if (result == true) {
                      _loadProfileData();
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadProfileData(),
        child: FutureBuilder<UserModel?>(
          future: _userData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("Gagal memuat data profil."));
            }

            final user = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Informasi Akun"),
                  _InfoCard(children: [_InfoTile(label: "Email", value: user.email)]),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Preferensi Latihan"),
                  _InfoCard(children: [
                    _InfoTile(label: "Tujuan Utama", value: user.goal?.replaceAll('_', ' ').toUpperCase() ?? '-'),
                    _InfoTile(label: "Tingkat Kebugaran", value: user.level?.toUpperCase() ?? '-'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Data Metrik"),
                  _InfoCard(children: [
                    _InfoTile(label: "Jenis Kelamin", value: user.gender?.toUpperCase() ?? '-'),
                    _InfoTile(label: "Umur", value: "${user.age ?? '-'} tahun"),
                    _InfoTile(label: "Tinggi Badan", value: "${user.height ?? '-'} cm"),
                    _InfoTile(label: "Berat Badan", value: "${user.weight ?? '-'} kg"),
                  ]),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => _authService.signOut(),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}