import 'package:flutter/material.dart';
import '../screens/home.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const HomeScreen(),
  };
}
