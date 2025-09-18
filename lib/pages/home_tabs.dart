import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recipes_provider.dart';
import '../models/recipe.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

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
    // Load data
    final rp = context.read<RecipesProvider>();
    rp.load();

    // Ask for language on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final lp = context.read<LocaleProvider>();
      final chosen = await lp.isLanguageChosen();
      if (!chosen && mounted) {
        _showLanguageDialog(context);
      }
    });
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
        title: Text(AppLocalizations.of(context)!.app_title),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.account,
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/account'),
          ),
          PopupMenuButton<RecipeSort>(
            tooltip: AppLocalizations.of(context)!.sort,
            onSelected: (s) => context.read<RecipesProvider>().setSort(s),
            itemBuilder: (context) => [
              PopupMenuItem(value: RecipeSort.name, child: Text(AppLocalizations.of(context)!.sort_by_name)),
              PopupMenuItem(value: RecipeSort.category, child: Text(AppLocalizations.of(context)!.sort_by_category)),
              PopupMenuItem(value: RecipeSort.products, child: Text(AppLocalizations.of(context)!.sort_by_products)),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
        bottom: TabBar(
          controller: _controller,
          tabs: [
            Tab(icon: const Icon(Icons.menu_book_outlined), text: AppLocalizations.of(context)!.catalog),
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
        tooltip: AppLocalizations.of(context)!.create_recipe,
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
            Text(AppLocalizations.of(context)!.no_recipes),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/edit'),
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.create_first_recipe),
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
                hint: Text(AppLocalizations.of(context)!.all_categories),
                onChanged: (val) => provider.setCategoryFilter(val),
                items: [
                  DropdownMenuItem<String?>(value: null, child: Text(AppLocalizations.of(context)!.all_categories)),
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
                    hintText: AppLocalizations.of(context)!.search_hint,
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

void _showLanguageDialog(BuildContext context) async {
  final appLoc = AppLocalizations.of(context)!;
  final lp = context.read<LocaleProvider>();
  final supported = const [Locale('en'), Locale('fr'), Locale('he')];

  // Default selection: system if supported, else English
  Locale? system = WidgetsBinding.instance.platformDispatcher.locale;
  Locale? defaultLocale = supported.firstWhere(
    (l) => l.languageCode == system.languageCode,
    orElse: () => const Locale('en'),
  );

  Locale? selected = lp.locale ?? defaultLocale;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: Text(appLoc.language),
        content: StatefulBuilder(
          builder: (ctx, setState) => DropdownButton<Locale?>(
            value: selected,
            onChanged: (val) => setState(() => selected = val ?? defaultLocale),
            items: const [
              DropdownMenuItem<Locale?>(value: Locale('en'), child: Text('English')),
              DropdownMenuItem<Locale?>(value: Locale('fr'), child: Text('Français')),
              DropdownMenuItem<Locale?>(value: Locale('he'), child: Text('עברית')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(appLoc.save),
          )
        ],
      );
    },
  );

  // Apply chosen locale
  await lp.setLocale(selected);
}

