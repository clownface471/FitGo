import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/daily_progress_model.dart';
import '../../models/user_model.dart';
import '../../models/diet_plan_model.dart';
import '../../models/recipe_model.dart';
import '../../providers/providers.dart';
import '../diet/recipe_detail_screen.dart';

class DietScreen extends ConsumerWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataFuture = ref.watch(dietScreenDataProvider);

    return Scaffold(
      appBar:
          AppBar(title: const Text("Rencana Makan Harian"), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dietScreenDataProvider),
        child: dataFuture.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Gagal memuat data: $err")),
          data: (data) {
            final UserModel user = data['user'];
            final DietPlan? plan = data['plan'];
            final List<Recipe> recipes = data['recipes'];
            final DailyProgress progress = data['progress'];

            if (plan == null) {
              return const Center(
                  child: Text("Tidak ada rencana diet yang cocok."));
            }
            
            int dayToShow = 1;
            if (user.planStartDate != null) {
              final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
              final startDate = DateTime(user.planStartDate!.year, user.planStartDate!.month, user.planStartDate!.day);
              dayToShow = today.difference(startDate).inDays + 1;
            }

            final dayInCycle = (dayToShow - 1) % plan.dailyMeals.length;
            final todayMealPlan = plan.dailyMeals[dayInCycle];

            final breakfastRecipe = recipes.firstWhere(
                (r) => r.id == todayMealPlan.breakfast.recipeId,
                orElse: _fallbackRecipe);
            final lunchRecipe = recipes.firstWhere(
                (r) => r.id == todayMealPlan.lunch.recipeId,
                orElse: _fallbackRecipe);
            final dinnerRecipe = recipes.firstWhere(
                (r) => r.id == todayMealPlan.dinner.recipeId,
                orElse: _fallbackRecipe);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MealCard(
                  mealType: "Sarapan",
                  recipe: breakfastRecipe,
                  isCompleted: progress.breakfastCompleted,
                  onCompleted: () => _logMeal(ref, 'breakfast', breakfastRecipe),
                ),
                const SizedBox(height: 16),
                _MealCard(
                  mealType: "Makan Siang",
                  recipe: lunchRecipe,
                  isCompleted: progress.lunchCompleted,
                  onCompleted: () => _logMeal(ref, 'lunch', lunchRecipe),
                ),
                const SizedBox(height: 16),
                _MealCard(
                  mealType: "Makan Malam",
                  recipe: dinnerRecipe,
                  isCompleted: progress.dinnerCompleted,
                  onCompleted: () => _logMeal(ref, 'dinner', dinnerRecipe),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _logMeal(WidgetRef ref, String mealType, Recipe recipe) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final protein = int.tryParse(recipe.protein.replaceAll('g', '')) ?? 0;
    final carbs = int.tryParse(recipe.carbs.replaceAll('g', '')) ?? 0;
    final fat = int.tryParse(recipe.fat.replaceAll('g', '')) ?? 0;

    await ref.read(firestoreServiceProvider).logMeal(
          uid: user.uid,
          mealType: mealType,
          calories: recipe.calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
        );
    
    ref.invalidate(dietScreenDataProvider);
    ref.invalidate(homeScreenDataProvider);
  }

  Recipe _fallbackRecipe() {
    return Recipe(
        id: '',
        name: 'Resep tidak ditemukan',
        imageUrl: '',
        calories: 0,
        protein: '0',
        carbs: '0',
        fat: '0',
        ingredients: [],
        instructions: []);
  }
}

class _MealCard extends StatelessWidget {
  final String mealType;
  final Recipe recipe;
  final bool isCompleted;
  final VoidCallback onCompleted;

  const _MealCard({
    required this.mealType,
    required this.recipe,
    required this.isCompleted,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (recipe.id.isNotEmpty) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailScreen(recipe: recipe),
              ));
        }
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[800],
              child: recipe.imageUrl.isNotEmpty
                  ? Image.network(
                      recipe.imageUrl.replaceFirst('http://', 'https://'),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          const Icon(Icons.restaurant, size: 50),
                    )
                  : const Icon(Icons.restaurant, size: 50),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(mealType, style: Theme.of(context).textTheme.titleMedium),
                      Checkbox(
                        value: isCompleted,
                        onChanged: isCompleted || recipe.id.isEmpty
                            ? null
                            : (bool? value) {
                                if (value == true) {
                                  onCompleted();
                                }
                              },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  Text(recipe.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  if (recipe.id.isNotEmpty)
                    Text("${recipe.calories} Kcal ・ P: ${recipe.protein}, C: ${recipe.carbs}, F: ${recipe.fat}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}