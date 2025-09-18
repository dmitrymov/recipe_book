import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/recipes_provider.dart';
import '../models/recipe.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                    tooltip: 'Share',
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {
                      final text = _shareText(recipe);
                      // ignore: deprecated_member_use
                      Share.share(text);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.of(context).pushNamed('/edit', arguments: recipeId),
                  ),
                ],
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
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
                        // top gradient for title readability
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black54, Colors.transparent, Colors.black38],
                              stops: [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                        // Title at the top of the image
                        Positioned(
                          left: 16,
                          right: 16,
                          top: MediaQuery.of(context).padding.top + 8,
                          child: Text(
                            recipe.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  shadows: const [
                                    Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black54),
                                  ],
                                ) ??
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                bottom: TabBar(
                  tabs: [
                    Tab(icon: const Icon(Icons.info_outline), text: AppLocalizations.of(context)!.overview),
                    Tab(icon: const Icon(Icons.list_alt_outlined), text: AppLocalizations.of(context)!.steps),
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

// Build shareable text for the recipe
String _shareText(Recipe recipe) {
  final b = StringBuffer();
  b.writeln('Recipe: ${recipe.name}');
  b.writeln('Category: ${recipe.category}');
  b.writeln('');
  b.writeln('Products:');
  for (final i in recipe.ingredients) {
    b.writeln('- ${i.name} — ${i.amount}');
  }
  b.writeln('');
  b.writeln('Steps:');
  for (var i = 0; i < recipe.steps.length; i++) {
    b.writeln('${i + 1}. ${recipe.steps[i]}');
  }
  return b.toString();
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
              '${recipe.ingredients.length} ${AppLocalizations.of(context)!.products.toLowerCase()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(AppLocalizations.of(context)!.products, style: Theme.of(context).textTheme.titleMedium),
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

      if (recipe.steps.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.no_steps_yet,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final step = recipe.steps[index];
        return Card(
          elevation: 0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              child: Text('${index + 1}'),
            ),
            title: Text(step),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: recipe.steps.length,
    );
  }
}
