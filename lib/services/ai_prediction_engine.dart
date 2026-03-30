import '../models/food_entry.dart';
import '../models/user_profile.dart';
import '../core/constants/app_constants.dart';

enum RiskLevel { low, medium, high }

class RiskResult {
  final RiskLevel level;
  final String label;
  final int score; // 0–100
  final List<String> reasons;
  final List<String> healthWarnings;
  final List<String> suggestions;

  const RiskResult({
    required this.level,
    required this.label,
    required this.score,
    required this.reasons,
    required this.healthWarnings,
    required this.suggestions,
  });
}

class AIPredictionEngine {
  /// Core rule-based engine to compute junk food risk
  static RiskResult computeRisk({
    required List<FoodEntry> todayEntries,
    required UserProfile profile,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    int score = 0;
    final List<String> reasons = [];
    final List<String> warnings = [];
    final List<String> suggestions = [];

    // ── Rule 1: Junk food count ──────────────────────────────────────────────
    final junkCount = todayEntries.where((e) => e.isJunk).length;
    if (junkCount >= 3) {
      score += 40;
      reasons.add('$junkCount junk food items consumed today');
    } else if (junkCount == 2) {
      score += 25;
      reasons.add('2 junk food items consumed today');
    } else if (junkCount == 1) {
      score += 10;
    }

    // ── Rule 2: Late-night eating ─────────────────────────────────────────────
    final lateNightEntries = todayEntries.where((e) => e.isLateNight).length;
    if (lateNightEntries >= 2) {
      score += 30;
      reasons.add('Multiple late-night eating sessions detected');
    } else if (lateNightEntries == 1) {
      score += 15;
      reasons.add('Late-night eating pattern detected');
    }

    // ── Rule 3: Current time is late night ───────────────────────────────────
    final hour = now.hour;
    if (hour >= 22 || hour < 4) {
      score += 20;
      reasons.add('You are browsing food at ${_formatHour(hour)}');
    }

    // ── Rule 4: High-calorie intake ──────────────────────────────────────────
    final totalCalories = todayEntries.fold(0, (sum, e) => sum + e.calories);
    if (totalCalories > 2500) {
      score += 20;
      reasons.add('Daily calorie intake exceeds 2500 kcal');
    } else if (totalCalories > 1800) {
      score += 8;
    }

    // ── Rule 5: Frequency of entries ─────────────────────────────────────────
    if (todayEntries.length >= 5) {
      score += 10;
      reasons.add('High frequency of food logging today');
    }

    // ── Health condition–based warnings ─────────────────────────────────────
    final recentJunk = todayEntries.where((e) => e.isJunk).toList();

    if (profile.healthConditions.contains('Diabetes')) {
      final highSugar = recentJunk.where((e) => e.sugar > 20).length;
      if (highSugar > 0) {
        warnings.add('High sugar foods detected — may increase blood glucose levels');
        score += 10;
      }
    }

    if (profile.healthConditions.contains('High Cholesterol')) {
      final highFat = recentJunk.where((e) => e.fat > 20).length;
      if (highFat > 0) {
        warnings.add('High fat content — risk of cholesterol spike');
        score += 10;
      }
    }

    if (profile.healthConditions.contains('PCOS')) {
      if (junkCount >= 2) {
        warnings.add('Processed food may worsen hormonal balance with PCOS');
        score += 5;
      }
    }

    if (profile.healthConditions.contains('Hypertension')) {
      final highSodium = recentJunk.where((e) => e.fat > 15).length;
      if (highSodium > 0) {
        warnings.add('High sodium/fat foods detected — may raise blood pressure');
        score += 8;
      }
    }

    // ── Suggestions ───────────────────────────────────────────────────────────
    if (score >= 50) {
      suggestions.addAll([
        'Skip ordering now — your body needs a break from junk',
        'Try a glass of water and a light fruit snack instead',
      ]);
    } else if (score >= 25) {
      suggestions.addAll([
        'Consider a lighter meal option',
        'Opt for homemade or healthier alternatives',
      ]);
    } else {
      suggestions.add('Great job today! Keep maintaining a balanced diet.');
    }

    // ── Clamp score ───────────────────────────────────────────────────────────
    score = score.clamp(0, 100);

    final level = score >= 60
        ? RiskLevel.high
        : score >= 30
            ? RiskLevel.medium
            : RiskLevel.low;

    final label = level == RiskLevel.high
        ? AppConstants.riskHigh
        : level == RiskLevel.medium
            ? AppConstants.riskMedium
            : AppConstants.riskLow;

    return RiskResult(
      level: level,
      label: label,
      score: score,
      reasons: reasons.isEmpty ? ['No significant risk factors today'] : reasons,
      healthWarnings: warnings,
      suggestions: suggestions,
    );
  }

  static String _formatHour(int hour) {
    if (hour == 0) return 'midnight';
    if (hour < 12) return '${hour}AM';
    if (hour == 12) return '12PM';
    return '${hour - 12}PM';
  }

  /// Get junk score label for a single food item
  static String getFoodJunkLabel(FoodEntry entry) {
    switch (entry.category) {
      case FoodCategory.junk:
        return 'High Junk';
      case FoodCategory.moderate:
        return 'Moderate';
      case FoodCategory.healthy:
        return 'Healthy';
    }
  }

  /// Compute today's totals from entries
  static Map<String, dynamic> computeTodayStats(List<FoodEntry> entries) {
    final today = DateTime.now();
    final todayEntries = entries.where((e) {
      return e.timestamp.year == today.year &&
          e.timestamp.month == today.month &&
          e.timestamp.day == today.day;
    }).toList();

    return {
      'totalCalories': todayEntries.fold(0, (sum, e) => sum + e.calories),
      'totalCost': todayEntries.fold(0.0, (sum, e) => sum + e.cost),
      'junkCount': todayEntries.where((e) => e.isJunk).length,
      'entryCount': todayEntries.length,
      'todayEntries': todayEntries,
    };
  }
}
