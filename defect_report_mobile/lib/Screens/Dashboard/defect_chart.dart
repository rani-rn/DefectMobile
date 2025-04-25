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
          width: (filteredData.length * 60).toDouble().clamp(300, 1000),
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: _generateSpots(filteredData),
                  isCurved: true,
                  color: Colors.cyanAccent,
                  barWidth: 3,
                  belowBarData: BarAreaData(show: false),
                  dotData: FlDotData(show: true),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              gridData: FlGridData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final index = spot.x.toInt();
                      final label = filteredData[index].label;
                      final value = filteredData[index].value;
                      return LineTooltipItem(
                        '$label\n$value',
                        const TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                ),
              ),
              minY: 0,
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots(List<DefectChartData> filteredData) {
    return filteredData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final value = entry.value.value.toDouble();
      return FlSpot(index, value);
    }).toList();
  }
}
