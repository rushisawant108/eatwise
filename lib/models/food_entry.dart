enum FoodCategory { healthy, moderate, junk }

class FoodEntry {
  final String id;
  final String name;
  final FoodCategory category;
  final int calories;
  final double fat;
  final double sugar;
  final double protein;
  final double cost;
  final DateTime timestamp;
  final String? notes;

  const FoodEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.fat,
    required this.sugar,
    required this.protein,
    required this.cost,
    required this.timestamp,
    this.notes,
  });

  bool get isJunk => category == FoodCategory.junk;
  bool get isHealthy => category == FoodCategory.healthy;
  bool get isLateNight {
    final hour = timestamp.hour;
    return hour >= 22 || hour < 4;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'calories': calories,
        'fat': fat,
        'sugar': sugar,
        'protein': protein,
        'cost': cost,
        'timestamp': timestamp.toIso8601String(),
        'notes': notes,
      };

  factory FoodEntry.fromJson(Map<String, dynamic> json) => FoodEntry(
        id: json['id'],
        name: json['name'],
        category: FoodCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => FoodCategory.moderate,
        ),
        calories: json['calories'],
        fat: (json['fat'] as num).toDouble(),
        sugar: (json['sugar'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        cost: (json['cost'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp']),
        notes: json['notes'],
      );
}
