import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

import '../models/recipe.dart';
import '../services/cloud_sync_service.dart';
import '../services/premium_service.dart';
import '../services/recipe_store.dart';

class RecipesProvider extends ChangeNotifier {
  final RecipeStore store;
  final PremiumService premiumService;
  final CloudSyncService cloudSync;

  List<Recipe> _recipes = [];
  RecipeSort _sort = RecipeSort.name;

  RecipesProvider({
    required this.store,
    required this.premiumService,
    required this.cloudSync,
  });

  List<Recipe> get recipes {
    final list = List<Recipe>.from(_recipes);
    switch (_sort) {
      case RecipeSort.name:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case RecipeSort.category:
        list.sort((a, b) => a.category.toLowerCase().compareTo(b.category.toLowerCase()));
        break;
      case RecipeSort.products:
        list.sort((a, b) => a.ingredients.length.compareTo(b.ingredients.length));
        break;
    }
    return list;
  }

  RecipeSort get sort => _sort;

  Future<void> load() async {
    await store.init();
    _recipes = store.getAll();
    notifyListeners();
  }

  void setSort(RecipeSort s) {
    _sort = s;
    notifyListeners();
  }

  Future<void> addOrUpdate(Recipe r) async {
    await store.put(r);
    final idx = _recipes.indexWhere((x) => x.id == r.id);
    if (idx == -1) {
      _recipes.add(r);
    } else {
      _recipes[idx] = r;
    }
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await store.delete(id);
    _recipes.removeWhere((x) => x.id == id);
    notifyListeners();
  }

  Future<void> syncToCloud() async {
    if (!premiumService.isPaid) return;
    await cloudSync.uploadRecipes(_recipes);
  }

  void purchasePremium() {
    premiumService.purchase();
    notifyListeners();
  }

  Future<void> syncFromCloud() async {
    if (!premiumService.isPaid) return;
    final downloaded = await cloudSync.downloadRecipes();
    for (final r in downloaded) {
      await store.put(r);
    }
    _recipes = store.getAll();
    notifyListeners();
  }

  Future<String?> pickImagePath() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: false);
      if (result == null || result.files.isEmpty) return null;
      final path = result.files.single.path;
      return path;
    } catch (e) {
      if (kDebugMode) {
        print('Image pick error: $e');
      }
      return null;
    }
  }
}
