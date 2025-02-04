import 'dart:convert';
import 'package:http/http.dart' as http;

class User {
  final int id;
  final String name;
  final String email;
  final String planName;
  final String provider;
  final int timeLimit; 
  final double planLimit; 
  double dataUsed; 
  double dataLimit;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.planName,
    required this.provider,
    required this.timeLimit,
    required this.planLimit,
    required this.dataUsed,
    required this.dataLimit,
  });

  static Future<User> fetchPlanDetails(int userId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8081/api/user-plan?userId=$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User(
          id: data['user']['id'],
          name: data['user']['name'],
          email: data['user']['email'],
          planName: data['plan']['name'],
          provider: data['plan']['provider'],
          timeLimit: data['plan']['timeLimit'],
          planLimit: data['plan']['planLimit'],
          dataUsed: data['plan']['dataUsed'],
          dataLimit: data['plan']['dataLimit'],
        );
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      print("Error fetching user details: $e");
      rethrow;
    }
  }
}
