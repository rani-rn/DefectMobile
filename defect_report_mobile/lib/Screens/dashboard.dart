import 'package:defect_report_mobile/Models/chart_data_model.dart';
import 'package:defect_report_mobile/Models/line_production_model.dart';
import 'package:defect_report_mobile/Screens/Dashboard/box_widgets.dart';
import 'package:defect_report_mobile/Screens/Dashboard/defect_chart.dart';
import 'package:defect_report_mobile/Services/api_services.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int? selectedLineId;
  String selectedPeriod = 'daily';
  List<DefectChartData> chartData = [];
  int daily = 0, weekly = 0, monthly = 0, annual = 0;

  List<LineProduction> lineOptions = [];
  bool isLoadingLine = true;

  Future<void> loadLineProductions() async {
    try {
      final data = await ApiServices.getDropdownData();
      final lines = (data["lineProductions"] as List)
          .map((e) => LineProduction.fromJson(e))
          .toList();

      setState(() {
        lineOptions = lines;
        isLoadingLine = false;
      });
    } catch (e) {
      print("Error loading line production: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load line production")),
        );
      }
    }
  }

  Future<void> loadData() async {
    try {
      final data = await ApiServices.fetchChartData(
        lineProductionId: selectedLineId,
        timePeriod: selectedPeriod,
      );
      setState(() {
        chartData = List<DefectChartData>.from(data["chartData"]);

        daily = data["daily"] ?? 0;
        weekly = data["weekly"] ?? 0;
        monthly = data["monthly"] ?? 0;
        annual = data["annual"] ?? 0;
      });
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading data: $e")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadLineProductions().then((_) => loadData());
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = (screenWidth - 48) / 2;

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoadingLine)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<int?>(
                    value: selectedLineId,
                    hint: const Text("Select Line"),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text("All Line Production"),
                      ),
                      ...lineOptions.map((line) => DropdownMenuItem<int?>(
                            value: line.id,
                            child: Text(line.lineProductionName),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() => selectedLineId = val);
                      loadData();
                    },
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: selectedPeriod,
                    items: ['daily', 'weekly', 'monthly', 'annual']
                        .map((period) => DropdownMenuItem(
                              value: period,
                              child: Text(period),
                            ))
                        .toList(),
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
                SizedBox(
                    width: itemWidth,
                    child: SummaryBox(title: "Daily", value: daily)),
                SizedBox(
                    width: itemWidth,
                    child: SummaryBox(title: "Weekly", value: weekly)),
                SizedBox(
                    width: itemWidth,
                    child: SummaryBox(title: "Monthly", value: monthly)),
                SizedBox(
                    width: itemWidth,
                    child: SummaryBox(title: "Annual", value: annual)),
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
              child: chartData.isEmpty
                  ? const Center(child: Text("No data available"))
                  : DefectChart(data: chartData),
            ),
          ],
        ),
      ),
    );
  }
}
