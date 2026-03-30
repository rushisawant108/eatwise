import '../models/food_entry.dart';

class FoodDatabase {
  static const List<Map<String, dynamic>> _items = [
    // ──────────────────── JUNK FOODS ────────────────────
    {'name': 'Pizza (2 slices)', 'category': 'junk', 'calories': 560, 'fat': 22.0, 'sugar': 8.0, 'protein': 22.0, 'cost': 250.0},
    {'name': 'Burger', 'category': 'junk', 'calories': 490, 'fat': 24.0, 'sugar': 10.0, 'protein': 18.0, 'cost': 150.0},
    {'name': 'French Fries (large)', 'category': 'junk', 'calories': 480, 'fat': 23.0, 'sugar': 1.0, 'protein': 6.0, 'cost': 120.0},
    {'name': 'Samosa (2 pcs)', 'category': 'junk', 'calories': 310, 'fat': 16.0, 'sugar': 2.0, 'protein': 5.0, 'cost': 30.0},
    {'name': 'Biryani (Restaurant)', 'category': 'junk', 'calories': 650, 'fat': 28.0, 'sugar': 4.0, 'protein': 30.0, 'cost': 220.0},
    {'name': 'Chips (1 packet)', 'category': 'junk', 'calories': 280, 'fat': 18.0, 'sugar': 1.5, 'protein': 3.0, 'cost': 30.0},
    {'name': 'Cold Drink (500ml)', 'category': 'junk', 'calories': 210, 'fat': 0.0, 'sugar': 52.0, 'protein': 0.0, 'cost': 40.0},
    {'name': 'Pav Bhaji', 'category': 'junk', 'calories': 520, 'fat': 20.0, 'sugar': 6.0, 'protein': 12.0, 'cost': 100.0},
    {'name': 'Vada Pav', 'category': 'junk', 'calories': 290, 'fat': 12.0, 'sugar': 3.0, 'protein': 6.0, 'cost': 25.0},
    {'name': 'Maggi Noodles', 'category': 'junk', 'calories': 350, 'fat': 14.0, 'sugar': 2.0, 'protein': 8.0, 'cost': 20.0},
    {'name': 'Chole Bhature', 'category': 'junk', 'calories': 580, 'fat': 26.0, 'sugar': 5.0, 'protein': 14.0, 'cost': 80.0},
    {'name': 'Gulab Jamun (2 pcs)', 'category': 'junk', 'calories': 360, 'fat': 14.0, 'sugar': 48.0, 'protein': 5.0, 'cost': 40.0},
    {'name': 'Ice Cream (1 scoop)', 'category': 'junk', 'calories': 270, 'fat': 14.0, 'sugar': 28.0, 'protein': 3.0, 'cost': 60.0},

    // ──────────────────── MODERATE FOODS ────────────────────
    {'name': 'Paneer Butter Masala', 'category': 'moderate', 'calories': 380, 'fat': 18.0, 'sugar': 6.0, 'protein': 16.0, 'cost': 160.0},
    {'name': 'Egg Bhurji', 'category': 'moderate', 'calories': 280, 'fat': 16.0, 'sugar': 2.0, 'protein': 18.0, 'cost': 60.0},
    {'name': 'Rajma Chawal', 'category': 'moderate', 'calories': 430, 'fat': 8.0, 'sugar': 4.0, 'protein': 18.0, 'cost': 80.0},
    {'name': 'Chicken Curry + Rice', 'category': 'moderate', 'calories': 520, 'fat': 18.0, 'sugar': 4.0, 'protein': 32.0, 'cost': 150.0},
    {'name': 'Masala Dosa', 'category': 'moderate', 'calories': 340, 'fat': 10.0, 'sugar': 3.0, 'protein': 8.0, 'cost': 70.0},
    {'name': 'Upma', 'category': 'moderate', 'calories': 240, 'fat': 6.0, 'sugar': 2.0, 'protein': 6.0, 'cost': 40.0},
    {'name': 'Aloo Paratha (2 pcs)', 'category': 'moderate', 'calories': 420, 'fat': 14.0, 'sugar': 2.0, 'protein': 10.0, 'cost': 60.0},

    // ──────────────────── HEALTHY FOODS ────────────────────
    {'name': 'Oats Porridge', 'category': 'healthy', 'calories': 180, 'fat': 4.0, 'sugar': 6.0, 'protein': 7.0, 'cost': 30.0},
    {'name': 'Mixed Fruit Bowl', 'category': 'healthy', 'calories': 120, 'fat': 0.5, 'sugar': 22.0, 'protein': 2.0, 'cost': 50.0},
    {'name': 'Sprout Salad', 'category': 'healthy', 'calories': 150, 'fat': 1.0, 'sugar': 4.0, 'protein': 10.0, 'cost': 40.0},
    {'name': 'Dal + Brown Rice', 'category': 'healthy', 'calories': 320, 'fat': 4.0, 'sugar': 3.0, 'protein': 14.0, 'cost': 60.0},
    {'name': 'Grilled Chicken Salad', 'category': 'healthy', 'calories': 290, 'fat': 6.0, 'sugar': 3.0, 'protein': 34.0, 'cost': 180.0},
    {'name': 'Idli (3 pcs) + Sambar', 'category': 'healthy', 'calories': 200, 'fat': 2.0, 'sugar': 3.0, 'protein': 8.0, 'cost': 50.0},
    {'name': 'Vegetable Soup', 'category': 'healthy', 'calories': 110, 'fat': 2.0, 'sugar': 4.0, 'protein': 4.0, 'cost': 40.0},
    {'name': 'Makhana (fox nuts)', 'category': 'healthy', 'calories': 90, 'fat': 1.0, 'sugar': 1.0, 'protein': 4.0, 'cost': 30.0},
    {'name': 'Green Smoothie', 'category': 'healthy', 'calories': 140, 'fat': 2.0, 'sugar': 14.0, 'protein': 5.0, 'cost': 60.0},
    {'name': 'Boiled Egg (2 pcs)', 'category': 'healthy', 'calories': 140, 'fat': 9.0, 'sugar': 0.5, 'protein': 12.0, 'cost': 20.0},
  ];

  static List<Map<String, dynamic>> get allItems => _items;

  static List<Map<String, dynamic>> search(String query) {
    final q = query.toLowerCase();
    return _items
        .where((item) => (item['name'] as String).toLowerCase().contains(q))
        .toList();
  }

  static FoodEntry createEntry(String id, Map<String, dynamic> data) {
    return FoodEntry(
      id: id,
      name: data['name'],
      category: FoodCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => FoodCategory.moderate,
      ),
      calories: data['calories'],
      fat: data['fat'],
      sugar: data['sugar'],
      protein: data['protein'],
      cost: data['cost'],
      timestamp: DateTime.now(),
    );
  }

  static List<String> get junkFoodNames => _items
      .where((e) => e['category'] == 'junk')
      .map((e) => e['name'] as String)
      .toList();

  static List<String> get healthyFoodNames => _items
      .where((e) => e['category'] == 'healthy')
      .map((e) => e['name'] as String)
      .toList();
}
