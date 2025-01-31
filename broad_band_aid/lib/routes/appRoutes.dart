import 'package:flutter/material.dart';
import '../screens/welcomeScreen.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const WelcomeScreen(),
  };
}
