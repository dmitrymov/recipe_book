import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/home_tabs.dart';
import 'pages/recipe_detail_page.dart';
import 'pages/edit_recipe_page.dart';
import 'pages/account_page.dart';
import 'providers/recipes_provider.dart';
import 'services/recipe_store.dart';
import 'services/premium_service.dart';
import 'services/cloud_sync_service.dart';

void main() {
  runApp(const RecipeBookApp());
}

class RecipeBookApp extends StatelessWidget {
  const RecipeBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RecipesProvider(
            store: RecipeStore(),
            premiumService: PremiumService(),
            cloudSync: CloudSyncService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Recipe Book',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const HomeTabs(),
        onGenerateRoute: (settings) {
          if (settings.name == '/detail') {
            final id = settings.arguments as String;
            return MaterialPageRoute(builder: (_) => RecipeDetailPage(recipeId: id));
          }
          if (settings.name == '/edit') {
            final id = settings.arguments as String?;
            return MaterialPageRoute(builder: (_) => EditRecipePage(recipeId: id));
          }
          if (settings.name == '/account') {
            return MaterialPageRoute(builder: (_) => const AccountPage());
          }
          return null;
        },
      ),
    );
  }
}
