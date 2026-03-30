class AppConstants {
  static const String appName = 'EATWISE';
  static const String appTagline = 'Eat Smart. Live Better.';

  // SharedPreferences Keys
  static const String kUserProfile = 'user_profile';
  static const String kFoodLog = 'food_log';
  static const String kRewardPoints = 'reward_points';
  static const String kOnboardingDone = 'onboarding_done';

  // Risk Levels
  static const String riskLow = 'Low';
  static const String riskMedium = 'Medium';
  static const String riskHigh = 'High';

  // Health Conditions
  static const List<String> healthConditions = [
    'None',
    'Diabetes',
    'High Cholesterol',
    'PCOS',
    'Hypertension',
    'Obesity',
  ];

  // Food Preferences
  static const List<String> foodPreferences = [
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan',
    'Eggetarian',
  ];

  // Regions
  static const List<String> regions = [
    'North Indian',
    'South Indian',
    'East Indian',
    'West Indian',
    'Continental',
    'Mixed',
  ];

  // Budget Options
  static const List<String> budgetOptions = [
    'Budget (< ₹100/meal)',
    'Moderate (₹100–₹300)',
    'Premium (> ₹300)',
  ];

  // Damage Control Tips
  static const List<String> damageControlTips = [
    'Take a 10-minute brisk walk after this meal.',
    'Drink 2 glasses of water to flush out excess sodium.',
    'Avoid sugary drinks for the rest of the day.',
    'Keep your next meal light — try a salad or dal with roti.',
    'Reduce your portion size at the next meal.',
    'Skip snacks for the next 3 hours.',
    'Do 15 squats or stretches to kickstart digestion.',
  ];

  // Healthier Alternatives (per food type)
  static const Map<String, List<String>> healthyAlternatives = {
    'pizza': ['Multigrain roti with paneer', 'Whole wheat pasta with veggies'],
    'burger': ['Grilled chicken wrap', 'Sprout chaat'],
    'biryani': ['Brown rice khichdi', 'Daliya pulao'],
    'samosa': ['Steamed momos', 'Roasted makhana'],
    'chips': ['Makhana (fox nuts)', 'Air-popped popcorn'],
    'default': ['Fresh fruit bowl', 'Dal with brown rice'],
  };
}
