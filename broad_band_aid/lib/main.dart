import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:broad_band_aid/providers/user.dart';
import 'package:broad_band_aid/providers/isp.dart'; 
import 'package:broad_band_aid/routes/app_routes.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ISPProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BroadBand Aid',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}
