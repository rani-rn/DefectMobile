import 'package:defect_report_mobile/Models/chart_data_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DefectChart extends StatelessWidget {
  final List<DefectChartData> data;
  const DefectChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final filteredData = data
        .where(
            (item) => item.value != 0 && item.label.toLowerCase() != 'overflow')
        .toList();

    return SizedBox(
      height: 300,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: (filteredData.length * 40).toDouble().clamp(300, 1000),
          child: BarChart(
            BarChartData(
              barGroups: _generateBarGroups(filteredData),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= filteredData.length) {
                        return const SizedBox();
                      }
                      return SideTitleWidget(
                        space: 4,
                        meta: meta,
                        child: Text(
                          filteredData[index].label,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(
      List<DefectChartData> filteredData) {
    return filteredData.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.value.toDouble(),
            color: Colors.cyanAccent.withAlpha((0.8 * 255).toInt()),
            borderRadius: BorderRadius.circular(6),
            width: 22,
          ),
        ],
      );
    }).toList();
  }
}
