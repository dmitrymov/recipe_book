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
  String _search = '';
  String? _categoryFilter;

  RecipesProvider({
    required this.store,
    required this.premiumService,
    required this.cloudSync,
  });

  List<Recipe> get recipes {
    var list = List<Recipe>.from(_recipes);

    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      list = list.where((r) => r.category == _categoryFilter).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((r) {
        final inName = r.name.toLowerCase().contains(q);
        final inCategory = r.category.toLowerCase().contains(q);
        final inIngredients = r.ingredients.any(
          (i) => i.name.toLowerCase().contains(q) || i.amount.toLowerCase().contains(q),
        );
        return inName || inCategory || inIngredients;
      }).toList();
    }

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
  String get search => _search;
  String? get categoryFilter => _categoryFilter;
  List<String> get categories {
    final list = _recipes.map((r) => r.category).toSet().toList();
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  Future<void> load() async {
    await store.init();
    // Ensure we always work with a growable list snapshot.
    _recipes = List<Recipe>.from(store.getAll());
    notifyListeners();
  }

  void setSort(RecipeSort s) {
    _sort = s;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void clearSearch() {
    _search = '';
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
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
