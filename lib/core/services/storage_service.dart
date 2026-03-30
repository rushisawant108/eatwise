import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_profile.dart';
import '../../models/food_entry.dart';
import '../constants/app_constants.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();
  static StorageService get instance => _instance ??= StorageService._();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── User Profile ────────────────────────────────────────────────────────────
  Future<void> saveUserProfile(UserProfile profile) async {
    await _prefs?.setString(
      AppConstants.kUserProfile,
      jsonEncode(profile.toJson()),
    );
  }

  UserProfile? getUserProfile() {
    final raw = _prefs?.getString(AppConstants.kUserProfile);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw));
  }

  // ─── Onboarding ──────────────────────────────────────────────────────────────
  Future<void> setOnboardingDone() async {
    await _prefs?.setBool(AppConstants.kOnboardingDone, true);
  }

  bool isOnboardingDone() {
    return _prefs?.getBool(AppConstants.kOnboardingDone) ?? false;
  }

  // ─── Food Log ────────────────────────────────────────────────────────────────
  List<FoodEntry> getFoodLog() {
    final raw = _prefs?.getString(AppConstants.kFoodLog);
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw);
    return list.map((e) => FoodEntry.fromJson(e)).toList();
  }

  Future<void> saveFoodEntry(FoodEntry entry) async {
    final log = getFoodLog();
    log.add(entry);
    await _prefs?.setString(AppConstants.kFoodLog, jsonEncode(log.map((e) => e.toJson()).toList()));
  }

  Future<void> clearFoodLog() async {
    await _prefs?.remove(AppConstants.kFoodLog);
  }

  // ─── Reward Points ───────────────────────────────────────────────────────────
  int getRewardPoints() {
    return _prefs?.getInt(AppConstants.kRewardPoints) ?? 0;
  }

  Future<void> addRewardPoints(int points) async {
    final current = getRewardPoints();
    await _prefs?.setInt(AppConstants.kRewardPoints, current + points);
  }
}
