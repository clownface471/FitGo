import 'package:flutter/material.dart';
import '../../models/motivation_model.dart';
import '../../utils/firestore_service.dart';

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  late Future<List<Motivation>> _motivationsFuture;

  @override
  void initState() {
    super.initState();
    _motivationsFuture = FirestoreService().getMotivations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Motivasi"),
      ),
      body: FutureBuilder<List<Motivation>>(
        future: _motivationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Konten motivasi belum tersedia."));
          }

          final motivations = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: motivations.length,
            itemBuilder: (context, index) {
              final item = motivations[index];
              if (item.type == 'profile') {
                return _ProfileCard(item: item);
              } else {
                return _QuoteCard(item: item);
              }
            },
          );
        },
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Motivation item;
  const _ProfileCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 140,
              color: Colors.grey[800],
              child: Image.network(item.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(item.content, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final Motivation item;
  const _QuoteCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[800],
              backgroundImage: NetworkImage(item.imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('"${item.content}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 4),
                  Text("- ${item.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}