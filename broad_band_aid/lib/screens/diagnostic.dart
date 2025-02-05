import 'package:flutter/material.dart';

class DiagnosticsScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const DiagnosticsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final recommendations = result['recommendations'] ?? 'No recommendations available.';

    final recommendationList = recommendations
        .toString()
        .split(RegExp(r'[,.\n]'))
        .where((item) => item.trim().isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWideScreen ? 600 : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? 32.0 : 16.0,
                  vertical: 16.0,
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  shadowColor: Colors.blueAccent.withOpacity(0.2),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Your Network Health',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const Divider(thickness: 1, color: Colors.grey),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.speed,
                          'Ping',
                          '${result['connectivity']['ping']} ms',
                        ),
                        _buildInfoRow(
                          Icons.signal_cellular_alt,
                          'Signal Strength',
                          '${result['connectivity']['signalStrength']} dBm',
                        ),
                        _buildInfoRow(
                          Icons.data_usage,
                          'Usage',
                          '${double.parse(result['usage']['usagePercentage'].replaceAll('%', '')).round()}%',
                        ),
                        const SizedBox(height: 20),
                        _buildRecommendations('Tips:', recommendationList),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(String title, List<String> recommendations) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.recommend, size: 24, color: Colors.blueAccent),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: recommendations.map((recommendation) {
              return Chip(
                label: Text(
                  recommendation.trim(),
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                backgroundColor: Colors.grey[200],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}