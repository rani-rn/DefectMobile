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
  int daily = 0, weekly = 0, monthly = 0;

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
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Dashboard", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
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
                  items: ['daily', 'weekly', 'monthly'].map((period) {
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 300,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // child: chartData.isEmpty
                    //     ? const Center(child: Text("No data"))
                    //     : DefectChartData(data: chartData),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    SummaryBox(title: "Daily", value: daily),
                    const SizedBox(height: 10),
                    SummaryBox(title: "Weekly", value: weekly),
                    const SizedBox(height: 10),
                    SummaryBox(title: "Monthly", value: monthly),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
