import 'package:hive_flutter/hive_flutter.dart';

import '../models/recipe.dart';
import '../models/ingredient.dart';

class RecipeStore {
  static const String recipesBoxName = 'recipes_box_v1';

  Future<void> init() async {
    // Initialize Hive (hive_flutter chooses an appropriate directory).
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(IngredientAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(RecipeAdapter());

    await Hive.openBox<Recipe>(recipesBoxName);
  }

  Box<Recipe> get _box => Hive.box<Recipe>(recipesBoxName);

  List<Recipe> getAll() => _box.values.toList(growable: false);

  Future<void> put(Recipe recipe) async {
    await _box.put(recipe.id, recipe);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async => _box.clear();
}
