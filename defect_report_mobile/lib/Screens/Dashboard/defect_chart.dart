import 'package:flutter/material.dart';
import 'package:defect_report_mobile/Services/api_services.dart';
import 'package:defect_report_mobile/Models/chart_data_model.dart';
import 'package:fl_chart/fl_chart.dart';

class DefectChartScreen extends StatelessWidget {
  final int? lineProductionId;
  final String timePeriod;

  const DefectChartScreen({super.key, this.lineProductionId, this.timePeriod = 'daily'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Defect Chart'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiServices.fetchChartData(
          lineProductionId: lineProductionId,
          timePeriod: timePeriod,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!['chartData'] as List;
            final chartData = data.map((e) => DefectChartData.fromJson(e)).toList();
            return DefectChart(data: chartData);
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

class DefectChart extends StatelessWidget {
  final List<DefectChartData> data;
  const DefectChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: _generateBarGroups(),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.value.toDouble(),
            color: Colors.lightBlueAccent,
            borderRadius: BorderRadius.circular(6),
            width: 18,
          ),
        ],
      );
    }).toList();
  }
}
