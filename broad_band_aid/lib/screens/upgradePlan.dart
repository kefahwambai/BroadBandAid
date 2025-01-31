import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'loginScreen.dart'; // Import login screen
import 'signUpScreen.dart'; // Import signup screen

class PlanUpgradeScreen extends StatefulWidget {
  @override
  _PlanUpgradeScreenState createState() => _PlanUpgradeScreenState();
}

class _PlanUpgradeScreenState extends State<PlanUpgradeScreen> {
  List<dynamic> plans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    final response = await http.get(Uri.parse('http://localhost:8081/api/plans'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        plans = data['plans'];
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load plans');
    }
  }

  void _navigateToAuth(BuildContext context) {
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
              },
              child: const Text("Sign Up"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Package'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12.0),
                    title: Text(
                      plan['name'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                    subtitle: Text(
                      'Data: ${plan['dataLimit']}GB | Price: KSH${plan['price']}',
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () => _navigateToAuth(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Choose'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
