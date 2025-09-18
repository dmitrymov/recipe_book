import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recipes_provider.dart';
import '../models/recipe.dart';

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 1, vsync: this);
    // Load data without awaiting; safe to call in initState.
    final rp = context.read<RecipesProvider>();
    rp.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Book'),
        actions: [
          IconButton(
            tooltip: 'Account',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/account'),
          ),
          PopupMenuButton<RecipeSort>(
            tooltip: 'Sort',
            onSelected: (s) => context.read<RecipesProvider>().setSort(s),
            itemBuilder: (context) => const [
              PopupMenuItem(value: RecipeSort.name, child: Text('Sort by name')),
              PopupMenuItem(value: RecipeSort.category, child: Text('Sort by category')),
              PopupMenuItem(value: RecipeSort.products, child: Text('Sort by products count')),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
        bottom: TabBar(
          controller: _controller,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_outlined), text: 'Catalog'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: const [
          _CatalogTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/edit'),
        tooltip: 'Create recipe',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CatalogTab extends StatelessWidget {
  const _CatalogTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipesProvider>();
    final recipes = provider.recipes;

    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No recipes yet'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/edit'),
              icon: const Icon(Icons.add),
              label: const Text('Create your first recipe'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Category filter
              DropdownButton<String?>(
                value: provider.categoryFilter,
                hint: const Text('All categories'),
                onChanged: (val) => provider.setCategoryFilter(val),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('All categories')),
                  ...provider.categories.map((c) => DropdownMenuItem<String?>(value: c, child: Text(c))),
                ],
              ),
              const SizedBox(width: 12),
              // Search field
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    hintText: 'Search recipes, categories, products...',
                    suffixIcon: provider.search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => provider.clearSearch(),
                          )
                        : null,
                  ),
                  onChanged: provider.setSearch,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, i) {
              final r = recipes[i];
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
          onTap: () => Navigator.of(context).pushNamed('/detail', arguments: r.id),
        );
      },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: recipes.length,
          ),
        ),
      ],
    );
  }
}

