import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'loginScreen.dart';
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
          print("Invalid user Idetails parsed from JWT.");
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
    return Scaffold(
      appBar: AppBar(
        title: Text('BroadBandAid'),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Welcome ${userName}\n\n Your Dashboard',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 55),
                    _buildCard(
                      title: 'Plan Details',
                      color: Colors.grey,
                      onTap: () {},
                      extraText:
                          '$planName for $bundle mb/s\nElapses after: $timeLimit\n Balance Due: KES $price/-',
                    ),
                    SizedBox(height: 20),
                    if (usagePercentage >= 80)
                      _buildCard(
                        title: 'Upgrade Plan',
                        color: Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlanUpgradeScreen(userId: userId.toString()),
                            ),
                          );
                        },
                      ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildCard(
                            title: 'Check\n Data Health',
                            color: const Color.fromARGB(255, 2, 141, 162),
                            onTap: runDiagnostics,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildCard(
                            title: 'Remaining Data',
                            color: Colors.grey,
                            onTap: () {},
                            extraText:
                                '${(100 - usagePercentage).round()}% Remaining',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCard({
    required String title,
    required Color color,
    required VoidCallback onTap,
    String extraText = '',
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        shadowColor: color.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      extraText,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
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
