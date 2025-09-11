import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InvestorService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://vitkara.com/api',
  );

  // Get investor profile
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/investor'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Update investor profile
  Future<Map<String, dynamic>?> updateProfile({
    String? name,
    String? avatar,
    int? age,
    String? location,
    String? city,
    String? defaultDashboard,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        return null;
      }

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (avatar != null) body['avatar'] = avatar;
      if (age != null) body['age'] = age;
      if (location != null) body['location'] = location;
      if (city != null) body['city'] = city;
      if (defaultDashboard != null) body['defaultDashboard'] = defaultDashboard;

      final response = await http.put(
        Uri.parse('$baseUrl/investor'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
