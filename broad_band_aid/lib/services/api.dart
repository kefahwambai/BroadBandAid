import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/isp_plan.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8081/api';

  static Future<List<ISPPlan>> fetchISPPlans() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/plans'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('plans')) {
          List<dynamic> data = jsonResponse['plans'];
          return data.map((plan) => ISPPlan.fromJson(plan)).toList();
        } else {
          throw Exception("Unexpected API response format: Missing 'plans' key");
        }
      } else {
        throw Exception('Failed to load ISP Plans. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching ISP Plans: $e');
    }
  }

  static Future<User> fetchUser(String name) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$name'));

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('User not found');
    }
  }
}
