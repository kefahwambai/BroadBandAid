import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'loginScreen.dart';
import 'signUpScreen.dart';
import 'home.dart';

class PlanUpgradeScreen extends StatefulWidget {
  final String? userId;

  const PlanUpgradeScreen({super.key, this.userId});

  @override
  _PlanUpgradeScreenState createState() => _PlanUpgradeScreenState();
}

class _PlanUpgradeScreenState extends State<PlanUpgradeScreen> {
  List<dynamic> plans = [];
  bool isLoading = true;
  Map<String, dynamic>? selectedPlan;
  final storage = FlutterSecureStorage();
  double usagePercentage = 0.0;

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    try {
      String? token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await http.get(
        Uri.parse('http://localhost:8081/api/plans'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          plans = data['plans'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load plans');
      }
    } catch (e) {
      print("Error fetching plans: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String convertTime(int timeLimitInHours) {
    if (timeLimitInHours < 24) {
      return '${timeLimitInHours}hr';
    } else if (timeLimitInHours >= 24 && timeLimitInHours < 168) {
      int days = timeLimitInHours ~/ 24;
      return '${days}d';
    } else if (timeLimitInHours >= 168 && timeLimitInHours < 720) {
      int weeks = timeLimitInHours ~/ 168;
      return '${weeks}w';
    } else {
      int months = timeLimitInHours ~/ 720;
      return '${months}mo';
    }
  }

  void _navigateToAuth(BuildContext context, Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Proceed to Login/Signup"),
          content: const Text("You need to log in or sign up to upgrade your plan."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(selectedPlan: plan),
                  ),
                );
              },
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignupScreen(selectedPlan: plan),
                  ),
                );
              },
              child: const Text("Sign Up"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _choosePlan(Map<String, dynamic> plan) async {
    if (widget.userId == null) {
      _navigateToAuth(context, plan);
      return;
    }

    DateTime now = DateTime.now();

    int timeLimit = plan['timeLimit'];
    DateTime expiryDate = now.add(Duration(hours: timeLimit));

    try {
      final response = await http.put(
        Uri.parse('http://localhost:8081/api/update-plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'planId': plan['id'],
          'planLimit': plan['dataLimit'],
          'timeLimit': plan['timeLimit'],
          'expiryDate': DateTime.now().add(Duration(hours: plan['timeLimit'])).toIso8601String(),
          'dataLimit': plan['dataLimit']
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plan updated to ${plan['name']}')),
        );

        setState(() {
          usagePercentage = 0.0;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userId: int.parse(widget.userId!)),
          ),
        );
      } else {
        throw Exception('Failed to update plan');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Plan'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWeb ? 800 : double.infinity),
                  child: ListView.separated(
                    itemCount: plans.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan['name'],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Data: ${plan['dataLimit']}GB',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Price: KSH ${plan['price']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Time: ${convertTime(plan['timeLimit'])}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () => _choosePlan(plan),
                                  icon: const Icon(Icons.check, size: 20),
                                  label: const Text(
                                    'Choose Plan',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}