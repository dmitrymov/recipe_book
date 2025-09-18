import 'package:hive/hive.dart';
import 'ingredient.dart';

enum RecipeSort { name, category, products }

class Recipe {
  final String id; // uuid
  final String name;
  final String category; // e.g., Dessert, Main, etc.
  final List<Ingredient> ingredients;
  final List<String> steps;
  final String? imagePath; // local file path
  final DateTime createdAt;
  final DateTime updatedAt;

  const Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
  });

  Recipe copyWith({
    String? id,
    String? name,
    String? category,
    List<Ingredient>? ingredients,
    List<String>? steps,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 1;

  @override
  Recipe read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final category = reader.readString();
    final ingredientsLen = reader.readInt();
    final ingredients = <Ingredient>[];
    for (var i = 0; i < ingredientsLen; i++) {
      ingredients.add(reader.read() as Ingredient);
    }
    final stepsLen = reader.readInt();
    final steps = <String>[];
    for (var i = 0; i < stepsLen; i++) {
      steps.add(reader.readString());
    }
    final hasImage = reader.readBool();
    final imagePath = hasImage ? reader.readString() : null;
    final createdAtMillis = reader.readInt();
    final updatedAtMillis = reader.readInt();

    return Recipe(
      id: id,
      name: name,
      category: category,
      ingredients: ingredients,
      steps: steps,
      imagePath: imagePath,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMillis),
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.category);
    writer.writeInt(obj.ingredients.length);
    for (final ing in obj.ingredients) {
      writer.write(ing);
    }
    writer.writeInt(obj.steps.length);
    for (final s in obj.steps) {
      writer.writeString(s);
    }
    if (obj.imagePath != null) {
      writer.writeBool(true);
      writer.writeString(obj.imagePath!);
    } else {
      writer.writeBool(false);
    }
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.updatedAt.millisecondsSinceEpoch);
  }
}