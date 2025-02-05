import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'screens/welcomeScreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? token;
  
  if (kIsWeb) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
  } else {
    final storage = FlutterSecureStorage();
    token = await storage.read(key: 'auth_token');
  }

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BroadBandAid',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(),
    );
  }
}
