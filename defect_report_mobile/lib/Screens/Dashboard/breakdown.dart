import 'package:defect_report_mobile/Models/breakdown_model.dart';
import 'package:flutter/material.dart';

class BreakdownCard extends StatelessWidget {
  final String? label;
  final List<BreakdownItem> breakdownList;

  const BreakdownCard({
    super.key,
    this.label,
    required this.breakdownList,
  });

  @override
  Widget build(BuildContext context) {
    if (label == null || breakdownList.isEmpty) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Breakdown for "$label"',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...breakdownList.map((item) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.lineProduction,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[700],
                        ),
                  ),
                  const SizedBox(height: 4),
                  ...item.topDefects.map(
                    (defect) => Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 2, bottom: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.bug_report, size: 16, color: Colors.redAccent),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              defect.defect,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '${defect.qty}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(thickness: 0.8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
