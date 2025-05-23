import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DefectChartData {
  final String label; 
  final Map<String, int> defectCounts;

  DefectChartData({
    required this.label,
    required this.defectCounts,
  });
}

class DefectChart extends StatelessWidget {
  final List<DefectChartData> data;

  const DefectChart({super.key, required this.data});

  List<Color> getColors(int count) {
    final baseColors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.cyan, Colors.amber,
      Colors.brown, Colors.indigo, Colors.pink,
    ];
    return List.generate(count, (index) => baseColors[index % baseColors.length]);
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("Tidak ada data chart"));
    }

    final defectNames = <String>{
      for (var item in data) ...item.defectCounts.keys,
    }.toList();

    final colors = getColors(defectNames.length);
    final limitedData = data.take(8).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(limitedData, defectNames),
        barGroups: List.generate(limitedData.length, (index) {
          final item = limitedData[index];
          final barRods = <BarChartRodStackItem>[];

          double runningTotal = 0;
          for (var i = 0; i < defectNames.length; i++) {
            final defect = defectNames[i];
            final value = (item.defectCounts[defect] ?? 0).toDouble();
            if (value > 0) {
              barRods.add(BarChartRodStackItem(
                runningTotal,
                runningTotal + value,
                colors[i],
              ));
              runningTotal += value;
            }
          }

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: runningTotal,
                rodStackItems: barRods,
                width: 18,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index >= 0 && index < limitedData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      limitedData[index].label,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        gridData: FlGridData(show: true),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = limitedData[group.x.toInt()];
              final stacks = rod.rodStackItems;
              if (stacks.isEmpty) return null;

              final tooltipLines = <String>[];
              for (var i = 0; i < stacks.length; i++) {
                final fromY = stacks[i].fromY;
                final toY = stacks[i].toY;
                final value = toY - fromY;
                if (value > 0) {
                  tooltipLines.add("${defectNames[i]}: ${value.toInt()}");
                }
              }

              return BarTooltipItem(
                tooltipLines.join('\n'),
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
           // tooltipBgColor: Colors.black87,
          ),
        ),
      ),
    );
  }

  double _getMaxY(List<DefectChartData> data, List<String> defects) {
    double maxY = 0;
    for (var item in data) {
      double total = 0;
      for (var def in defects) {
        total += (item.defectCounts[def] ?? 0).toDouble();
      }
      if (total > maxY) maxY = total;
    }
    return maxY + 5;
  }
}
