import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'signUpScreen.dart';

class LoginScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedPlan; 
  const LoginScreen({super.key, this.selectedPlan});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  final storage = const FlutterSecureStorage();
  DateTime? lastActivityTime;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    const String apiUrl = 'http://localhost:8081/api/user-login';

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showMessage("Please enter email and password.");
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
          "email": emailController.text,
          "password": passwordController.text,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('token') &&
            responseData.containsKey('user')) {
          String token = responseData['token'];
          int userId = responseData['user']['id'];

          await storage.write(key: 'auth_token', value: token);

          lastActivityTime = DateTime.now();

          _showMessage("Login successful!", success: true);

          if (widget.selectedPlan != null) {
            await _updatePlan(userId, widget.selectedPlan!);
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userId: userId)),
          );
        } else {
          _showMessage("Unexpected server response.");
        }
      } else {
        final responseData = jsonDecode(response.body);
        _showMessage(responseData['message'] ?? "Invalid email or password.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showMessage("Network error. Please try again later.");
    }
  }

Future<void> _updatePlan(int userId, Map<String, dynamic> plan) async {
  try {
    DateTime now = DateTime.now();

    int timeLimit = plan['timeLimit']; 
    DateTime expiryDate = now.add(Duration(hours: timeLimit));

    final response = await http.put(
      Uri.parse('http://localhost:8081/api/update-plan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'planId': plan['id'],
        'planLimit': plan['dataLimit'],
        'timeLimit': timeLimit,
        'expiryDate': expiryDate.toIso8601String(), 
        'dataLimit': plan['dataLimit']
      }),
    );

    if (response.statusCode == 200) {
      print('Plan updated successfully');
    } else {
      print('Failed to update plan: ${response.body}');
    }
  } catch (e) {
    print('Error updating plan: $e');
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

  void _logoutUser() async {
    await storage.delete(key: 'auth_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _updateLastActivityTime() {
    lastActivityTime = DateTime.now();
  }

  void _checkInactivity() {
    Future.delayed(Duration(minutes: 1), () {
      if (lastActivityTime != null) {
        final timeElapsed = DateTime.now().difference(lastActivityTime!);
        if (timeElapsed.inMinutes >= 60) {
          _logoutUser();
        }
      }
      _checkInactivity();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome Back!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => _updateLastActivityTime(), 
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _updateLastActivityTime(), 
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Login"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignupScreen()),
                );
              },
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
