import 'dart:async';

class DiagnosticService {
  Future<int> runPingTest() async {
    await Future.delayed(Duration(seconds: 1)); 
    return 100; 
  }

  Future<int> checkSignalStrength() async {
    await Future.delayed(Duration(seconds: 1)); 
    return 80;
  }

  String getRecommendation(int ping, int signal) {
    if (ping > 200 || signal < 50) {
      return "Your connection is poor. Consider upgrading your plan or moving closer to the router.";
    } else if (ping > 100 || signal < 70) {
      return "Your connection is average. You may experience occasional slowdowns.";
    } else {
      return "Your connection is excellent. No action needed.";
    }
  }
}