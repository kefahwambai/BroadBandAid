import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'diagnostic.dart';
import 'upgradePlan.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double usagePercentage = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataUsage();
  }

  Future<void> fetchDataUsage() async {
    final response =
        await http.get(Uri.parse('http://localhost:8081/api/usage?userId=34'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        usagePercentage =
            double.parse(data['usage']['usagePercentage'].replaceAll('%', ''));
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data usage');
    }
  }

  Future<void> runDiagnostics() async {
    final response =
        await http.get(Uri.parse('http://localhost:8081/api/diagnostic?userId=34'));
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ISP Manager'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Your Data Usage',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: usagePercentage / 100,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '$usagePercentage% of plan limit used',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: runDiagnostics,
                    child: Text('Run Diagnostics'),
                  ),
                  SizedBox(height: 20),
                  if (usagePercentage >= 80)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlanUpgradeScreen(),
                          ),
                        );
                      },
                      child: Text('Upgrade Plan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
