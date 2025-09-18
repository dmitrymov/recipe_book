import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/recipes_provider.dart';
import 'recipe_detail_page.dart';

class RecipesListPage extends StatelessWidget {
  const RecipesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipesProvider>();
    final recipes = provider.recipes;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Text('Sort by:'),
              const SizedBox(width: 8),
              DropdownButton<RecipeSort>(
                value: provider.sort,
                onChanged: (v) {
                  if (v != null) provider.setSort(v);
                },
                items: const [
                  DropdownMenuItem(value: RecipeSort.name, child: Text('Name')),
                  DropdownMenuItem(value: RecipeSort.category, child: Text('Category')),
                  DropdownMenuItem(value: RecipeSort.products, child: Text('Products count')),
                ],
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Create recipe',
                onPressed: () async {
                  Navigator.of(context).pushNamed('/edit');
                },
                icon: const Icon(Icons.add_circle_outline),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: recipes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final r = recipes[index];
              return ListTile(
                leading: r.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          File(r.imagePath!),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.no_photography),
                        ),
                      )
                    : const CircleAvatar(child: Icon(Icons.restaurant_menu)),
                title: Text(r.name),
                subtitle: Text('${r.category} • ${r.ingredients.length} products'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => RecipeDetailPage(recipeId: r.id)),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => provider.delete(r.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
