import 'package:defect_report_mobile/Models/chart_data_model.dart';
import 'package:defect_report_mobile/Screens/Dashboard/box_widgets.dart';
import 'package:defect_report_mobile/Services/api_services.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? selectedLine;
  String selectedPeriod = 'daily';
  List<DefectChartData> chartData = [];
  int daily = 0, weekly = 0, monthly = 0, annual = 0;

  final List<String> lineOptions = ['All Line Production', 'Line A', 'Line B'];

  Future<void> loadData() async {
    final data = await ApiServices.fetchChartData(
      lineProductionId: selectedLine,
      timePeriod: selectedPeriod,
    );
    setState(() {
      chartData = data["chartData"];
      daily = data["daily"];
      weekly = data["weekly"];
      monthly = data["monthly"];
      annual = data["annual"];
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = (screenWidth - 48) / 2; // 16 padding kiri + kanan dan 16 spacing antar kotak

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: selectedLine,
                  hint: const Text("Select Line"),
                  items: lineOptions.map((line) {
                    return DropdownMenuItem(
                      value: line == 'All Line Production' ? null : line,
                      child: Text(line),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => selectedLine = val);
                    loadData();
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedPeriod,
                  items: ['daily', 'weekly', 'monthly', 'annual'].map((period) {
                    return DropdownMenuItem(value: period, child: Text(period));
                  }).toList(),
                  onChanged: (val) {
                    setState(() => selectedPeriod = val!);
                    loadData();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                SizedBox(width: itemWidth, child: SummaryBox(title: "Daily", value: daily)),
                SizedBox(width: itemWidth, child: SummaryBox(title: "Weekly", value: weekly)),
                SizedBox(width: itemWidth, child: SummaryBox(title: "Monthly", value: monthly)),
                SizedBox(width: itemWidth, child: SummaryBox(title: "Annual", value: annual)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 400,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                borderRadius: BorderRadius.circular(10),
              ),
              // child: chartData.isEmpty
              //     ? const Center(child: Text("No data"))
              //     : DefectChart(data: chartData),
            ),
          ],
        ),
      ),
    );
  }
}
