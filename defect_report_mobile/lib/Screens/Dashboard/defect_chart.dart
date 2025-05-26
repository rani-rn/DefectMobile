import 'package:defect_report_mobile/Models/chart_data_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DefectChart extends StatefulWidget {
  final DefectChartResponse data;
  const DefectChart({super.key, required this.data});

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

  List<int> _filterNonZeroIndexes() {
    List<int> filtered = [];
    final count = widget.data.labels.length;
    final dsCount = widget.data.datasets.length;

    for (int i = 0; i < count; i++) {
      bool hasValue = false;
      for (int j = 0; j < dsCount; j++) {
        if (widget.data.datasets[j].data[i] != 0) {
          hasValue = true;
          break;
        }
      }
      if (hasValue) filtered.add(i);
    }
    return filtered;
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
              width: 24,
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

  @override
  Widget build(BuildContext context) {
    final filtered = _filterNonZeroIndexes();
    final maxY = _findMaxY();
    final barGroups = _generateBarGroups(filtered, maxY);

    const barWidth = 24.0;
    const groupSpace = 40.0;
    final chartWidth = (barWidth + groupSpace) * filtered.length + 24;

    if (filtered.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text("No data available")),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: chartWidth,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    groupsSpace: groupSpace,
                    barGroups: barGroups,
                    alignment: BarChartAlignment.start,
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
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i >= filtered.length) return const SizedBox();

                            final originalIndex = filtered[i];
                            final label = widget.data.labels[originalIndex];
                            final parts = label.split(' ');

                            return SideTitleWidget(
                              meta: meta,
                              space: 8,
                              child: SizedBox(
                                width: 50,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: parts.map((part) {
                                    return FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        part,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }).toList(),
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

                          final defects = widget.data.datasets
                              .map((ds) {
                                final val = ds.data[originalIndex].toDouble();
                                return val > 0
                                    ? "${ds.label}: ${val.toInt()}"
                                    : null;
                              })
                              .whereType<String>()
                              .toList();

                          setState(() {
                            tooltipText = defects.join('\n');
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
            ),
            if (touchPosition != null && tooltipText != null)
             Builder(builder: (context) {
            final screenWidth = MediaQuery.of(context).size.width;
            const tooltipWidth = 120.0;
            const tooltipHeight = 40.0;

            final left = (screenWidth - tooltipWidth) / 2;
            final top = (touchPosition!.dy - tooltipHeight).clamp(8.0, double.infinity);

             return Positioned(
                
                left: left,
              top: top,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: tooltipWidth,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tooltipText!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                );
             }),
          ],
        ),
      ),
    );
  }
}
