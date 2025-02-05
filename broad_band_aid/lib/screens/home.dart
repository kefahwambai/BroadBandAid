import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'diagnostic.dart';
import 'welcomeScreen.dart';
import 'upgradePlan.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({super.key, required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

String formatTimeLimit(int timeLimitInHours) {
  if (timeLimitInHours < 24) {
    return '$timeLimitInHours hour${timeLimitInHours > 1 ? 's' : ''}';
  } else if (timeLimitInHours < 168) {
    final days = timeLimitInHours ~/ 24;
    return '$days day${days > 1 ? 's' : ''}';
  } else if (timeLimitInHours < 720) {
    final weeks = timeLimitInHours ~/ 168;
    return '$weeks week${weeks > 1 ? 's' : ''}';
  } else {
    final months = timeLimitInHours ~/ 720;
    return '$months month${months > 1 ? 's' : ''}';
  }
}

class _HomeScreenState extends State<HomeScreen> {
  double usagePercentage = 0.0;
  Timer? _usageSimulationTimer;
  bool isLoading = true;
  int? userId;
  String userName = '';
  String planName = '';
  int? price;
  String timeLimit = '';
  String provider = '';
  int? bundle;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    _startDataUsageSimulation();
  }

  @override
  void dispose() {
    _usageSimulationTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchUserInfo() async {
    try {
      String? token = await storage.read(key: 'auth_token');

      if (token != null) {
        final decodedToken = Jwt.parseJwt(token);

        int extractedUserId = decodedToken['id'] ?? 0;
        String extractedUserName = decodedToken['name'];

        if (extractedUserId == 0 || extractedUserName == Null) {
          print("Invalid user details parsed from JWT.");
          return;
        }

        setState(() {
          userId = extractedUserId;
          userName = extractedUserName;
        });

        fetchDataUsage();
        fetchPlanDetails();
      } else {
        throw Exception('Token not found');
      }
    } catch (e) {
      print("Error fetching user info: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logoutUser() async {
    await storage.delete(key: 'auth_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
    );
  }

  Future<void> fetchDataUsage() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8081/api/usage?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        double usage = double.tryParse(
                data['usage']['usagePercentage'].replaceAll('%', '')) ??
            0.0;

        if (usage < 0) usage = 0;
        if (usage > 100) usage = 100;

        setState(() {
          usagePercentage = usage;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data usage');
      }
    } catch (e) {
      print("Error fetching data usage: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchPlanDetails() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:8081/api/user-plan?userId=$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          planName = data['plan']['name'];
          price = data['plan']['price'];
          bundle = data['plan']['dataLimit'];
          timeLimit =
              formatTimeLimit(int.parse(data['plan']['timeLimit'].toString()));
          provider = data['plan']['provider'];
        });
      } else {
        throw Exception('Failed to load plan details');
      }
    } catch (e) {
      print("Error fetching plan details: $e");
    }
  }

  Future<void> runDiagnostics() async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:8081/api/diagnostic?userId=$userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiagnosticsScreen(result: data['data']),
          ),
        );
      } else {
        throw Exception('Failed to run diagnostics');
      }
    } catch (e) {
      print("Error running diagnostics: $e");
    }
  }

  void _startDataUsageSimulation() {
    if (_usageSimulationTimer != null && _usageSimulationTimer!.isActive) {
      return;
    }

    _usageSimulationTimer =
        Timer.periodic(Duration(seconds: 30), (timer) async {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:8081/api/simulateUsage'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': widget.userId}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          double currentUsagePercentage = double.tryParse(
                  data['usage']['usagePercentage'].replaceAll('%', '')) ??
              0.0;

          setState(() {
            usagePercentage = currentUsagePercentage;
          });

          if (currentUsagePercentage >= 100) {
            _usageSimulationTimer?.cancel();
          }
        } else {
          throw Exception('Failed to simulate data usage');
        }
      } catch (e) {
        print("Error simulating data usage: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('BroadBandAid', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logoutUser,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 100 : 16,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, $userName!',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 32 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Dashboard',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 24 : 18,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildCard(
                    title: 'Plan Details',
                    color: Colors.blueGrey[800]!,
                    extraText:
                        '$planName for $bundle GB\nExpires in: $timeLimit\nBalance: KES $price/-',
                  ),
                  const SizedBox(height: 20),
                  if (usagePercentage >= 80)
                    _buildCard(
                      title: 'Upgrade Plan',
                      color: Colors.red[400]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlanUpgradeScreen(userId: userId.toString()),
                          ),
                        );
                      },
                    ),
                  if (usagePercentage >= 80) const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: isLargeScreen ? 2 : 1,
                        child: _buildCard(
                          title: 'Check Data Health',
                          color: Colors.teal[400]!,
                          onTap: runDiagnostics,
                        ),
                      ),
                      SizedBox(width: isLargeScreen ? 20 : 10),
                      Expanded(
                        flex: isLargeScreen ? 2 : 1,
                        child: _buildCard(
                          title: 'Remaining Data',
                          color: Colors.blueGrey[800]!,
                          extraText: '${(100 - usagePercentage).round()}% Remaining',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildCard({
    required String title,
    required Color color,
    String extraText = '',
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (extraText.isNotEmpty) const SizedBox(height: 8),
              if (extraText.isNotEmpty)
                Text(
                  extraText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Jwt {
  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw FormatException('Invalid JWT token');

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