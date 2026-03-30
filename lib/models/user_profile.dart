class UserProfile {
  final String id;
  final String name;
  final int age;
  final double weight;
  final List<String> healthConditions;
  final String foodPreference;
  final String region;
  final String budgetPreference;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.weight,
    required this.healthConditions,
    required this.foodPreference,
    required this.region,
    required this.budgetPreference,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'weight': weight,
        'healthConditions': healthConditions,
        'foodPreference': foodPreference,
        'region': region,
        'budgetPreference': budgetPreference,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'],
        name: json['name'],
        age: json['age'],
        weight: (json['weight'] as num).toDouble(),
        healthConditions: List<String>.from(json['healthConditions']),
        foodPreference: json['foodPreference'],
        region: json['region'],
        budgetPreference: json['budgetPreference'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  UserProfile copyWith({
    String? name,
    int? age,
    double? weight,
    List<String>? healthConditions,
    String? foodPreference,
    String? region,
    String? budgetPreference,
  }) =>
      UserProfile(
        id: id,
        name: name ?? this.name,
        age: age ?? this.age,
        weight: weight ?? this.weight,
        healthConditions: healthConditions ?? this.healthConditions,
        foodPreference: foodPreference ?? this.foodPreference,
        region: region ?? this.region,
        budgetPreference: budgetPreference ?? this.budgetPreference,
        createdAt: createdAt,
      );
}
