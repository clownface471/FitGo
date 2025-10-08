import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/motivation_model.dart';
import '../../providers/providers.dart';

class MotivationScreen extends ConsumerWidget {
  const MotivationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motivationsFuture = ref.watch(motivationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Motivasi"),
      ),
      body: motivationsFuture.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text("Konten motivasi belum tersedia.")),
        data: (motivations) {
          if (motivations.isEmpty) {
            return const Center(child: Text("Konten motivasi belum tersedia."));
          }
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
              onBackgroundImageError: (e, s) => const Icon(Icons.person),
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