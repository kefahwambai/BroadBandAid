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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
          shadowColor: Colors.blueAccent.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                _buildInfoRow(Icons.speed, 'Ping', '${result['connectivity']['ping']} ms'),
                _buildInfoRow(Icons.signal_cellular_alt, 'Signal Strength', '${result['connectivity']['signalStrength']} dBm'),
                _buildInfoRow(Icons.data_usage, 'Usage', '${double.parse(result['usage']['usagePercentage'].replaceAll('%', '')).round()}%'),
                _buildRecommendations('Tips;', recommendationList), 
                const SizedBox(height: 27),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: SingleChildScrollView(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                overflow: TextOverflow.visible,
                maxLines: 5,
              ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: recommendations.map((recommendation) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation.trim(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,

                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}

}