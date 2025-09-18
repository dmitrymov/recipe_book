import '../models/recipe.dart';

class CloudSyncService {
  Future<void> uploadRecipes(List<Recipe> recipes) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // In a real app, POST to your backend or cloud storage here.
  }

  Future<List<Recipe>> downloadRecipes() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Stub returns an empty list for now.
    return [];
  }
}
