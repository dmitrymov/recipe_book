import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recipes_provider.dart';

class RecipeDetailPage extends StatelessWidget {
  final String recipeId;
  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipesProvider>();
    final recipe = provider.recipes.firstWhere((r) => r.id == recipeId);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/edit', arguments: recipeId),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (recipe.imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(recipe.imagePath!),
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.no_photography),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            recipe.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            recipe.category,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          Text('Products', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          ...recipe.ingredients.map((i) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle_outline),
                title: Text(i.name),
                trailing: Text(i.amount),
              )),
          const SizedBox(height: 16),
          Text('Steps', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          ...recipe.steps.asMap().entries.map((e) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 12,
                  child: Text('${e.key + 1}', style: const TextStyle(fontSize: 12)),
                ),
                title: Text(e.value),
              )),
        ],
      ),
    );
  }
}
