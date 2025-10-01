import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/daily_progress_model.dart';
import '../../models/user_model.dart';
import '../../models/diet_plan_model.dart';
import '../../models/recipe_model.dart';
import '../../utils/firestore_service.dart';
import '../diet/recipe_detail_screen.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final user = FirebaseAuth.instance.currentUser!;
    final firestore = FirestoreService();

    final results = await Future.wait([
      firestore.getUserData(user.uid),
      firestore.getAllRecipes(),
      firestore.getDailyProgress(user.uid),
    ]);

    final userData = results[0] as UserModel?;
    if (userData == null || userData.goal == null) {
      throw Exception("Data user tidak lengkap");
    }

    final dietPlan = await firestore.getRecommendedDietPlan(userData.goal!);

    return {
      'user': userData,
      'plan': dietPlan,
      'recipes': results[1] as List<Recipe>,
      'progress': results[2] as DailyProgress,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Rencana Makan Harian"), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                  child: Text("Gagal memuat data: ${snapshot.error}"));
            }

            final UserModel user = snapshot.data!['user'];
            final DietPlan? plan = snapshot.data!['plan'];
            final List<Recipe> recipes = snapshot.data!['recipes'];
            final DailyProgress progress = snapshot.data!['progress'];

            if (plan == null) {
              return const Center(
                  child: Text("Tidak ada rencana diet yang cocok."));
            }

            final dayToShow = (user.currentDay - 1) % plan.dailyMeals.length;
            final todayMealPlan = plan.dailyMeals[dayToShow];

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
                  onCompleted: () => _logMeal('breakfast', breakfastRecipe),
                ),
                const SizedBox(height: 16),
                _MealCard(
                  mealType: "Makan Siang",
                  recipe: lunchRecipe,
                  isCompleted: progress.lunchCompleted,
                  onCompleted: () => _logMeal('lunch', lunchRecipe),
                ),
                const SizedBox(height: 16),
                _MealCard(
                  mealType: "Makan Malam",
                  recipe: dinnerRecipe,
                  isCompleted: progress.dinnerCompleted,
                  onCompleted: () => _logMeal('dinner', dinnerRecipe),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _logMeal(String mealType, Recipe recipe) async {
    final user = FirebaseAuth.instance.currentUser!;

    final protein = int.tryParse(recipe.protein.replaceAll('g', '')) ?? 0;
    final carbs = int.tryParse(recipe.carbs.replaceAll('g', '')) ?? 0;
    final fat = int.tryParse(recipe.fat.replaceAll('g', '')) ?? 0;

    await FirestoreService().logMeal(
      uid: user.uid,
      mealType: mealType,
      calories: recipe.calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );

    _loadData();
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
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ));
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
              child: Image.network(
                recipe.imageUrl.replaceFirst('http://', 'https://'),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    const Icon(Icons.restaurant, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(mealType,
                          style: Theme.of(context).textTheme.titleMedium),
                      Checkbox(
                        value: isCompleted,
                        onChanged: isCompleted
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
                  Text(recipe.name,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                      "${recipe.calories} Kcal ・ P: ${recipe.protein}, C: ${recipe.carbs}, F: ${recipe.fat}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
