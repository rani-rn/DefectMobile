import 'package:flutter/material.dart';
class BreakdownCard extends StatelessWidget {
  final String? label;
  final String? lineProduction;
  final List<Map<String, dynamic>> breakdownData;

  const BreakdownCard({
    super.key,
    this.label,
    this.lineProduction,
    required this.breakdownData,
  });

  @override
  Widget build(BuildContext context) {
    if (label == null || lineProduction == null) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Breakdown for $label - $lineProduction'),
            const SizedBox(height: 8),
            ...breakdownData.map((item) {
              return Text('${item["defect"]}: ${item["count"]}');
            }),
          ],
        ),
      ),
    );
  }
}
