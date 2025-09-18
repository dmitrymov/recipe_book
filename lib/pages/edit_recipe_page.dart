import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../providers/recipes_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditRecipePage extends StatefulWidget {
  final String? recipeId;
  const EditRecipePage({super.key, this.recipeId});

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _CategoryPicker extends StatefulWidget {
  final TextEditingController controller;
  const _CategoryPicker({required this.controller});

  @override
  State<_CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<_CategoryPicker> {
  String? selected;
  final _newCategoryCtrl = TextEditingController();

  @override
  void dispose() {
    _newCategoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipesProvider>();
    final categories = provider.categories;

    final items = [
      DropdownMenuItem<String>(value: '__new__', child: Text(AppLocalizations.of(context)!.create_new_category)),
      ...categories.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: selected,
          items: items,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.category),
          onChanged: (val) {
            setState(() => selected = val);
          },
          validator: (v) {
            final value = v == '__new__' ? _newCategoryCtrl.text.trim() : (v ?? '').trim();
            return value.isEmpty ? AppLocalizations.of(context)!.required : null;
          },
        ),
        if (selected == '__new__')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
              controller: _newCategoryCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.new_category_name),
              onChanged: (v) {
                // Also update the main controller so save reads the right value
                widget.controller.text = v;
              },
              validator: (v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context)!.required : null,
            ),
          ),
        if (selected != '__new__' && selected != null)
          // keep the controller in sync with the selected category
          Offstage(
            offstage: true,
            child: TextFormField(
              controller: widget.controller..text = selected ?? '',
            ),
          ),
      ],
    );
  }
}

class _EditRecipePageState extends State<EditRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _stepCtrl = TextEditingController();
  final _ingredientNameCtrl = TextEditingController();
  final _ingredientAmountCtrl = TextEditingController();

  List<Ingredient> ingredients = [];
  List<String> steps = [];
  String? imagePath;

  @override
  void initState() {
    super.initState();
    final provider = context.read<RecipesProvider>();
    if (widget.recipeId != null) {
      final r = provider.recipes.firstWhere((e) => e.id == widget.recipeId);
      _nameCtrl.text = r.name;
      _categoryCtrl.text = r.category;
      ingredients = List.of(r.ingredients);
      steps = List.of(r.steps);
      imagePath = r.imagePath;
    } else {
      // default to first category if exists
      final cats = provider.categories;
      if (cats.isNotEmpty) _categoryCtrl.text = cats.first;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _stepCtrl.dispose();
    _ingredientNameCtrl.dispose();
    _ingredientAmountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeId == null ? AppLocalizations.of(context)!.create_recipe_title : AppLocalizations.of(context)!.edit_recipe),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.save,
            icon: const Icon(Icons.save_outlined),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              final now = DateTime.now();
              final id = widget.recipeId ?? now.microsecondsSinceEpoch.toString();
              final recipe = Recipe(
                id: id,
                name: _nameCtrl.text.trim(),
                category: _categoryCtrl.text.trim(),
                ingredients: ingredients,
                steps: steps,
                imagePath: imagePath,
                createdAt: now,
                updatedAt: now,
              );
              final navigator = Navigator.of(context); // capture before await
              await provider.addOrUpdate(recipe);
              navigator.pop();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
                    validator: (v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context)!.required : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CategoryPicker(
                    controller: _categoryCtrl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final path = await provider.pickImagePath();
                    if (path != null) setState(() => imagePath = path);
                  },
                  icon: const Icon(Icons.image_outlined),
                  label: Text(AppLocalizations.of(context)!.pick_image),
                ),
                const SizedBox(width: 12),
                if (imagePath != null) Text('Selected: ${imagePath!.split('\\').last.split('/').last}'),
              ],
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.products, style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientNameCtrl,
                    decoration: InputDecoration(hintText: AppLocalizations.of(context)!.ingredient),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _ingredientAmountCtrl,
                    decoration: InputDecoration(hintText: AppLocalizations.of(context)!.amount),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    final n = _ingredientNameCtrl.text.trim();
                    final a = _ingredientAmountCtrl.text.trim();
                    if (n.isEmpty || a.isEmpty) return;
                    setState(() {
                      ingredients.add(Ingredient(name: n, amount: a));
                      _ingredientNameCtrl.clear();
                      _ingredientAmountCtrl.clear();
                    });
                  },
                )
              ],
            ),
            ...ingredients.asMap().entries.map(
              (e) => ListTile(
                dense: true,
                title: Text(e.value.name),
                subtitle: Text(e.value.amount),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => ingredients.removeAt(e.key)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.steps, style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stepCtrl,
                    decoration: InputDecoration(hintText: '${AppLocalizations.of(context)!.steps}...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    final s = _stepCtrl.text.trim();
                    if (s.isEmpty) return;
                    setState(() {
                      steps.add(s);
                      _stepCtrl.clear();
                    });
                  },
                )
              ],
            ),
            ...steps.asMap().entries.map(
              (e) => ListTile(
                dense: true,
                leading: CircleAvatar(radius: 12, child: Text('${e.key + 1}', style: const TextStyle(fontSize: 12))),
                title: Text(e.value),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => steps.removeAt(e.key)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
