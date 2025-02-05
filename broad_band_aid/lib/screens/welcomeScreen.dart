import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'home.dart';
import 'loginScreen.dart';
import 'signUpScreen.dart';
import 'upgradePlan.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? userId;
  bool isLoading = true;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _checkAuthToken();
  }

  Future<void> _fetchUserId() async {
    String? storedUserId = await storage.read(key: 'user_id');
    setState(() {
      userId = storedUserId;
    });
  }

  Future<void> _checkAuthToken() async {
    try {
      String? token = await storage.read(key: 'auth_token');

      if (token != null) {
        final decodedToken = Jwt.parseJwt(token);
        int userId = decodedToken['id'] ?? 0;

        if (userId != 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(userId: userId),
            ),
          );
        }
      }
    } catch (e) {
      print("Error checking auth token: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _navigateToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  void _navigateToUpgradePlan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanUpgradeScreen(
          userId: userId,
          requireAuth: false, 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("BroadBandAid"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return _buildWebLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.blueAccent,
            child: const Center(
              child: Icon(
                Icons.wifi,
                size: 150,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildButtons(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi,
            size: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          const Text(
            "Welcome to BroadBandAid!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _navigateToLogin(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text("Login"),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _navigateToSignup(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: Color.fromARGB(255, 1, 221, 255),
            side: const BorderSide(color: Color.fromARGB(255, 1, 221, 255)),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text("Sign Up"),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _navigateToUpgradePlan(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text("Choose Package"),
        ),
      ],
    );
  }
}

class Jwt {
  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw const FormatException('Invalid JWT token');

    final payload = _decodeBase64(parts[1]);
    return jsonDecode(payload);
  }

  static String _decodeBase64(String base64Str) {
    String output = base64Str;
    if (output.length % 4 != 0) {
      output += '=' * (4 - output.length % 4);
    }
    final decodedBytes = base64Url.decode(output);
    return utf8.decode(decodedBytes);
  }
}