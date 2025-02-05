import 'package:flutter/material.dart';
import '../models/isp_plan.dart';

class ISPPlanCard extends StatelessWidget {
  final ISPPlan plan;

  const ISPPlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(plan.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Price: \$${plan.price} - Data: ${plan.dataLimit}GB - Speed: ${plan.speed}Mbps'),
      ),
    );
  }
}
