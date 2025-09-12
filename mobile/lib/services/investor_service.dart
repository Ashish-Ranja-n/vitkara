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

  // Get investor campaigns
  Future<Map<String, dynamic>?> getCampaigns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        return null;
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/investor/campaigns'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to load campaigns: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  // Make an investment
  Future<Map<String, dynamic>?> makeInvestment({
    required String campaignId,
    required int tickets,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        return null;
      }

      final body = <String, dynamic>{
        'campaignId': campaignId,
        'tickets': tickets,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/investor/investments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Investment failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }
}
