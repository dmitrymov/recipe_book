import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../providers/recipes_provider.dart';

class EditRecipePage extends StatefulWidget {
  final String? recipeId;
  const EditRecipePage({super.key, this.recipeId});

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
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
        title: Text(widget.recipeId == null ? 'Create Recipe' : 'Edit Recipe'),
        actions: [
          IconButton(
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
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _categoryCtrl,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
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
                  label: const Text('Pick image'),
                ),
                const SizedBox(width: 12),
                if (imagePath != null) Text('Selected: ${imagePath!.split('\\').last.split('/').last}'),
              ],
            ),
            const SizedBox(height: 16),
            Text('Products', style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientNameCtrl,
                    decoration: const InputDecoration(hintText: 'Ingredient'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _ingredientAmountCtrl,
                    decoration: const InputDecoration(hintText: 'Amount'),
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
            Text('Steps', style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stepCtrl,
                    decoration: const InputDecoration(hintText: 'Add a step...'),
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
