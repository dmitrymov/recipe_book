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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                expandedHeight: 280,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.of(context).pushNamed('/edit', arguments: recipeId),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (recipe.imagePath != null)
                        Image.file(
                          File(recipe.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.no_photography, size: 64),
                          ),
                        )
                      else
                        Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.no_photography, size: 64),
                        ),
                      // gradient overlay for readability
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black38],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.info_outline), text: 'Overview'),
                    Tab(icon: Icon(Icons.list_alt_outlined), text: 'Steps'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _OverviewTab(recipeId: recipeId),
              _StepsTab(recipeId: recipeId),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final String recipeId;
  const _OverviewTab({required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipesProvider>();
    final recipe = provider.recipes.firstWhere((r) => r.id == recipeId);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Chip(
              avatar: const Icon(Icons.category_outlined, size: 16),
              label: Text(recipe.category),
            ),
            const Spacer(),
            Text(
              '${recipe.ingredients.length} products',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Products', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        ...recipe.ingredients.map((i) => Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.check_circle_outline),
                title: Text(i.name),
                trailing: Text(i.amount),
              ),
            )),
      ],
    );
  }
}

class _StepsTab extends StatelessWidget {
  final String recipeId;
  const _StepsTab({required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipesProvider>();
    final recipe = provider.recipes.firstWhere((r) => r.id == recipeId);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final step = recipe.steps[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            child: Text('${index + 1}'),
          ),
          title: Text(step),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: recipe.steps.length,
    );
  }
}
