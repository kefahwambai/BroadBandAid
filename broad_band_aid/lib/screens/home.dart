import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'loginScreen.dart';
import 'diagnostic.dart';
import 'upgradePlan.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  HomeScreen({required this.userId});

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
  String planName = '';
  String timeLimit = '';
  String provider = '';
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

        if (extractedUserId == 0) {
          print("Invalid user ID parsed from JWT.");
          return;
        }

        setState(() {
          userId = extractedUserId;
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
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> fetchDataUsage() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:8081/api/usage?userId=$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          usagePercentage = double.tryParse(
                  data['usage']['usagePercentage'].replaceAll('%', '')) ??
              0.0;
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

  _usageSimulationTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
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



  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BroadBandAid'),
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
                      'Your Dashboard',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 50),
                    _buildCard(
                      title: 'Plan Details',
                      icon: Icons.circle,
                      color: Colors.grey,
                      onTap: () {},
                      extraText:
                          'Plan: $planName\nProvider: $provider\nTime Limit: $timeLimit',
                    ),
                    if (usagePercentage >= 80)
                      _buildCard(
                        title: 'Upgrade Plan',
                        icon: Icons.upgrade,
                        color: Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlanUpgradeScreen(userId: userId.toString()), 
                            ),
                          );
                        },
                      ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildCard(
                            title: 'Data Health',
                            icon: Icons.health_and_safety,
                            color: Colors.green,
                            onTap: runDiagnostics,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildCard(
                            title: 'Remaining Data',
                            icon: Icons.data_usage,
                            color: Colors.orange,
                            onTap: () {},
                            extraText:
                                '${(100 - usagePercentage).toStringAsFixed(1)}% Remaining',
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
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? extraText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 10),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              if (extraText != null)
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    extraText,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
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
