import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'loginScreen.dart';
import 'home.dart';

class SignupScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedPlan;
  
  const SignupScreen({super.key, this.selectedPlan});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> _signupUser() async {
    final String apiUrl = 'http://localhost:8081/api/user-signup';

    if (passwordController.text != confirmPasswordController.text) {
      _showMessage("Passwords do not match");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text,
          "email": emailController.text,
          "password": passwordController.text,
          "confirmPassword": confirmPasswordController.text,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('user')) {
          int userId = responseData['user']['id'];

          _showMessage("Signup successful!", success: true);

          if (widget.selectedPlan != null) {
            await _updatePlan(userId, widget.selectedPlan!);
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(userId: userId),
            ),
          );
        } else {
          _showMessage("Unexpected server response.");
        }
      } else {
        final responseData = jsonDecode(response.body);
        _showMessage(responseData['message'] ?? "Signup failed");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showMessage("Network error. Please try again later.");
    }
  }

  Future<void> _updatePlan(int userId, Map<String, dynamic> plan) async {

    DateTime now = DateTime.now();

    int timeLimit = plan['timeLimit']; 
    DateTime expiryDate = now.add(Duration(hours: timeLimit));


    try {
      final response = await http.put(
        Uri.parse('http://localhost:8081/api/update-plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'planId': plan['id'],
          'planLimit': plan['dataLimit'],
          'timeLimit': plan['timeLimit'],
          'expiryDate': expiryDate.toIso8601String(), 
          'dataLimit': plan['dataLimit']
        }),
      );

      if (response.statusCode == 200) {
        _showMessage("Plan updated to ${plan['name']}", success: true);
      } else {
        throw Exception('Failed to update plan');
      }
    } catch (e) {
      _showMessage("Error updating plan: ${e.toString()}");
    }
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Create an Account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signupUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text("Sign Up"),
                  ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}