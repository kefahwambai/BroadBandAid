import 'package:flutter/material.dart';

class DiagnosticWidget extends StatelessWidget {
  final String title;
  final String result;
  final IconData icon;
  final Color iconColor;

  const DiagnosticWidget({
    super.key,
    required this.title,
    required this.result,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 40),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(result, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
