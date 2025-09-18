import 'package:hive/hive.dart';

class Ingredient {
  final String name;
  final String amount; // e.g., "2 cups", "1 tbsp"

  const Ingredient({required this.name, required this.amount});

  Ingredient copyWith({String? name, String? amount}) {
    return Ingredient(
      name: name ?? this.name,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'amount': amount,
      };

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] as String? ?? '',
      amount: map['amount'] as String? ?? '',
    );
  }
}

class IngredientAdapter extends TypeAdapter<Ingredient> {
  @override
  final int typeId = 0;

  @override
  Ingredient read(BinaryReader reader) {
    final name = reader.readString();
    final amount = reader.readString();
    return Ingredient(name: name, amount: amount);
  }

  @override
  void write(BinaryWriter writer, Ingredient obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.amount);
  }
}
