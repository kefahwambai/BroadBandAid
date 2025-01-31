import 'package:flutter/material.dart';
import 'loginScreen.dart'; // Import your login screen
import 'signUpScreen.dart'; // Import your signup screen
import 'upgradePlan.dart'; // Import your upgrade plan screen

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

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
      MaterialPageRoute(builder: (context) => PlanUpgradeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
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
            // const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () => _navigateToLogin(context),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.white,
            //     foregroundColor: Colors.blueAccent,
            //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //   ),
            //   child: const Text("Login"),
            // ),
            // const SizedBox(height: 10),
            // OutlinedButton(
            //   onPressed: () => _navigateToSignup(context),
            //   style: OutlinedButton.styleFrom(
            //     foregroundColor: Colors.white,
            //     side: const BorderSide(color: Colors.white),
            //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //   ),
            //   child: const Text("Sign Up"),
            // ),
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
        ),
      ),
    );
  }
}
