import 'package:defect_report_mobile/Models/chart_data_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DefectChart extends StatefulWidget {
  final DefectChartResponse data;
  final void Function(String label, String? line) onBarTapped;

  const DefectChart({
    super.key,
    required this.data,
    required this.onBarTapped,
  });

  @override
  State<DefectChart> createState() => _DefectChartState();
}

class _DefectChartState extends State<DefectChart> {
  int? touchedGroupIndex;
  String? tooltipText;
  Offset? touchPosition;

  double _findMaxY() {
    double maxY = 0;
    for (int i = 0; i < widget.data.labels.length; i++) {
      double stackSum = 0;
      for (var ds in widget.data.datasets) {
        stackSum += ds.data[i].toDouble();
      }
      if (stackSum > maxY) maxY = stackSum;
    }
    return (maxY == 0) ? 5 : (maxY * 1.2).ceilToDouble();
  }

  List<BarChartGroupData> _generateBarGroups(List<int> filtered, double maxY) {
    List<BarChartGroupData> groups = [];

    for (int x = 0; x < filtered.length; x++) {
      final idx = filtered[x];
      double startY = 0;
      List<BarChartRodStackItem> stacks = [];

      for (var ds in widget.data.datasets) {
        double val = ds.data[idx].toDouble();
        if (val == 0) continue;

        final endY = startY + val;
        stacks.add(
          BarChartRodStackItem(
            startY,
            endY,
            Color(int.parse(ds.backgroundColor.replaceAll('#', '0xff'))),
          ),
        );
        startY = endY;
      }

      groups.add(
        BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: startY,
              width: 16, // Smaller width to fit all 12 bars
              rodStackItems: stacks,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY,
                color: Colors.grey.shade200,
              ),
            ),
          ],
        ),
      );
    }

    return groups;
  }

  String _shortenLabel(String label) {
    final parts = label.split(' ');
    return parts.map((part) {
      if (part.length >= 3) {
        return part.substring(0, 3);
      } else {
        return part;
      }
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final filtered = List.generate(widget.data.labels.length, (i) => i);
    final maxY = _findMaxY();
    final barGroups = _generateBarGroups(filtered, maxY);

    if (filtered.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text("No data available")),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  groupsSpace: 20, // Reduced spacing to fit 12 bars
                  barGroups: barGroups,
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY / 5).ceilToDouble(),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (maxY / 5).ceilToDouble(),
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i >= filtered.length) return const SizedBox();

                          final originalIndex = filtered[i];
                          final label = widget.data.labels[originalIndex];
                          final shortLabel = _shortenLabel(label);

                          return SideTitleWidget(
                            meta: meta,
                            space: 6,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                shortLabel,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      if (event is FlTapUpEvent && response?.spot != null) {
                        final groupIdx = response!.spot!.touchedBarGroupIndex;
                        final originalIndex = filtered[groupIdx];
                        final label = widget.data.labels[originalIndex];

                        String? lineProduction;
                        for (var ds in widget.data.datasets) {
                          if (ds.data[originalIndex] > 0) {
                            lineProduction = ds.label;
                            break;
                          }
                        }

                        widget.onBarTapped(label, lineProduction);

                        setState(() {
                          tooltipText = widget.data.datasets
                              .map((ds) {
                                final val = ds.data[originalIndex].toDouble();
                                return val > 0
                                    ? "${ds.label}: ${val.toInt()}"
                                    : null;
                              })
                              .whereType<String>()
                              .toList()
                              .join('\n');
                          touchPosition = response.spot!.offset;
                        });

                        Future.delayed(const Duration(seconds: 4), () {
                          if (mounted) setState(() => tooltipText = null);
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            if (touchPosition != null && tooltipText != null)
              Builder(builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                const tooltipWidth = 120.0;
                const tooltipHeight = 40.0;

                final left = (screenWidth - tooltipWidth) / 2;
                final top = (touchPosition!.dy - tooltipHeight)
                    .clamp(8.0, double.infinity);

                return Positioned(
                  left: left,
                  top: top,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: tooltipWidth,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tooltipText!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
