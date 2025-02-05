import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'loginScreen.dart';
import 'signUpScreen.dart';
import 'home.dart';

class PlanUpgradeScreen extends StatefulWidget {
  final String? userId;
  final bool requireAuth;

  const PlanUpgradeScreen({super.key, this.userId, this.requireAuth = true});

  @override
  _PlanUpgradeScreenState createState() => _PlanUpgradeScreenState();
}

class _PlanUpgradeScreenState extends State<PlanUpgradeScreen> {
  List<dynamic> plans = [];
  bool isLoading = true;
  Map<String, dynamic>? selectedPlan;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    try {
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

  void _choosePlan(Map<String, dynamic> plan) {
    if (widget.userId == null) {
      _navigateToAuth(context, plan);
    } else {
      _upgradePlan(plan);
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

  Future<void> _upgradePlan(Map<String, dynamic> plan) async {
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
          'dataLimit': plan['dataLimit'],
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plan updated to ${plan['name']}')),
        );

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

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
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? 32 : 16,
                vertical: 16,
              ),
              child: isWideScreen
                  ? GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        return _buildPlanCard(plan, isWideScreen);
                      },
                    )
                  : ListView.separated(
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        return _buildPlanCard(plan, isWideScreen);
                      },
                    ),
            ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, bool isWideScreen) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.withOpacity(0.8), Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data: ${plan['dataLimit']}GB',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Price: KSH ${plan['price']}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => _choosePlan(plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Choose Plan',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}