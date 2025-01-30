import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/isp.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ISPProvider>(context, listen: false).fetchPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ispProvider = Provider.of<ISPProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('ISP Plans')),
      body: ispProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ispProvider.error.isNotEmpty
              ? Center(child: Text('Error: ${ispProvider.error}'))
              : ListView.builder(
                  itemCount: ispProvider.plans.length,
                  itemBuilder: (context, index) {
                    final plan = ispProvider.plans[index];
                    return ListTile(
                      title: Text(plan.name),
                      subtitle: Text('Speed: ${plan.speed} Mbps'),
                    );
                  },
                ),
    );
  }
}
