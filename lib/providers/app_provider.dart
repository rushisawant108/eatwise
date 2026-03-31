import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/food_entry.dart';
import '../core/services/storage_service.dart';
import '../services/ai_prediction_engine.dart';
import '../services/api_service.dart';
import '../data/food_database.dart';
import 'package:uuid/uuid.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;
  final _uuid = const Uuid();

  UserProfile? _userProfile;
  List<FoodEntry> _foodLog = [];
  int _rewardPoints = 0;
  bool _isLoading = false;

  // ── Getters ────────────────────────────────────────────────────────────────
  UserProfile? get userProfile => _userProfile;
  List<FoodEntry> get foodLog => _foodLog;
  int get rewardPoints => _rewardPoints;
  bool get isLoading => _isLoading;

  List<FoodEntry> get todayEntries {
    final today = DateTime.now();
    return _foodLog.where((e) {
      return e.timestamp.year == today.year &&
          e.timestamp.month == today.month &&
          e.timestamp.day == today.day;
    }).toList();
  }

  RiskResult get currentRisk {
    if (_userProfile == null) {
      return const RiskResult(
        level: RiskLevel.low,
        label: 'Low',
        score: 0,
        reasons: ['Complete onboarding to get personalized insights'],
        healthWarnings: [],
        suggestions: [],
      );
    }
    return AIPredictionEngine.computeRisk(
      todayEntries: todayEntries,
      profile: _userProfile!,
    );
  }

  Map<String, dynamic> get todayStats =>
      AIPredictionEngine.computeTodayStats(_foodLog);

  // ── Initialization ─────────────────────────────────────────────────────────
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    _userProfile = _storage.getUserProfile();
    _foodLog = _storage.getFoodLog();
    _rewardPoints = _storage.getRewardPoints();
    
    // Attempt to sync from backend if possible
    if (_userProfile != null) {
      final backendUser = await ApiService.getUserProfile(_userProfile!.id);
      if (backendUser != null) {
        // Sync logic could go here
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Onboarding ──────────────────────────────────────────────────────────────
  Future<void> saveUserProfile(UserProfile profile) async {
    _userProfile = profile;
    await _storage.saveUserProfile(profile);
    await _storage.setOnboardingDone();

    // Sync to backend
    // Note: In real app, name/id would come from auth
    // For now we try to push it
    // ApiService does not have a direct push profile yet, but we'll use logFood style or similar
    
    notifyListeners();
  }

  bool get isOnboardingDone => _storage.isOnboardingDone();

  // ── Food Log ────────────────────────────────────────────────────────────────
  Future<FoodEntry> logFood(Map<String, dynamic> foodData) async {
    final entry = FoodDatabase.createEntry(_uuid.v4(), foodData);
    _foodLog.add(entry);

    // Points: healthy +10, moderate +3, junk -5
    final pts = entry.isHealthy ? 10 : entry.isJunk ? -5 : 3;
    _rewardPoints = (_rewardPoints + pts).clamp(0, 99999);

    await _storage.saveFoodEntry(entry);
    await _storage.addRewardPoints(pts);

    // Backend Sync
    if (_userProfile != null) {
      ApiService.logFood(_userProfile!.id, foodData);
    }

    notifyListeners();
    return entry;
  }

  Future<FoodEntry> logFoodEntry(FoodEntry entry) async {
    _foodLog.add(entry);
    final pts = entry.isHealthy ? 10 : entry.isJunk ? -5 : 3;
    _rewardPoints = (_rewardPoints + pts).clamp(0, 99999);
    await _storage.saveFoodEntry(entry);
    await _storage.addRewardPoints(pts);

    // Backend Sync
    if (_userProfile != null) {
      ApiService.logFood(_userProfile!.id, {
        'id': entry.id,
        'name': entry.name,
        'calories': entry.calories,
        'category': entry.category.toString().split('.').last,
        'cost': entry.cost,
        'fat': entry.fat,
        'sugar': entry.sugar,
        'protein': entry.protein,
      });
    }

    notifyListeners();
    return entry;
  }

  // ── Weekly stats (last 7 days) ────────────────────────────────────────────
  List<Map<String, dynamic>> get weeklyStats {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final entries = _foodLog.where((e) {
        return e.timestamp.year == day.year &&
            e.timestamp.month == day.month &&
            e.timestamp.day == day.day;
      }).toList();

      return {
        'day': day,
        'junkCount': entries.where((e) => e.isJunk).length,
        'calories': entries.fold(0, (s, e) => s + e.calories),
        'risk': AIPredictionEngine.computeRisk(
          todayEntries: entries,
          profile: _userProfile ??
              UserProfile(
                id: '',
                name: '',
                age: 25,
                weight: 65,
                healthConditions: [],
                foodPreference: 'Vegetarian',
                region: 'North Indian',
                budgetPreference: 'Moderate',
                createdAt: DateTime.now(),
              ),
          currentTime: day,
        ),
      };
    });
  }
}
