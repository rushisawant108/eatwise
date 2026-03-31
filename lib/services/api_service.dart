import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/food_entry.dart';

class ApiService {
  // Use http://10.0.2.2:5000 for Android Emulator or your local IP for physical devices
  // Since this is a web app prototype, localhost:5000 works.
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$uid'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  static Future<String?> logFood(String uid, Map<String, dynamic> foodData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/foodLog'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'uid': uid,
          'foodData': foodData,
        }),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['entryId'];
      }
      return null;
    } catch (e) {
      print('Error logging food: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> analyzeImage(List<int> imageBytes, Map<String, dynamic> biometrics) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'imageBuffer': base64Encode(imageBytes),
          'userBiometrics': biometrics,
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error analyzing image: $e');
      return null;
    }
  }
}
