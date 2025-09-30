import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../utils/theme.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        backgroundColor: darkBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              color: Colors.grey[800],
              child: Image.network(
                recipe.imageUrl.replaceFirst('http://', 'https://'),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const Icon(Icons.restaurant_menu, size: 60),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  _buildNutritionInfo(context),
                  const SizedBox(height: 24),

                  Text("Bahan-bahan", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...recipe.ingredients.map((ingredient) => _buildChecklistItem(ingredient)),
                  const SizedBox(height: 24),

                  Text("Cara Memasak", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...recipe.instructions.asMap().entries.map((entry) {
                    return _buildInstructionItem(
                      step: entry.key + 1,
                      text: entry.value,
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(BuildContext context) {
    return Card(
      color: darkCardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _InfoColumn(title: "Kalori", value: "${recipe.calories} kcal"),
            _InfoColumn(title: "Protein", value: recipe.protein),
            _InfoColumn(title: "Karbohidrat", value: recipe.carbs),
            _InfoColumn(title: "Lemak", value: recipe.fat),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_box_outline_blank, size: 20, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildInstructionItem({required int step, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: primaryColor,
            child: Text("$step", style: const TextStyle(color: darkTextColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;
  const _InfoColumn({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}